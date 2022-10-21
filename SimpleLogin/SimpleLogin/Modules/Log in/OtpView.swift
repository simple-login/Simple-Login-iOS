//
//  OtpView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import AlertToast
import Combine
import SimpleLoginPackage
import SwiftUI

struct OtpView: View {
    @StateObject private var viewModel: OtpViewModel
    @State private var showingLoadingHud = false
    @State private var showingReactivateAlert = false
    @Binding var mode: OtpMode?
    let onVerification: ((ApiKey) -> Void)?
    let onActivation: (() async -> Void)?

    init(mode: Binding<OtpMode?>,
         apiService: APIServiceProtocol,
         onVerification: ((ApiKey) -> Void)? = nil,
         onActivation: (() async -> Void)? = nil) {
        self._mode = mode
        let viewModel = OtpViewModel(apiService: apiService,
                                     mode: mode.wrappedValue ?? .logIn(mfaKey: ""))
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onVerification = onVerification
        self.onActivation = onActivation
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                if let description = viewModel.mode.description {
                    Text(description)
                        .font(.callout)
                        .foregroundColor(Color(.darkGray))
                        .multilineTextAlignment(.center)
                        .padding([.top, .horizontal])
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 18) {
                    Group {
                        Spacer()
                        Text(viewModel.firstDigit.rawValue)
                        Text(viewModel.secondDigit.rawValue)
                        Text(viewModel.thirdDigit.rawValue)
                        Text(viewModel.fourthDigit.rawValue)
                        Text(viewModel.fifthDigit.rawValue)
                        Text(viewModel.sixthDigit.rawValue)
                        Spacer()
                    }
                    .font(.largeTitle)
                    .frame(minWidth: 24)
                }
                .padding(.top)

                Group {
                    if let error = viewModel.error {
                        Text(error.safeLocalizedDescription)
                            .foregroundColor(.red)
                            .modifier(ShakeEffect(animatableData: viewModel.attempts))
                            .animation(.default, value: viewModel.attempts)
                            .transition(.opacity)
                    } else {
                        Text("Dummy text")
                            .opacity(0)
                    }
                }
                .padding()
                .font(.headline)

                HStack {
                    OtpButton(action: {
                        viewModel.add(digit: .one)
                    }, label: {
                        Text("1")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .two)
                    }, label: {
                        Text("2")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .three)
                    }, label: {
                        Text("3")
                    })
                }

                HStack {
                    OtpButton(action: {
                        viewModel.add(digit: .four)
                    }, label: {
                        Text("4")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .five)
                    }, label: {
                        Text("5")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .six)
                    }, label: {
                        Text("6")
                    })
                }

                HStack {
                    OtpButton(action: {
                        viewModel.add(digit: .seven)
                    }, label: {
                        Text("7")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .eighth)
                    }, label: {
                        Text("8")
                    })

                    OtpButton(action: {
                        viewModel.add(digit: .nine)
                    }, label: {
                        Text("9")
                    })
                }

                HStack {
                    OtpButton(action: {}, label: { EmptyView() })
                        .opacity(0)

                    OtpButton(action: {
                        viewModel.add(digit: .zero)
                    }, label: {
                        Text("0")
                    })

                    OtpButton(action: {
                        viewModel.delete()
                    }, label: {
                        Image(systemName: "delete.left.fill")
                    })
                }

                Button(action: {
                    viewModel.paste(string: UIPasteboard.general.string)
                }, label: {
                    Label("Paste from clipboard", systemImage: "doc.on.clipboard")
                })
                    .padding()

                Spacer()
            }
            .navigationBarTitle(viewModel.mode.title, displayMode: .inline)
            .navigationBarItems(leading: closeButton)
        }
        .accentColor(.slPurple)
        .toast(isPresenting: $showingLoadingHud) {
            AlertToast(type: .loading)
        }
        .alert(isPresented: $showingReactivateAlert) { reactivateAlert }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingHud = isLoading
        }
        .onReceive(Just(viewModel.apiKey)) { apiKey in
            if let apiKey = apiKey {
                onVerification?(apiKey)
            }
        }
        .onReceive(Just(viewModel.shouldReactivate)) { shouldReactivate in
            if shouldReactivate {
                showingReactivateAlert = true
            }
        }
        .onReceive(Just(viewModel.activationSuccessful)) { activationSuccessful in
            if activationSuccessful {
                Task {
                    await onActivation?()
                }
                mode = nil
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            mode = nil
        }, label: {
            Text("Close")
        })
    }

    private var reactivateAlert: Alert {
        Alert(title: Text("Wrong code too many times"),
              message: Text("The last activation code is disabled. You need to request a new one."),
              dismissButton: .default(Text("Send me a new code")) { viewModel.reactivate() })
    }
}

/*
struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView(mode: .constant(.activate(email: "john.doe@example.com")),
                client: .default)
    }
}
 */

struct OtpButton<Label: View>: View {
    let action: () -> Void
    let label: () -> Label

    init(action: @escaping () -> Void,
         @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(.otp)
    }
}

private struct OtpButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let width = min(120, UIScreen.main.minLength / 4)
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGray6))
            configuration.label
                .font(.largeTitle)
        }
        .opacity(configuration.isPressed ? 0.5 : 1)
        .frame(width: width, height: width)
    }
}

private extension ButtonStyle where Self == OtpButtonStyle {
    static var otp: OtpButtonStyle {
        OtpButtonStyle()
    }
}

enum OtpMode {
    case logIn(mfaKey: String)
    case activate(email: String)

    var title: String {
        switch self {
        case .logIn:
            return "Enter OTP code"
        case .activate:
            return "Enter activation code"
        }
    }

    var description: String? {
        switch self {
        case .logIn:
            return nil
        case .activate(let email):
            return "Please enter the activation code that we've sent to \(email)"
        }
    }
}

private final class OtpViewModel: ObservableObject {
    enum Digit: String {
        case none = "-"
        case zero = "0"
        case one = "1"
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eighth = "8"
        case nine = "9"
    }

    @Published private(set) var firstDigit = Digit.none
    @Published private(set) var secondDigit = Digit.none
    @Published private(set) var thirdDigit = Digit.none
    @Published private(set) var fourthDigit = Digit.none
    @Published private(set) var fifthDigit = Digit.none
    @Published private(set) var sixthDigit = Digit.none
    @Published private(set) var error: Error?
    @Published private(set) var attempts: CGFloat = 0
    @Published private(set) var isLoading = false
    @Published private(set) var apiKey: ApiKey?
    @Published private(set) var shouldReactivate = false
    @Published private(set) var activationSuccessful = false

    let mode: OtpMode
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol, mode: OtpMode) {
        self.mode = mode
        self.apiService = apiService
    }

    func delete() {
        if sixthDigit != .none {
            sixthDigit = .none
        } else if fifthDigit != .none {
            fifthDigit = .none
        } else if fourthDigit != .none {
            fourthDigit = .none
        } else if thirdDigit != .none {
            thirdDigit = .none
        } else if secondDigit != .none {
            secondDigit = .none
        } else if firstDigit != .none {
            firstDigit = .none
        }
        error = nil
    }

    func add(digit: Digit) {
        error = nil
        if firstDigit == .none {
            firstDigit = digit
        } else if secondDigit == .none {
            secondDigit = digit
        } else if thirdDigit == .none {
            thirdDigit = digit
        } else if fourthDigit == .none {
            fourthDigit = digit
        } else if fifthDigit == .none {
            fifthDigit = digit
        } else if sixthDigit == .none {
            sixthDigit = digit
            verify()
        }
    }

    func paste(string: String?) {
        guard let string = string else {
            error = SLError.emptyClipboard
            return
        }
        guard string.count == 6 else {
            error = SLError.invalidValidationCodeSyntax
            return
        }
        let getDigit: (String?) -> Digit = { digitString in
            switch digitString {
            case "0": return .zero
            case "1": return .one
            case "2": return .two
            case "3": return .three
            case "4": return .four
            case "5": return .five
            case "6": return .six
            case "7": return .seven
            case "8": return .eighth
            case "9": return .nine
            default: return .none
            }
        }
        add(digit: getDigit(string[0]))
        add(digit: getDigit(string[1]))
        add(digit: getDigit(string[2]))
        add(digit: getDigit(string[3]))
        add(digit: getDigit(string[4]))
        add(digit: getDigit(string[5]))
    }

    private func verify() {
        defer { self.isLoading = false }
        isLoading = true
        let token =
            [firstDigit, secondDigit, thirdDigit, fourthDigit, fifthDigit, sixthDigit]
            .map { $0.rawValue }
            .reduce(into: "") { $0 += "\($1)" }

        switch mode {
        case .logIn(let mfaKey):
            Task { @MainActor in
                do {
                    let mfaEndpoint = MFAEndpoint(token: token, key: mfaKey, device: UIDevice.current.name)
                    apiKey = try await apiService.execute(mfaEndpoint)
                } catch {
                    Vibration.error.vibrate(fallBackToOldSchool: true)
                    self.error = error
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.attempts += 1
                    }
                    self.reset()
                }
            }

        case .activate(let email):
            Task { @MainActor in
                do {
                    let activateEndpoint = ActivateEndpoint(email: email, code: token)
                    _ = try await apiService.execute(activateEndpoint)
                    self.activationSuccessful = true
                } catch {
                    Vibration.error.vibrate(fallBackToOldSchool: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.attempts += 1
                    }
                    self.reset()
                    if let apiServiceError = error as? APIServiceError,
                       case .clientError(let errorResponse) = apiServiceError,
                       errorResponse.statusCode == 410 {
                        self.shouldReactivate = true
                    } else {
                        self.error = error
                    }
                }
            }
        }
    }

    private func reset() {
        firstDigit = .none
        secondDigit = .none
        thirdDigit = .none
        fourthDigit = .none
        fifthDigit = .none
        sixthDigit = .none
    }

    func reactivate() {
        guard case .activate(let email) = mode else { return }
        Task { @MainActor in
            do {
                let reactivateEndpoint = ReactivateEndpoint(email: email)
                _ = try await apiService.execute(reactivateEndpoint)
            } catch {
                self.error = error
            }
        }
    }
}
