//
//  LoadableToastableViewModifier.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 29/08/2021.
//

import SwiftUI

struct LoadableToastableViewModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @State private var loadingMode = LoadingMode(isLoading: false)
    @State private var toastMessage: String? = nil
    private let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()

    func body(content: Content) -> some View {
        ZStack {
            content

            if loadingMode.isLoading {
                Group {
                    Color.gray
                        .opacity(0.2)
                        .ignoresSafeArea()

                    let progressViewBackgroundColor = colorScheme == .light ?
                        Color.white : Color(.systemGray6)
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(32)
                        .background(progressViewBackgroundColor
                                        .clipShape(RoundedRectangle(cornerRadius: 8)))
                }
                .animation(.default)
                .transition(.opacity)
            }

            if let toastMessage = toastMessage {
                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity)

                    let toastBackgroundColor = colorScheme == .light ?
                        Color.black : Color(.systemGray6)
                    Text(toastMessage)
                        .font(.caption)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(6)
                        .background(toastBackgroundColor
                                        .clipShape(RoundedRectangle(cornerRadius: 4)))
                }
                .padding(.horizontal)
                .padding(.bottom, 44)
                .transition(.opacity.animation(.linear(duration: 0.15)))
            }
        }
        .onReceive(timer) { _ in toastMessage = nil }
        .environment(\.loadingMode, $loadingMode)
        .environment(\.toastMessage, $toastMessage)
    }
}

extension View {
    func loadableToastable() -> some View {
        modifier(LoadableToastableViewModifier())
    }
}

// MARK: - Loadable
struct LoadingMode {
    var isLoading: Bool

    mutating func startLoading() {
        isLoading = true
    }

    mutating func stopLoading() {
        isLoading = false
    }
}

struct LoadingModeKey: EnvironmentKey {
    static let defaultValue: Binding<LoadingMode> = .constant(.init(isLoading: false))
}

extension EnvironmentValues {
    var loadingMode: Binding<LoadingMode> {
        get { self[LoadingModeKey.self] }
        set { self[LoadingModeKey.self] = newValue }
    }
}

// MARK: - Toastable
struct ToastMessageKey: EnvironmentKey {
    static let defaultValue: Binding<String?> = .constant(nil)
}

extension EnvironmentValues {
    var toastMessage: Binding<String?> {
        get { self[ToastMessageKey.self] }
        set { self[ToastMessageKey.self] = newValue }
    }
}
