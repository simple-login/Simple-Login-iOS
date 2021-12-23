//
//  AliasContactsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasContactsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel: AliasContactsViewModel
    @State private var showingHelperText = false

    init(alias: Alias) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias))
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                if let contacts = viewModel.contacts {
                    ForEach(contacts, id: \.id) { contact in
                        ContactView(contact: contact)
                            .padding(.horizontal, 4)
                    }
                }

                if viewModel.isLoadingContacts {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical, 8)
        }
        .navigationBarTitle(viewModel.contacts?.isEmpty == false ? viewModel.alias.email : "",
                            displayMode: viewModel.contacts?.isEmpty == false ? .large : .automatic)
        .navigationBarItems(trailing: plusButton)
        .onAppear {
            viewModel.getMoreContactsIfNeed(session: session,
                                            currentContact: nil)
        }
        .emptyPlaceholder(isEmpty: viewModel.contacts?.isEmpty == true) {
            noContactView
                .navigationBarItems(trailing: plusButton)
        }
    }

    var plusButton: some View {
        Button(action: {
            print("add")
        }, label: {
            Image(systemName: "plus")
        })
            .frame(minWidth: 24, minHeight: 24)
    }

    var noContactView: some View {
        ZStack(alignment: .topTrailing) {
            if showingHelperText {
                HStack {
                    Spacer()
                    Text("Add contact")
                    Image(systemName: "arrow.turn.right.up")
                }
                .padding()
                .foregroundColor(.secondary)
            }

            ZStack {
                Image(systemName: "at")
                    .resizable()
                    .padding()
                    .scaledToFit()
                    .foregroundColor(.slPurple)
                    .opacity(0.03)
                Text(viewModel.alias.email)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showingHelperText = true
                }
            }
        }
    }
}

private struct ContactView: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 0) {
            Color(contact.blockForward ? (.darkGray) : .slPurple)
                .frame(width: 4)

            VStack(spacing: 8) {
                VStack(alignment: .leading) {
                    Text(contact.email)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: false)
                    Text("\(contact.creationDateString) (\(contact.relativeCreationDateString))")
                        .fixedSize(horizontal: false, vertical: false)
                }
            }
            .padding(8)

            Spacer()

            if contact.blockForward {
                Text("⛔")
                    .font(.title)
                    .padding(.trailing)
            }
        }
        .background(contact.blockForward ? Color(.darkGray).opacity(0.05) : Color.slPurple.opacity(0.05))
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
