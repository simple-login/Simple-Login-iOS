//
//  AliasEmailView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 23/04/2022.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

/// Alias full screen
struct AliasEmailView: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var mode: Mode = .text
    @State private var originalBrightness: CGFloat = 0.5
    @State private var percentage: Double = 0.5
    let email: String

    enum Mode {
        case text, qr

        var systemImageName: String {
            switch self {
            case .text: return "textformat.abc"
            case .qr: return "qrcode"
            }
        }

        var oppositeMode: Mode {
            switch self {
            case .text: return .qr
            case .qr: return .text
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                switch mode {
                case .text:
                    AliasEmailTextView(originalBrightness: $originalBrightness,
                                       percentage: $percentage,
                                       email: email)
                case .qr:
                    AliasEmailQrView(email: email)
                }
            }
            .accentColor(.slPurple)
            .padding()
            .toolbar { toolbarContent }
            .onAppear {
                originalBrightness = UIScreen.main.brightness
                UIScreen.main.brightness = CGFloat(1.0)
            }
            .onDisappear {
                UIScreen.main.brightness = originalBrightness
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Close")
            })
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                self.mode = mode.oppositeMode
            }, label: {
                Image(systemName: mode.oppositeMode.systemImageName)
            })
        }
    }
}

private struct AliasEmailTextView: View {
    @Binding var originalBrightness: CGFloat
    @Binding var percentage: Double
    let email: String

    var body: some View {
        VStack {
            Spacer()
            Text(verbatim: email)
                .font(.system(size: (percentage + 1) * 24))
                .fontWeight(.semibold)
            Spacer()
            HStack {
                Text("A")
                Slider(value: $percentage)
                Text("A")
                    .font(.title)
            }
        }
    }
}

private struct AliasEmailQrView: View {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    var email: String

    var body: some View {
        Image(uiImage: qrCodeImage())
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }

    private func qrCodeImage() -> UIImage {
        let data = Data(email.utf8)
        filter.setValue(data, forKey: "inputMessage")

        if let qrCodeImage = filter.outputImage,
           let qrCodeCGImage = context.createCGImage(qrCodeImage, from: qrCodeImage.extent) {
            return .init(cgImage: qrCodeCGImage)
        }
        return .init()
    }
}
