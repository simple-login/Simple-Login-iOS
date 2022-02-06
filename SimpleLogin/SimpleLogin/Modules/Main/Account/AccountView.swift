//
//  AccountView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AlertToast
import Combine
import Kingfisher
import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

// swiftlint:disable let_var_whitespace
struct AccountView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AccountViewModel()
    @State private var confettiCounter = 0
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

        let navigationTitle = viewModel.userInfo.name.isEmpty ? viewModel.userInfo.email : viewModel.userInfo.name

        NavigationView {
            if viewModel.isInitialized {
                ZStack {
                    NavigationLink(
                        isActive: $showingUpgradeView,
                        destination: {
                            UpgradeView {
                                confettiCounter += 1
                                viewModel.forceRefresh()
                            }
                        },
                        label: { EmptyView() })

                    Form {
                        UserInfoSection(showingUpgradeView: $showingUpgradeView)
                        if viewModel.biometryType == .touchID || viewModel.biometryType == .faceID {
                            BiometricAuthenticationSection()
                        }
                        LocalSettingsSection()
                        NewslettersSection()
                        AliasesSection()
                        SenderFormatSection()
                        KeyboardExtensionSection()
                        LogOutSection(onLogOut: onLogOut)
                    }
                    .environmentObject(viewModel)
                }
                .navigationTitle(navigationTitle)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .foregroundColor(.secondary)
                    .opacity(0.1)
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.setSession(session)
            viewModel.getRequiredInformation()
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
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(viewModel.error)
        }
        .toast(isPresenting: showingMessageAlert) {
            AlertToast.messageAlert(viewModel.message)
        }
    }
}

private struct UserInfoSection: View {
    @EnvironmentObject private var viewModel: AccountViewModel
    @State private var showingEditActionSheet = false
    @State private var showingPhotoPickerSheet = false
    @State private var showingEditDisplayNameSheet = false
    @Binding var showingUpgradeView: Bool

    var body: some View {
        Section {
            VStack {
                personalInfoView
                    .sheet(isPresented: $showingPhotoPickerSheet) {
                        PhotoPickerView { pickedImage in
                            viewModel.uploadNewProfilePhoto(pickedImage)
                        }
                        .forceDarkModeIfApplicable()
                    }
                Divider()
                membershipView
                    .sheet(isPresented: $showingEditDisplayNameSheet) {
                        EditDisplayNameView { displayName in
                            viewModel.updateDisplayName(displayName)
                        }
                        .environmentObject(viewModel)
                        .forceDarkModeIfApplicable()
                    }
            }
        }
    }

    private var personalInfoView: some View {
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

            Button(action: {
                showingEditActionSheet = true
            }, label: {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.slPurple)
                    .font(.title3)
            })
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.isLoading)
        }
        .actionSheet(isPresented: $showingEditActionSheet) {
            editActionSheet
        }
        .alert(isPresented: $viewModel.askingForSettings) {
            settingsAlert
        }
    }

    private var defaultAvatarImage: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(.slPurple)
            .frame(width: min(64, UIScreen.main.bounds.width / 7))
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
            showingEditDisplayNameSheet = true
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

/// For settings that are local like haptic effect & dark mode
private struct LocalSettingsSection: View {
    @AppStorage(kHapticFeedbackEnabled) private var hapticEffectEnabled = true
    @AppStorage(kForceDarkMode) private var forceDarkMode = false

    var body: some View {
        Section {
            Toggle("Haptic feedback", isOn: $hapticEffectEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))

            Toggle("Force dark mode", isOn: $forceDarkMode)
                .toggleStyle(SwitchToggleStyle(tint: .slPurple))
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
                // Display mode
                Group {
                    Text("Display mode")
                        .fixedSize(horizontal: false, vertical: false)
                    Picker(selection: $viewModel.aliasDisplayMode,
                           label: Text(viewModel.aliasDisplayMode.description)) {
                        ForEach(AliasDisplayMode.allCases, id: \.self) { mode in
                            Text(mode.description)
                                .tag(mode)
                        }
                    }
                           .pickerStyle(SegmentedPickerStyle())
                    AliasDisplayModePreview()
                    Divider()
                }

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
        Section(header: Text("Sender address format"),
                footer: Text("John Doe who uses john.doe@example.com to send you an email, how would you like to format his email?")) {
            VStack {
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

private struct KeyboardExtensionSection: View {
    @AppStorage(kKeyboardExtensionMode, store: .shared)
    private var keyboardExtensionMode: KeyboardExtensionMode = .all
    @State private var showingExplanation = false

    var body: some View {
        Section(header: Text("Keyboard extension"),
                footer: footerView) {
            Picker(selection: $keyboardExtensionMode,
                   label: Text(keyboardExtensionMode.title)) {
                ForEach(KeyboardExtensionMode.allCases, id: \.self) { mode in
                    Text(mode.title)
                        .tag(mode)
                }
            }
                   .pickerStyle(SegmentedPickerStyle())
                   .sheet(isPresented: $showingExplanation) {
                       KeyboardFullAccessExplanationView()
                   }
        }
    }

    private var footerView: some View {
        VStack {
            Text("You need to enable and give the keyboard full access in order to use it.\nGo to Settings ➝ General ➝ Keyboard ➝ Keyboards.")
            HStack {
                Button(action: {
                    UIApplication.shared.openSettings()
                }, label: {
                    Text("Open Settings")
                        .fontWeight(.medium)
                        .foregroundColor(.slPurple)
                })

                Text("•")

                Button(action: {
                    showingExplanation = true
                }, label: {
                    Text("Why full access?")
                        .fontWeight(.medium)
                        .foregroundColor(.slPurple)
                })

                Spacer()
            }
        }
    }
}

private struct KeyboardFullAccessExplanationView: View {
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("""
        Most of the functionalities of this application are based on making requests to our server. Every request is attached with an API key in order for our server to authenticate you.

        When you successfully log in, our server sends a valid API key to the application. The application then saves this API key to a Keychain Group in order to reuse it in next sessions without asking you to authenticate again.

        The keyboard extension needs to use the API key saved in Keychain Group by the host application to make requests by itself. Such access to Keychain Group requires full access. The keyboard extension does not record nor share anything you type.
        """)

                    HStack {
                        Text("Need more information?")
                        URLButton(urlString: "mailto:hi@simplelogin.io", foregroundColor: .slPurple) {
                            Label("Email us", systemImage: "envelope.fill")
                        }
                    }
                    .padding(.top)
                }
                    .padding()
            }
            .navigationTitle("Why full access?")
            .navigationBarItems(leading: closeButton)
        }
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
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
