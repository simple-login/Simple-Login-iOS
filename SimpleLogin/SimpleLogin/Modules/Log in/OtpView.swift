//
//  OtpView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct OtpView: View {
    @Environment(\.loadingMode) private var loadingMode
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: OtpViewModel
    let onVerification: (ApiKey) -> Void

    init(mfaKey: String,
         client: SLClient,
         onVerification: @escaping (ApiKey) -> Void) {
        self._viewModel = StateObject(wrappedValue: .init(mfaKey: mfaKey,
                                                          client: client))
        self.onVerification = onVerification
    }

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

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
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .modifier(ShakeEffect(animatableData: viewModel.attempts))
                            .animation(.default)
                            .transition(.opacity)
                    } else {
                        Text("Dummy text")
                            .opacity(0)
                    }
                }
                .padding()
                .font(.title)

                let buttonWidth = min(UIScreen.main.bounds.width / 4, 120)

                HStack {
                    CircleButton(action: {
                        viewModel.add(digit: .one)
                    }, content: {
                        Text("1")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .two)
                    }, content: {
                        Text("2")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .three)
                    }, content: {
                        Text("3")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    CircleButton(action: {
                        viewModel.add(digit: .four)
                    }, content: {
                        Text("4")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .five)
                    }, content: {
                        Text("5")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .six)
                    }, content: {
                        Text("6")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    CircleButton(action: {
                        viewModel.add(digit: .seven)
                    }, content: {
                        Text("7")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .eighth)
                    }, content: {
                        Text("8")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .nine)
                    }, content: {
                        Text("9")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    Color.clear
                        .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .zero)
                    }, content: {
                        Text("0")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.delete()
                    }, content: {
                        Image(systemName: "delete.left.fill")
                    })
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                Spacer()
            }
            .navigationBarTitle("Enter OTP", displayMode: .inline)
            .navigationBarItems(leading: closeButton)
        }
        .accentColor(.slPurple)
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            if isLoading {
                loadingMode.wrappedValue.startLoading()
            } else {
                loadingMode.wrappedValue.stopLoading()
            }
        }
        .onReceive(Just(viewModel.apiKey)) { apiKey in
            if let apiKey = apiKey {
                onVerification(apiKey)
            }
        }
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

struct OtpView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next force_unwrapping
        OtpView(mfaKey: "", client: .init(session: .shared)!) { _ in }
    }
}

struct CircleButton<Content: View>: View {
    let action: () -> Void
    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(.systemGroupedBackground))
            content
                .font(.largeTitle)
        }
        .onTapGesture {
            action()
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
    @Published private(set) var errorMessage: String?
    @Published private(set) var attempts: CGFloat = 0
    @Published private(set) var isLoading = false
    @Published private(set) var apiKey: ApiKey?

    private let mfaKey: String
    private let client: SLClient
    private var cancellable: AnyCancellable?

    init(mfaKey: String, client: SLClient) {
        self.mfaKey = mfaKey
        self.client = client
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
        errorMessage = nil
    }

    func add(digit: Digit) {
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

    private func verify() {
        guard !isLoading else { return }
        isLoading = true
        let token =
            [firstDigit, secondDigit, thirdDigit, fourthDigit, fifthDigit, sixthDigit]
            .map { $0.rawValue }
            .reduce(into: "") { $0 += "\($1)" }
        cancellable = client.mfa(token: token, key: mfaKey, device: UIDevice.current.name)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                defer { self.isLoading = false }
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.description
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.attempts += 1
                    }
                    self.reset()
                case .finished: break
                }
            } receiveValue: { [weak self] apiKey in
                guard let self = self else { return }
                self.apiKey = apiKey
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
}
