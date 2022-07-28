//
//  LogInWithProtonButtonView.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 27/07/2022.
//

import AuthenticationServices
import SimpleLoginPackage
import SwiftUI

struct LogInWithProtonButtonView: View {
    @EnvironmentObject private var preferences: Preferences
    @State private var isShowingSafariView = false
    @State private var selectedUrlString: String?
    let onSuccess: (ApiKey) -> Void
    let onError: (Error) -> Void

    var body: some View {
        Button(action: {
            isShowingSafariView = true
            selectedUrlString = "\(preferences.apiUrl)/auth/proton/login?mode=apikey"
        }, label: {
            ZStack {
                HStack {
                    Image("Proton")
                    Spacer()
                }
                Text("Log in with Proton")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.proton)
            }
            .padding()
            .contentShape(Rectangle())
        })
        .buttonStyle(.proton)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.proton, lineWidth: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .webAuthenticationSession(isPresented: $isShowingSafariView) {
            // swiftlint:disable:next force_unwrapping
            let url = URL(string: "\(preferences.apiUrl)/auth/proton/login?mode=apikey")!
            return .init(url: url, callbackURLScheme: "auth.simplelogin", onCompletion: handleResult)
        }
    }

    private func handleResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
            if let apiQueryItem = components.queryItems?.first(where: { $0.name == "apikey" }),
               let apiKeyValue = apiQueryItem.value {
                let apiKey = ApiKey(value: apiKeyValue)
                onSuccess(apiKey)
            }

        case .failure(let error):
            if let webAuthenticationSessionError = error as? ASWebAuthenticationSessionError {
                // User clicks on cancel button => do not handle this "error"
                if case ASWebAuthenticationSessionError.canceledLogin = webAuthenticationSessionError {
                    return
                }
            }
            onError(error)
        }
    }
}
