//
//  CreateAliasView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var session: Session
    @StateObject private var viewModel = CreateAliasViewModel()
    @State private var showingLoadingAlert = false

    let onCreateAlias: (Alias) -> Void

    var body: some View {
        let showingErrorAlert = Binding<Bool>(get: {
            viewModel.error != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledError()
            }
        })

        NavigationView {
            Group {
                if let options = viewModel.options {
                    ContentView(options: options) { aliasCreationOptions in
                        viewModel.createAlias(session: session,
                                              aliasCreationOptions: aliasCreationOptions)
                    }
                } else if !viewModel.isLoading {
                    Button(action: {
                        viewModel.fetchOptions(session: session)
                    }, label: {
                        Label("Retry", systemImage: "gobackward")
                    })
                }
            }
            .navigationBarTitle("Create an alias", displayMode: .inline)
            .navigationBarItems(leading: cancelButton)
        }
        .accentColor(.slPurple)
        .onAppear {
            viewModel.fetchOptions(session: session)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdAlias)) { createdAlias in
            if let createdAlias = createdAlias {
                onCreateAlias(createdAlias)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .toast(isPresenting: $showingLoadingAlert) {
            AlertToast(type: .loading)
        }
        .toast(isPresenting: showingErrorAlert) {
            AlertToast.errorAlert(message: viewModel.error?.description)
        }
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        })
    }
}

private struct ContentView: View {
    let options: AliasOptions
    let onCreate: (AliasCreationOptions) -> Void

    var body: some View {
        Text("Content view")
    }
}
