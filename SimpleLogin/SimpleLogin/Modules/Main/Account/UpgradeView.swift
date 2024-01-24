//
//  UpgradeView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/12/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct UpgradeView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: UpgradeViewModel
    @State private var showingLoadingAlert = false
    @State private var showingThankAlert = false
    @State private var selectedUrlString: String?

    var onSubscription: () -> Void

    init(session: Session, onSubscription: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.onSubscription = onSubscription
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                freePlanSection
                premiumPlanSection
                yearlyButton
                    .padding(.top)
                monthlyButton
                    .padding(.vertical)
                SecondaryButton(title: "Restore purchasse") {
                    viewModel.restorePurchase()
                }
                // swiftlint:disable:next line_length
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
            showingThankAlert = isSubscribed
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
        .betterSafariView(urlString: $selectedUrlString)
        .alert(isPresented: $showingThankAlert) {
            Alert(
                title: Text("Thank you"),
                message: Text("You are now a premium user 🎉"),
                dismissButton: .default(Text("Got it 👍")) {
                    onSubscription()
                    presentationMode.wrappedValue.dismiss()
                })
        }
    }

    private var gradientBackground: some View {
        LinearGradient(gradient: .init(colors: [.slPurple.opacity(0.05),
                                                .slPurple.opacity(0.1),
                                                .slPurple.opacity(0.15),
                                                .slPurple.opacity(0.2)]),
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
                CapacityView(capacity: $0, checkmarkColor: nil)
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
                CapacityView(capacity: $0, checkmarkColor: .slPurple)
            }
            Text("...and all of our upcoming features.")
        }
    }

    private var yearlyButton: some View {
        VStack(alignment: .leading) {
            if let yearlySubscription = viewModel.yearlySubscription {
                PrimaryButton(title: "Subscribe yearly \(yearlySubscription.localizedPrice)/year") {
                    viewModel.subscribeYearly()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text("Save 2 months by subscribing yearly.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var monthlyButton: some View {
        VStack(alignment: .leading) {
            if let monthlySubscription = viewModel.monthlySubscription {
                SecondaryButton(title: "Subscribe monthly \(monthlySubscription.localizedPrice)/month") {
                    viewModel.subscribeMonthly()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text("A cup of ☕ per month to improve your privacy.")
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var termsAndPrivacyView: some View {
        HStack {
            Button(action: {
                selectedUrlString = "https://simplelogin.io/terms/"
            }, label: {
                Text("Terms and condition")
                    .fontWeight(.semibold)
                    .foregroundColor(.slPurple)
            })

            Text("•")
                .foregroundColor(.secondary)

            Button(action: {
                selectedUrlString = "https://simplelogin.io/privacy/"
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
            UpgradeView(session: .preview) {}
        }
    }
}

private let kFreeCapacities: [Capacity] = [
    .fifteenAliases,
    .unlimitedBandWidth,
    .oneMailbox,
    .browserExtensions,
    .totp,
    .signWithSimpleLogin
]

private let kPremiumCapacities: [Capacity] = [
    .everythingInFreePlan,
    .unlimitedAliases,
    .unlimitedReplySend,
    .unlimitedMailboxes,
    .unlimitedDomains,
    .catchAllDomain,
    .fiveSubdomains,
    .fiftyDirectories,
    .pgp
]
