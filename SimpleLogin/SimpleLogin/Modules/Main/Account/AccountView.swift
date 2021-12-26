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

struct AccountView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AccountViewModel()
    @State private var showingLoadingAlert = false
    let onLogOut: () -> Void

    var body: some View {
        NavigationView {
            if viewModel.isInitialized {
                Form {
                    UserInfoSection(userInfo: viewModel.userInfo,
                                    onModifyProfilePhoto: { photoBase64String in

                    },
                                    onModifyDisplayName: { displayName in

                    })

                    if viewModel.biometryType == .touchID || viewModel.biometryType == .faceID {
                        BiometricAuthenticationSection(biometryType: viewModel.biometryType)
                    }

                    NewslettersSection(notification: $viewModel.notification)

                    RandomAliasSection(randomMode: $viewModel.randomMode,
                                       randomAliasDefaultDomain: $viewModel.randomAliasDefaultDomain,
                                       usableDomains: viewModel.usableDomains)

                    SenderFormatSection(senderFormat: $viewModel.senderFormat)

                    LogOutSection(onLogOut: onLogOut)
                }
                .navigationTitle("My account")
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
            viewModel.getRequiredInformation(session: session)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
    }
}

private struct UserInfoSection: View {
    let userInfo: UserInfo
    let onModifyProfilePhoto: (String?) -> Void
    let onModifyDisplayName: (String?) -> Void

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
                if !userInfo.name.isEmpty {
                    Text(userInfo.name)
                        .fontWeight(.semibold)
                }
                Text(userInfo.email)
            }

            Spacer()
        }
    }

    @ViewBuilder
    private var membershipView: some View {
        HStack {
            if userInfo.inTrial {
                Text("Premium trial membership")
                    .foregroundColor(.blue)
            } else if userInfo.isPremium {
                Text("Premium membership")
                    .foregroundColor(.green)
            } else {
                Text("Free membership")
            }

            Spacer()

            if !userInfo.inTrial && !userInfo.isPremium {
                Button(action: {
                    // TODO: Upgrade
                }, label: {
                    Label("Upgrade", systemImage: "sparkles")
                        .foregroundColor(.blue)
                })
            }
        }
    }
}

private struct BiometricAuthenticationSection: View {
    let biometryType: LABiometryType

    var body: some View {
        Section(footer: Text("Restrict unwanted access to your SimpleLogin account on this device")) {
            HStack {
                Label(biometryType.description, systemImage: biometryType.systemImageName)
                Spacer()
                Toggle("", isOn: .constant(false))
                    .toggleStyle(SwitchToggleStyle(tint: .slPurple))
            }
        }
    }
}

private struct NewslettersSection: View {
    @Binding var notification: Bool

    var body: some View {
        Section(footer: Text("We will occasionally send you emails with new feature announcements")) {
            HStack {
                Label("Newsletters", systemImage: "newspaper")
                Spacer()
                Toggle("", isOn: $notification)
                    .toggleStyle(SwitchToggleStyle(tint: .slPurple))
            }
        }
    }
}

private struct RandomAliasSection: View {
    @Binding var randomMode: RandomMode
    @Binding var randomAliasDefaultDomain: String
    let usableDomains: [UsableDomain]

    var body: some View {
        Section {
            VStack {
                HStack {
                    Label("Random alias", systemImage: "shuffle")
                    Spacer()
                }

                Picker(selection: $randomMode, label: Text(randomMode.description)) {
                    ForEach(RandomMode.allCases, id: \.self) { mode in
                        Text(mode.description)
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Divider()

                HStack {
                    Text("Default domain")
                    Spacer()
                    Picker(selection: $randomAliasDefaultDomain, label: Text(randomAliasDefaultDomain)) {
                        ForEach(usableDomains, id: \.domain) { usableDomain in
                            VStack {
                                Text(usableDomain.domain + (usableDomain.isCustom ? " 🟢" : ""))
                            }
                            .tag(usableDomain.domain)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }
}

private struct SenderFormatSection: View {
    @Binding var senderFormat: SenderFormat

    var body: some View {
        Section(footer: Text("John Doe who uses john.doe@example.com to send you an email, how would you like to format his email?")) {
            VStack {
                HStack {
                    Label("Sender address format", systemImage: "square.and.at.rectangle")
                    Spacer()
                }
                Picker(selection: $senderFormat, label: Text(senderFormat.description)) {
                    ForEach(SenderFormat.allCases, id: \.self) { format in
                        Text(format.description)
                            .tag(format)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

private struct LogOutSection: View {
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
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("You will be logged out"),
                          message: Text("Please confirm"),
                          primaryButton: .destructive(Text("Yes, log me out"), action: onLogOut),
                          secondaryButton: .cancel())
                }
        }
    }
}
