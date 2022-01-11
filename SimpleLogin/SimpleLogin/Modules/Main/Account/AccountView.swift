//
//  AccountView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AlertToast
import Combine
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

// swiftlint:disable let_var_whitespace
struct AccountView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AccountViewModel()
    @State private var showingUpgradeView = false
    @State private var showingLoadingAlert = false
    let onLogOut: () -> Void

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingMessageAlert = Binding<Bool>(get: {
            viewModel.message != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledMessage()
            }
        })

        NavigationView {
            if viewModel.isInitialized {
                ZStack {
                    NavigationLink(
                        isActive: $showingUpgradeView,
                        destination: {
                            UpgradeView {
                                viewModel.forceRefresh()
                            }
                        },
                        label: { EmptyView() })

                    Form {
                        UserInfoSection(showingUpgradeView: $showingUpgradeView)
                        if viewModel.biometryType == .touchID || viewModel.biometryType == .faceID {
                            BiometricAuthenticationSection()
                        }
                        NewslettersSection()
                        AliasesSection()
                        SenderFormatSection()
                        LogOutSection(onLogOut: onLogOut)
                    }
                    .environmentObject(viewModel)
                }
                .navigationTitle(viewModel.navigationTitle)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .foregroundColor(.secondary)
                    .opacity(0.1)
            }
        }
        .onAppear {
            viewModel.setSession(session)
            viewModel.getRequiredInformation()
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
        .toast(isPresenting: showingMessageAlert) {
            AlertToast.messageAlert(message: viewModel.message)
        }
    }
}

private struct UserInfoSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @State private var showingEditActionSheet = false
    @State private var showingPhotoPickerSheet = false
    @Binding var showingUpgradeView: Bool

    var body: some View {
        Section {
            VStack {
                personalInfoView
                Divider()
                membershipView
            }
        }
    }

    private var personalInfoView: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.slPurple)
                .frame(width: min(64, UIScreen.main.bounds.width / 7))

            VStack {
                if !viewModel.userInfo.name.isEmpty {
                    Text(viewModel.userInfo.name)
                        .fontWeight(.semibold)
                }
                Text(viewModel.userInfo.email)
            }

            Spacer()

            Button(action: {
                showingEditActionSheet = true
            }, label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.slPurple)
            })
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.isLoading)
        }
        .actionSheet(isPresented: $showingEditActionSheet) {
            editActionSheet
        }
        .sheet(isPresented: $showingPhotoPickerSheet) {
            PhotoPickerView { pickedImage in
                viewModel.uploadNewProfilePhoto(pickedImage)
            }
        }
        .alert(isPresented: $viewModel.askingForSettings) {
            settingsAlert
        }
    }

    @ViewBuilder
    private var membershipView: some View {
        HStack {
            if viewModel.userInfo.inTrial {
                Text("Premium trial membership")
                    .foregroundColor(.blue)
            } else if viewModel.userInfo.isPremium {
                Text("Premium membership")
                    .foregroundColor(.green)
            } else {
                Text("Free membership")
            }

            Spacer()

            if !viewModel.userInfo.inTrial && !viewModel.userInfo.isPremium {
                Button(action: {
                    showingUpgradeView = true
                }, label: {
                    Label("Upgrade", systemImage: "sparkles")
                        .foregroundColor(.blue)
                })
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.isLoading)
            }
        }
    }

    private var editActionSheet: ActionSheet {
        var buttons = [ActionSheet.Button]()
        buttons.append(.default(Text("Upload new profile photo")) {
            showingPhotoPickerSheet = true
        })
        buttons.append(.destructive(Text("Remove profile photo")) {
            viewModel.removeProfilePhoto()
        })
        buttons.append(.default(Text("Modify display name")) {
            print("Modify display name")
        })
        buttons.append(.cancel())
        return ActionSheet(title: Text("Modify profile information"), message: nil, buttons: buttons)
    }

    private var settingsAlert: Alert {
        Alert(title: Text("Please allow access to photo library"),
              message: nil,
              primaryButton: .default(Text("Open Settings")) {
            viewModel.openAppSettings()
        },
              secondaryButton: .cancel())
    }
}

private struct BiometricAuthenticationSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel

    var body: some View {
        Section(header: Text("Local authentication"),
                footer: Text("Restrict unwanted access to your SimpleLogin account on this device")) {
            VStack {
                Toggle(isOn: $viewModel.biometricAuthEnabled) {
                    Label(viewModel.biometryType.description, systemImage: viewModel.biometryType.systemImageName)
                }
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                if viewModel.biometricAuthEnabled {
                    Divider()
                    Toggle(isOn: $viewModel.ultraProtectionEnabled) {
                        Label {
                            Text("Ultra-protection")
                        } icon: {
                            if #available(iOS 15, *) {
                                Image(systemName: "bolt.shield")
                            } else {
                                Image(systemName: "shield")
                            }
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                    Text("Request authentication everytime the app goes in foreground")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
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
                    .fixedSize(horizontal: false, vertical: false)

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
                    .fixedSize(horizontal: false, vertical: false)

                Divider()

                // Default domain
                HStack {
                    Text("Default domain")
                    Spacer()
                    Picker(selection: $viewModel.randomAliasDefaultDomain,
                           label: Text(viewModel.randomAliasDefaultDomain)) {
                        ForEach(viewModel.usableDomains, id: \.domain) { usableDomain in
                            VStack {
                                Text(usableDomain.domain + (usableDomain.isCustom ? " 🟢" : ""))
                            }
                            .tag(usableDomain.domain)
                        }
                    }
                           .pickerStyle(MenuPickerStyle())
                           .disabled(viewModel.isLoading)
                }

                Divider()

                // Random alias suffix
                Text("Random alias suffix")
                    .fixedSize(horizontal: false, vertical: false)

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
                    .fixedSize(horizontal: false, vertical: false)
            }
        }
    }
}

private struct SenderFormatSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel

    var body: some View {
        Section(footer: Text("John Doe who uses john.doe@example.com to send you an email, how would you like to format his email?")) {
            VStack {
                HStack {
                    Label("Sender address format", systemImage: "square.and.at.rectangle")
                    Spacer()
                }
                Picker(selection: $viewModel.senderFormat, label: Text(viewModel.senderFormat.description)) {
                    ForEach(SenderFormat.allCases, id: \.self) { format in
                        Text(format.description)
                            .tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .disabled(viewModel.isLoading)
            }
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
                isShowingAlert = true
            }, label: {
                Text("Log out")
                    .fontWeight(.semibold)
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
