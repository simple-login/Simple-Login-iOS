//
//  UpgradeView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/12/2021.
//

import AlertToast
import Combine
import SwiftUI

// swiftlint:disable let_var_whitespace
struct UpgradeView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = UpgradeViewModel()
    @State private var showingLoadingAlert = false

    var onSubscription: () -> Void

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        ScrollView {
            VStack(alignment: .leading) {
                freePlanSection
                premiumPlanSection
                yearlyButton
                    .padding(.top)
                monthlyButton
                    .padding(.vertical)
                restoreButton
                Text("Subscription can be managed and canceled at anytime by going to Settings ➝ Your Apple ID ➝ Subscriptions.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
                    .fixedSize(horizontal: false, vertical: true)
                termsAndPrivacyView
            }
            .padding()
        }
        .navigationBarTitle("Upgrade for more features", displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gradientBackground)
        .onAppear {
            viewModel.retrieveProductsInfo()
        }
        .onReceive(Just(viewModel.isSubscribed)) { isSubscribed in
            if isSubscribed {
                onSubscription()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
    }

    private var gradientBackground: some View {
        LinearGradient(gradient: .init(colors: [.slPurple.opacity(0.2),
                                                .slPurple.opacity(0.6)]),
                       startPoint: .top,
                       endPoint: .bottom)
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
    }

    @ViewBuilder
    private var freePlanSection: some View {
        Text("Your current free plan".uppercased())
            .font(.headline)
            .fontWeight(.medium)
            .padding(.horizontal)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        VStack(alignment: .leading, spacing: 6) {
            ForEach(kFreeCapacities) {
                capacityView($0, isPremium: false)
            }
        }
    }

    @ViewBuilder
    private var premiumPlanSection: some View {
        Text("Go premium for more".uppercased())
            .font(.title3)
            .fontWeight(.heavy)
            .padding([.horizontal, .top])
            .padding(.bottom, 4)
            .foregroundColor(.slPurple)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        VStack(alignment: .leading, spacing: 6) {
            ForEach(kPremiumCapacities) {
                capacityView($0, isPremium: true)
            }
            Text("...and all of our upcoming features.")
        }
    }

    @ViewBuilder
    private func capacityView(_ capacity: Capacity, isPremium: Bool) -> some View {
        Label {
            Text(capacity.description)
        } icon: {
            Image(systemName: "checkmark")
                .foregroundColor(isPremium ? .slPurple : .primary)
        }
        .fixedSize(horizontal: false, vertical: true)

        if let detail = capacity.detail {
            Label {
                Text(detail)
                    .font(.callout)
                    .foregroundColor(.secondary)
            } icon: {
                Image(systemName: "circle")
                    .opacity(0)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var yearlyButton: some View {
        VStack(alignment: .leading) {
            Button(action: {
                viewModel.subscribeYearly(session: session)
            }, label: {
                if let yearlySubscription = viewModel.yearlySubscription {
                    Text("Subscribe yearly \(yearlySubscription.localizedPrice)/year")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    ProgressView()
                }
            })
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.slPurple)
                .disabled(viewModel.yearlySubscription == nil)

            Text("Save 2 months by subcribing yearly.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var monthlyButton: some View {
        VStack(alignment: .leading) {
            Button(action: {
                viewModel.subscribeMonthly(session: session)
            }, label: {
                if let monthlySubscription = viewModel.monthlySubscription {
                    Text("Subscribe monthly \(monthlySubscription.localizedPrice)/month")
                        .fontWeight(.bold)
                        .foregroundColor(.slPurple)
                } else {
                    ProgressView()
                }
            })
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.slPurple, width: 2)
                .disabled(viewModel.monthlySubscription == nil)

            Text("A cup of ☕ per month to improve your privacy.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var restoreButton: some View {
        Button(action: {
            viewModel.restorePurchase(session: session)
        }, label: {
            Text("Restore purchase")
                .fontWeight(.bold)
                .foregroundColor(.slPurple)
        })
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .border(Color.slPurple, width: 2)
    }

    private var termsAndPrivacyView: some View {
        HStack {
            Text("SimpleLogin")
                .foregroundColor(.secondary)

            Button(action: {
                if let url = URL(string: "https://simplelogin.io/terms/") {
                    UIApplication.shared.open(url, options: [:])
                }
            }, label: {
                Text("Terms of Use")
                    .fontWeight(.semibold)
                    .foregroundColor(.slPurple)
            })

            Text("&")
                .foregroundColor(.secondary)

            Button(action: {
                if let url = URL(string: "https://simplelogin.io/privacy/") {
                    UIApplication.shared.open(url, options: [:])
                }
            }, label: {
                Text("Privacy policy")
                    .fontWeight(.semibold)
                    .foregroundColor(.slPurple)
            })
        }
        .font(.callout)
    }
}

struct UpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpgradeView { }
        }
    }
}

private struct Capacity: Identifiable {
    let id = UUID()
    let description: String
    var detail: String?
}

private let kFreeCapacities: [Capacity] = [
    .init(description: "15 aliases"),
    .init(description: "Unlimited bandwidth"),
    .init(description: "Unlimited reply/send from alias"),
    .init(description: "1 mailbox"),
    .init(description: "Browser extensions", detail: "Chrome, Firefox and Safari"),
    .init(description: "iOS & Android applications"),
    .init(description: "Secure your account with TOTP and/or WebAuthn (FIDO)"),
    .init(description: "Sign in with SimpleLogin")
]

private let kPremiumCapacities: [Capacity] = [
    .init(description: "Everything in the Free Plan"),
    .init(description: "Unlimited aliases"),
    .init(description: "Unlimited custom domains",
          detail: "Bring your own domain to create aliases like contact@your-domain.com"),
    .init(description: "Catch-all (or wildcard) domain"),
    .init(description: "5 subdomains"),
    .init(description: "50 directories/usernames"),
    .init(description: "Unlimited mailboxes"),
    .init(description: "PGP encryption")
]
