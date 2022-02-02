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
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("How it works")) {
                    Image("Schema")
                        .resizable()
                        .scaledToFit()
                }

                Section {
                    URLButton(urlString: "https://simplelogin.io/terms/") {
                        Label("Terms and condition", systemImage: "doc.plaintext.fill")
                    }

                    URLButton(urlString: "https://simplelogin.io/privacy/") {
                        Label("Privacy policy", systemImage: "hand.raised.fill")
                    }

                    URLButton(urlString: "https://simplelogin.io/security/") {
                        Label("Security", systemImage: "lock.shield")
                    }
                }

                Section {
                    URLButton(urlString: "https://simplelogin.io/") {
                        Label("Website", systemImage: "globe")
                    }

                    URLButton(urlString: "https://github.com/simple-login/app/discussions") {
                        Label {
                            Text("Github forum")
                        } icon: {
                            prefixIcon("Github")
                        }
                    }
                }

                Section {
                    URLButton(urlString: "https://simplelogin.io/faq/") {
                        Label("Frequently asked questions", systemImage: "person.fill.questionmark")
                    }

                    URLButton(urlString: "https://simplelogin.io/blog/") {
                        Label("Blog", systemImage: "newspaper.fill")
                    }

                    URLButton(urlString: "https://simplelogin.io/about/") {
                        Label("Our team", systemImage: "person.3.fill")
                    }
                }

                Section(header: Text("Social networks")) {
                    URLButton(urlString: "https://github.com/simple-login/") {
                        Label {
                            Text("Github")
                        } icon: {
                            prefixIcon("Github")
                        }
                    }

                    URLButton(urlString: "https://twitter.com/simple_login") {
                        Label {
                            Text("Twitter")
                        } icon: {
                            prefixIcon("Twitter")
                        }
                    }

                    URLButton(urlString: "https://www.reddit.com/r/Simplelogin/") {
                        Label {
                            Text("Reddit")
                        } icon: {
                            prefixIcon("Reddit")
                        }
                    }

                    URLButton(urlString: "https://www.producthunt.com/posts/simplelogin") {
                        Label {
                            Text("Product Hunt")
                        } icon: {
                            prefixIcon("ProductHunt")
                        }
                    }
                }

                Section(header: Text("Have a question?")) {
                    URLButton(urlString: "mailto:hi@simplelogin.io") {
                        Label("Email us", systemImage: "envelope.fill")
                    }
                }

                Section(footer: bottomFooterView) {}
            }
            .navigationTitle("About SimpleLogin")
            .navigationBarItems(trailing: tipsButton)
            .sheet(isPresented: $showingTipsView) {
                TipsView()
            }
        }
    }

    private func prefixIcon(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
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
            showingTipsView = true
        }, label: {
            Label("Tips", systemImage: "lightbulb")
        })
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
