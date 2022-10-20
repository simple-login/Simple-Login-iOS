//
//  CustomDomainsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 12/01/2022.
//

import SimpleLoginPackage
import SwiftUI

struct CustomDomainsView: View {
    @StateObject private var viewModel: CustomDomainsViewModel
    @State private var selectedUnverifiedDomain: CustomDomain?

    init(session: Session) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
    }

    var body: some View {
        let showingUnverifiedDomainAlert = Binding<Bool>(get: {
            selectedUnverifiedDomain != nil
        }, set: { isShowing in
            if !isShowing {
                selectedUnverifiedDomain = nil
            }
        })

        List {
            Section(content: {
                ForEach(viewModel.domains, id: \.id) { domain in
                    domainView(for: domain)
                }
            }, footer: {
                Text("To add new domains, please use our web application.")
            })
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Custom domains")
        .emptyPlaceholder(isEmpty: viewModel.noDomains) {
            DetailPlaceholderView(systemIconName: "globe",
                                  // swiftlint:disable:next line_length
                                  message: "You currently don't have any custom domains. You can only add custom domains using our web app.")
                .padding(.horizontal)
        }
        .task { await viewModel.refresh(force: false) }
        .refreshable { await viewModel.refresh(force: true) }
        .alert(isPresented: showingUnverifiedDomainAlert) {
            unverifiedDomainAlert
        }
        .alertToastLoading(isPresenting: $viewModel.isLoading)
        .alertToastError($viewModel.error)
    }

    @ViewBuilder
    private func domainView(for domain: CustomDomain) -> some View {
        if domain.verified {
            NavigationLink(destination: {
                DomainDetailView(domain: domain,
                                 session: viewModel.session)
            }, label: {
                DomainView(domain: domain)
            })
        } else {
            DomainView(domain: domain)
                .onTapGesture { selectedUnverifiedDomain = domain }
        }
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
            VStack(alignment: .leading, spacing: 6) {
                Text(domain.domainName)
                    .fontWeight(.semibold)
                    .foregroundColor(domain.verified ? .primary : .secondary)
                Text("\(domain.relativeCreationDateString) • \(domain.aliasCount) alias(es)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if !domain.verified {
                BorderedText.unverified
            }
        }
        .contentShape(Rectangle())
    }
}

/*
struct CustomDomainsView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            DomainView(domain: .verified)
            DomainView(domain: .unverified)
        }
    }
}
*/
