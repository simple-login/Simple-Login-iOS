//
//  AccountView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = AccountViewModel()
    @State private var showingLoadingAlert = false
    let onLogOut: () -> Void

    var body: some View {
        NavigationView {
            if let userInfo = viewModel.userInfo,
               let userSettings = viewModel.userSettings {
                Form {
                    Section {
                        UserInfoView(userInfo: userInfo,
                                     onModifyProfilePhoto: { photoBase64String in

                        },
                                     onModifyDisplayName: { displayName in

                        })
                    }

                    Section {
                        LogOutView(onLogOut: onLogOut)
                    }
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
            viewModel.getUserInfoAndSettings(session: session)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
    }
}

private struct UserInfoView: View {
    let userInfo: UserInfo
    let onModifyProfilePhoto: (String?) -> Void
    let onModifyDisplayName: (String?) -> Void

    var body: some View {
        VStack {
            personalInfoView
            Divider()
            membershipView
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

private struct LogOutView: View {
    @State private var isShowingAlert = false
    var onLogOut: () -> Void

    var body: some View {
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
