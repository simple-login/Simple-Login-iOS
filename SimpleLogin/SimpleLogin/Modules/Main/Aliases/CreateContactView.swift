//
//  CreateContactView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 25/12/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateContactView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CreateContactViewModel
    @State private var contactEmail: String = ""
    @State private var showingLoadingAlert = false
    private var onCreateContact: () -> Void

    init(alias: Alias, session: Session, onCreateContact: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
        self.onCreateContact = onCreateContact
    }

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            Form {
                Section(header: Text("New contact")) {
                    TextField("Email address", text: $contactEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle(viewModel.alias.email)
            .navigationBarItems(leading: cancelButton, trailing: createButton)
        }
        .onReceive(Just(viewModel.createdContact)) { createdContact in
            if createdContact != nil {
                onCreateContact()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError(isPresenting: showingErrorAlert, error: viewModel.error)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }

    private var createButton: some View {
        Button(action: {
            viewModel.createContact(contactEmail: contactEmail)
        }, label: {
            Text("Create")
        })
            .disabled(!contactEmail.isValidEmail)
    }
}

final class CreateContactViewModel: BaseSessionViewModel, ObservableObject {
    deinit {
        print("\(Self.self) is deallocated")
    }

    let alias: Alias

    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var createdContact: Contact?
    private var cancellables = Set<AnyCancellable>()

    init(alias: Alias, session: Session) {
        self.alias = alias
        super.init(session: session)
    }

    func handledError() {
        self.error = nil
    }

    func createContact(contactEmail: String) {
        guard !isLoading else { return }
        isLoading = true
        session.client.createContact(apiKey: session.apiKey, aliasId: alias.id, contactEmail: contactEmail)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error
                }
            } receiveValue: { [weak self] createdContact in
                guard let self = self else { return }
                if createdContact.existed {
                    self.error = SLError.contactExists
                } else {
                    self.createdContact = createdContact
                }
            }
            .store(in: &cancellables)
    }
}
