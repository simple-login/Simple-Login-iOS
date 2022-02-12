//
//  CustomDomainsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import Combine
import Introspect
import SimpleLoginPackage
import SwiftUI

struct CustomDomainsView: View {
    @StateObject private var viewModel: CustomDomainsViewModel
    @State private var showingLoadingAlert = false
    @State private var selectedUnverifiedDomain: CustomDomain?

    init(session: Session) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
    }

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        let showingUnverifiedDomainAlert = Binding<Bool>(get: {
            selectedUnverifiedDomain != nil
        }, set: { isShowing in
            if !isShowing {
                selectedUnverifiedDomain = nil
            }
        })

        List {
            ForEach(viewModel.domains, id: \.id) { domain in
                if domain.verified {
                    NavigationLink(destination: {
                        DomainDetailView(domain: domain,
                                         session: viewModel.session)
                    }, label: {
                        DomainView(domain: domain)
                    })
                } else {
                    DomainView(domain: domain)
                        .onTapGesture {
                            selectedUnverifiedDomain = domain
                        }
                }
            }
        }
        .introspectTableView { tableView in
            tableView.refreshControl = viewModel.refreshControl
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Custom domains")
        .emptyPlaceholder(isEmpty: viewModel.noDomain) {
            noDomainView
        }
        .onAppear {
            viewModel.fetchCustomDomains(refreshing: false)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .alert(isPresented: showingUnverifiedDomainAlert) {
            unverifiedDomainAlert
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
    }

    var noDomainView: some View {
        ZStack {
            Image(systemName: "globe")
                .resizable()
                .padding()
                .scaledToFit()
                .foregroundColor(.slPurple)
                .opacity(0.03)
            Text("You currently don't have any custom domain. You can only add custom domains using our web app.")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var unverifiedDomainAlert: Alert {
        guard let selectedUnverifiedDomain = selectedUnverifiedDomain else {
            return .init(title: Text("selectedUnverifiedDomain is nil"),
                         message: nil,
                         dismissButton: .cancel())
        }
        return .init(title: Text("\(selectedUnverifiedDomain.domainName) is not verified"),
                     message: Text("You can only verify this domain in our web app"),
                     dismissButton: .default(Text("OK")))
    }
}

private struct DomainView: View {
    let domain: CustomDomain

    var body: some View {
        HStack {
            Image(systemName: domain.verified ? "checkmark.seal.fill" : "checkmark.seal")
                .resizable()
                .scaledToFit()
                .foregroundColor(domain.verified ? .green : .gray)
                .frame(width: 20, height: 20, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                Text(domain.domainName)
                    .fontWeight(.semibold)
                Text("\(domain.relativeCreationDateString) • \(domain.aliasCount) alias(es)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !domain.verified {
                Text("Unverified")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.red, lineWidth: 1))
            }
        }
        .contentShape(Rectangle())
    }
}

struct CustomDomainsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DomainView(domain: .verified)
            DomainView(domain: .unverified)
        }
    }
}
