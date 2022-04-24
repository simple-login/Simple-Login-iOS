//
//  AccountView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import Kingfisher
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

// swiftlint:disable let_var_whitespace
struct AccountView: View {
    @StateObject private var viewModel: AccountViewModel
    @Binding var upgradeNeeded: Bool
    @State private var confettiCounter = 0
    @State private var showingPremiumView = false
    @State private var showingUpgradeView = false
    @State private var showingLoadingAlert = false
    let onLogOut: () -> Void

    init(session: Session,
         upgradeNeeded: Binding<Bool>,
         onLogOut: @escaping () -> Void) {
        self._viewModel = StateObject(wrappedValue: .init(session: session))
        self._upgradeNeeded = upgradeNeeded
        self.onLogOut = onLogOut
    }

    var body: some View {
        let navigationTitle = viewModel.userInfo.name.isEmpty ? viewModel.userInfo.email : viewModel.userInfo.name

        NavigationView {
            if viewModel.isInitialized {
                Form {
                    UserInfoSection()
                    NewslettersSection()
                    AliasesSection()
                    SenderFormatSection()
                    LogOutSection(onLogOut: onLogOut)
                }
                .ignoresSafeArea(.keyboard)
                .environmentObject(viewModel)
                .navigationTitle(navigationTitle)
                .navigationBarItems(trailing: trailingButton)
                .onAppear {
                    if upgradeNeeded, !showingUpgradeView {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            upgradeNeeded = false
                            showingUpgradeView = true
                        }
                    }
                }
            } else {
                EmptyView()
            }

            DetailPlaceholderView(systemIconName: "person")
        }
        .slNavigationView()
        .onAppear {
            viewModel.getRequiredInformation()
        }
        .onReceive(Just(viewModel.isInitialized)) { isInitialized in
            guard isInitialized, UIDevice.current.userInterfaceIdiom != .phone else { return }
            if viewModel.userInfo.inTrial || !viewModel.userInfo.isPremium {
                showingUpgradeView = true
            } else {
                showingPremiumView = true
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.shouldLogOut)) { shouldLogOut in
            if shouldLogOut {
                onLogOut()
            }
        }
        .modifier(ConfettiableModifier(counter: $confettiCounter))
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastMessage($viewModel.message)
        .alertToastError($viewModel.error)
    }

    @ViewBuilder
    private var trailingButton: some View {
        if !viewModel.userInfo.inTrial && viewModel.userInfo.isPremium {
            NavigationLink(
                isActive: $showingPremiumView,
                destination: {
                    PremiumView()
                },
                label: {
                    Button(action: {
                        showingPremiumView = true
                    }, label: {
                        Text("Premium")
                    })
                })
        } else {
            NavigationLink(
                isActive: $showingUpgradeView,
                destination: {
                    UpgradeView(session: viewModel.session) {
                        confettiCounter += 1
                        viewModel.forceRefresh()
                    }
                },
                label: {
                    Button(action: {
                        showingUpgradeView = true
                    }, label: {
                        Text("Upgrade")
                    })
                })
        }
    }
}

private struct UserInfoSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @State private var showingPhotoPicker = false
    @State private var showingEditNameAlert = false

    var body: some View {
        Section {
            HStack {
                let imageWidth = min(64, UIScreen.main.bounds.width / 7)
                if let profilePictureUrl = viewModel.userInfo.profilePictureUrl {
                    KFImage.url(URL(string: profilePictureUrl))
                        .placeholder { defaultAvatarImage }
                        .loadDiskFileSynchronously()
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageWidth, height: imageWidth)
                        .clipShape(Circle())
                } else {
                    defaultAvatarImage
                }

                VStack(alignment: .leading) {
                    if !viewModel.userInfo.name.isEmpty {
                        Text(viewModel.userInfo.name)
                            .fontWeight(.semibold)
                    }
                    Text(viewModel.userInfo.email)
                }

                Spacer()

                editMenu
            }
            .alert(isPresented: $viewModel.askingForSettings) {
                settingsAlert
            }
            .sheet(isPresented: $showingPhotoPicker) {
                PhotoPickerView { pickedImage in
                    viewModel.uploadNewProfilePhoto(pickedImage)
                }
            }
            .textFieldAlert(isPresented: $showingEditNameAlert, config: editNameConfig)
        }
    }

    private var defaultAvatarImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.slPurple)
            .frame(width: min(64, UIScreen.main.bounds.width / 7))
    }

    private var editMenu: some View {
        Menu(content: {
            Section {
                Button(action: {
                    showingPhotoPicker = true
                }, label: {
                    Label("Upload new profile photo", systemImage: "square.and.arrow.up")
                })

                Button(action: {
                    viewModel.removeProfilePhoto()
                }, label: {
                    Label("Remove profile photo", systemImage: "trash")
                })
            }

            Section {
                Button(action: {
                    showingEditNameAlert = true
                }, label: {
                    if #available(iOS 15, *) {
                        Label("Edit display name", systemImage: "person.text.rectangle")
                    } else {
                        Label("Edit display name", systemImage: "square.and.at.rectangle")
                    }
                })
            }
        }, label: {
            Image(systemName: "square.and.pencil")
        })
            .disabled(viewModel.isLoading)
    }

    private var settingsAlert: Alert {
        Alert(title: Text("Please allow access to photo library"),
              message: nil,
              primaryButton: .default(Text("Open Settings")) {
            viewModel.openAppSettings()
        },
              secondaryButton: .cancel())
    }

    private var editNameConfig: TextFieldAlertConfig {
        TextFieldAlertConfig(title: "Edit display name",
                             text: viewModel.userInfo.name,
                             keyboardType: .default,
                             clearButtonMode: .always,
                             actionTitle: "Save") { newDisplayName in
            viewModel.updateDisplayName(newDisplayName ?? "")
        }
    }
}

private struct NewslettersSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel

    var body: some View {
        Section(footer: Text("We will occasionally send you emails with new feature announcements")) {
            Toggle(isOn: $viewModel.notification) {
                Label("Newsletters", systemImage: "newspaper")
            }
            .toggleStyle(SwitchToggleStyle(tint: .slPurple))
        }
    }
}

private struct AliasesSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel

    var body: some View {
        Section(header: Text("Aliases")) {
            VStack(alignment: .leading) {
                // Random mode
                Text("Random mode")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker(selection: $viewModel.randomMode,
                       label: Text(viewModel.randomMode.description)) {
                    ForEach(RandomMode.allCases, id: \.self) { mode in
                        Text(mode.description)
                            .tag(mode)
                    }
                }
                       .pickerStyle(SegmentedPickerStyle())
                       .disabled(viewModel.isLoading)

                Text("Ex: \(viewModel.randomMode.example)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                // Default domain
                Picker("Default domain", selection: $viewModel.randomAliasDefaultDomain) {
                    ForEach(viewModel.usableDomains, id: \.domain) { usableDomain in
                        HStack {
                            Text(usableDomain.domain)
                            if usableDomain.isCustom {
                                Image(systemName: "checkmark.seal.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20, alignment: .leading)
                            }
                        }
                        .tag(usableDomain.domain)
                    }
                }
                       .disabled(viewModel.isLoading)

                Divider()

                // Random alias suffix
                Text("Random alias suffix")
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker(selection: $viewModel.randomAliasSuffix,
                       label: Text(viewModel.randomAliasSuffix.description)) {
                    ForEach(RandomAliasSuffix.allCases, id: \.self) { mode in
                        Text(mode.description)
                            .tag(mode)
                    }
                }
                       .pickerStyle(SegmentedPickerStyle())
                       .disabled(viewModel.isLoading)

                Text("Ex: \(viewModel.randomAliasSuffix.example)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private struct SenderFormatSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel

    var body: some View {
        Section(header: Text("Sender address format"),
                footer: Text("John Doe who uses john.doe@example.com to send you an email, how would you like to format his email?")) {
            Picker("Format", selection: $viewModel.senderFormat) {
                ForEach(SenderFormat.allCases, id: \.self) { format in
                    Text(format.description)
                        .tag(format)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}

private struct LogOutSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @State private var isShowingAlert = false
    var onLogOut: () -> Void

    var body: some View {
        Section {
            Button(action: {
                Vibration.rigid.vibrate(fallBackToOldSchool: true)
                isShowingAlert = true
            }, label: {
                Text("Log out")
                    .foregroundColor(.red)
            })
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.5 : 1.0)
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("You will be logged out"),
                          message: Text("Please confirm"),
                          primaryButton: .destructive(Text("Yes, log me out"), action: onLogOut),
                          secondaryButton: .cancel())
                }
        }
    }
}

private struct EditDisplayNameView: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var displayName = ""
    var onEnterDisplayName: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display name")) {
                    if #available(iOS 15, *) {
                        AutoFocusTextField(text: $displayName)
                    } else {
                        TextField("", text: $displayName)
                            .labelsHidden()
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                    }
                }
            }
            .navigationTitle(viewModel.userInfo.email)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            displayName = viewModel.userInfo.name
        }
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    private var doneButton: some View {
        Button(action: {
            onEnterDisplayName(displayName)
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Done")
        })
    }
}
