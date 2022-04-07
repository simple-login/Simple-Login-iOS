//
//  AboutView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SwiftUI

private let kVersionName =
    (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
private let kBuildNumber =
    (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"

struct AboutView: View {
    @State private var showingTipsView = false
    @State private var selectedUrlString: String?
    @State private var showingHowItWorksView = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How it works")) {
                    Image("Schema")
                        .resizable()
                        .scaledToFit()
                    NavigationLink(
                        isActive: $showingHowItWorksView,
                        destination: {
                            HowItWorksView()
                        },
                        label: {
                            Text("More detail")
                        })
                }

                Section {
                    systemImageLabel(title: "Terms and conditions",
                                     systemImageName: "doc.plaintext.fill",
                                     urlString: "https://simplelogin.io/terms/")

                    systemImageLabel(title: "Privacy policy",
                                     systemImageName: "hand.raised.fill",
                                     urlString: "https://simplelogin.io/privacy/")

                    systemImageLabel(title: "Security",
                                     systemImageName: "lock.shield",
                                     urlString: "https://simplelogin.io/security/")
                }

                Section {
                    systemImageLabel(title: "Website",
                                     systemImageName: "globe",
                                     urlString: "https://simplelogin.io/")

                    customImageLabel(title: "Github forum",
                                     imageName: "Github",
                                     urlString: "https://github.com/simple-login/app/discussions")
                }

                Section {
                    systemImageLabel(title: "Frequently asked questions",
                                     systemImageName: "person.fill.questionmark",
                                     urlString: "https://simplelogin.io/faq/")

                    systemImageLabel(title: "Blog",
                                     systemImageName: "newspaper.fill",
                                     urlString: "https://simplelogin.io/blog/")

                    systemImageLabel(title: "Our team",
                                     systemImageName: "person.3.fill",
                                     urlString: "https://simplelogin.io/about/")
                }

                Section(header: Text("Social networks")) {
                    customImageLabel(title: "Github",
                                     imageName: "Github",
                                     urlString: "https://github.com/simple-login/")

                    customImageLabel(title: "Twitter",
                                     imageName: "Twitter",
                                     urlString: "https://twitter.com/simple_login")

                    customImageLabel(title: "Reddit",
                                     imageName: "Reddit",
                                     urlString: "https://www.reddit.com/r/Simplelogin/")

                    customImageLabel(title: "Product Hunt",
                                     imageName: "ProductHunt",
                                     urlString: "https://www.producthunt.com/posts/simplelogin")
                }

                Section {
                    Button(action: openAppStore) {
                        Label("Rate & review on App Store", systemImage: "star.circle.fill")
                            .foregroundColor(Color(.label))
                    }

                    URLButton(urlString: "mailto:hi@simplelogin.io") {
                        Label("Email us", systemImage: "envelope.fill")
                    }
                }

                Section(footer: bottomFooterView) {}
            }
            .navigationTitle("About SimpleLogin")
            .navigationBarItems(trailing: tipsButton)
            .sheet(isPresented: $showingTipsView) {
                TipsView(isFirstTime: false)
            }
            .betterSafariView(urlString: $selectedUrlString)
            .onAppear {
                if UIDevice.current.userInterfaceIdiom != .phone {
                    showingHowItWorksView = true
                }
            }

            DetailPlaceholderView(systemIconName: "info.circle")
        }
        .slNavigationView()
    }

    private var bottomFooterView: some View {
        VStack {
            Text("Version \(kVersionName) (Build \(kBuildNumber))")
                .fontWeight(.medium)

            Spacer()

            Text("""
SimpleLogin is an open-source email alias solution to protect your email address.

SimpleLogin is the product of SimpleLogin SAS, registered in France under the SIREN number 884302134.
""")
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var tipsButton: some View {
        Button(action: {
            Vibration.soft.vibrate()
            showingTipsView = true
        }, label: {
            Label("Tips", systemImage: "lightbulb")
        })
    }

    private func systemImageLabel(title: String,
                                  systemImageName: String,
                                  urlString: String) -> some View {
        Label(title, systemImage: systemImageName)
            .accentColor(Color(.label))
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedUrlString = urlString
            }
    }

    private func customImageLabel(title: String,
                                  imageName: String,
                                  urlString: String) -> some View {
        Label(title: {
            Text(title)
        }, icon: {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        })
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedUrlString = urlString
            }
    }

    private func openAppStore() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1494359858?action=write-review") else { return }
        UIApplication.shared.open(writeReviewURL, options: [:])
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
