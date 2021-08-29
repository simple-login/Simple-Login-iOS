//
//  OtpView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 28/08/2021.
//

import SwiftUI

struct OtpView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = OtpViewModel()

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
                    }) {
                        Text("1")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .two)
                    }) {
                        Text("2")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .three)
                    }) {
                        Text("3")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    CircleButton(action: {
                        viewModel.add(digit: .four)
                    }) {
                        Text("4")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .five)
                    }) {
                        Text("5")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .six)
                    }) {
                        Text("6")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    CircleButton(action: {
                        viewModel.add(digit: .seven)
                    }) {
                        Text("7")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .eighth)
                    }) {
                        Text("8")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .nine)
                    }) {
                        Text("9")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                HStack {
                    Color.clear
                        .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.add(digit: .zero)
                    }) {
                        Text("0")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)

                    CircleButton(action: {
                        viewModel.delete()
                    }) {
                        Image(systemName: "delete.left.fill")
                    }
                    .frame(width: buttonWidth, height: buttonWidth)
                }

                Spacer()
            }
            .navigationBarTitle("Enter OTP", displayMode: .inline)
            .navigationBarItems(leading: closeButton)
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
        OtpView()
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
            errorMessage = "Wrong OTP token"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.attempts += 1
            }
        }
    }
}
