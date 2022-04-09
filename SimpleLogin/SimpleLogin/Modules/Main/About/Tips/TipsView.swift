//
//  TipsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

struct TipsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var localAuthenticator = LocalAuthenticator()
    let isFirstTime: Bool

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            localAuthenticator.error != nil
        }, set: { isShowing in
            if !isShowing {
                localAuthenticator.handledError()
            }
        })

        let showingMessageAlert = Binding<Bool>(get: {
            localAuthenticator.message != nil
        }, set: { isShowing in
            if !isShowing {
                localAuthenticator.handledMessage()
            }
        })

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack {
                    if isFirstTime {
                        Text("👋 Welcome to")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("SimpleLogin")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.slPurple)
                            .padding(.bottom)
                    }

                    Text("Here are some useful tips to help you make the most out of this application.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                switch localAuthenticator.biometryType {
                case .touchID:
                    TipView(tip: .touchId)
                        .environmentObject(localAuthenticator)
                case .faceID:
                    TipView(tip: .faceId)
                        .environmentObject(localAuthenticator)
                default:
                    EmptyView()
                }
                TipView(tip: .contextMenu)
                TipView(tip: .fullScreen)
                TipView(tip: .shareExtension)
                TipView(tip: .keyboardExtension)

                if isFirstTime {
                    PrimaryButton(title: "Got it 👍") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.top, 20)
            .padding()
        }
        .navigationBarHidden(isFirstTime)
        .navigationTitle("💡 Tips")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: isFirstTime ? closeButton : nil)
        .alertToastMessage(isPresenting: showingMessageAlert,
                           message: localAuthenticator.message)
        .alertToastError(isPresenting: showingErrorAlert,
                         error: localAuthenticator.error)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView(isFirstTime: true)
    }
}

private struct TipView: View {
    @EnvironmentObject var localAuthenticator: LocalAuthenticator
    @State private var showingSheet = false
    let tip: Tip

    var body: some View {
        VStack {
            HStack {
                switch tip {
                case .touchId:
                    Toggle(isOn: $localAuthenticator.biometricAuthEnabled) {
                        Text(LABiometryType.touchID.description)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                        .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                case .faceId:
                    Toggle(isOn: $localAuthenticator.biometricAuthEnabled) {
                        Text(LABiometryType.faceID.description)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                        .toggleStyle(SwitchToggleStyle(tint: .slPurple))

                default:
                    Text(tip.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

            HStack {
                Text(tip.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: tip.systemIconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.slPurple)
                    .frame(width: 40)
            }

            if let action = tip.action {
                Button(action: {
                    handleAction()
                }, label: {
                    Text(action)
                        .font(.headline)
                })
            }

            if tip == .contextMenu {
                AliasCompactView(alias: .sample,
                                 onCopy: {},
                                 onSendMail: {},
                                 onToggle: {},
                                 onPin: {},
                                 onUnpin: {},
                                 onDelete: {})
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color(.systemGray5), radius: 10, x: 0, y: 0)
        .sheet(isPresented: $showingSheet) {
            switch tip {
            case .fullScreen:
                AliasEmailView(email: "a-long-and-complicated-alias@my-domain.com")
            case .shareExtension:
                if let url = URL(string: "https://www.wikipedia.org/") {
                    ShareSheetView(activityItems: [url])
                } else {
                    EmptyView()
                }
            default:
                EmptyView()
            }
        }
    }

    private func handleAction() {
        switch tip {
        case .touchId, .faceId, .contextMenu:
            break
        case .fullScreen, .shareExtension:
            showingSheet = true
        case .keyboardExtension:
            UIApplication.shared.openSettings()
        }
    }
}

private extension Alias {
    static var sample: Alias {
        .init(id: 0,
              email: "my.alias@example.com",
              name: nil,
              enabled: true,
              creationTimestamp: Date().timeIntervalSince1970,
              blockCount: 15,
              forwardCount: 25,
              replyCount: 35,
              note: nil,
              pgpSupported: false,
              pgpDisabled: false,
              mailboxes: [],
              latestActivity: nil,
              pinned: true)
    }
}
