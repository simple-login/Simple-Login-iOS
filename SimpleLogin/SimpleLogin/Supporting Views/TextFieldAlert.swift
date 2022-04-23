//
//  TextFieldAlert.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 23/04/2022.
//

import SwiftUI

struct TextFieldAlertConfig {
    let title: String
    var message: String?
    var text: String?
    var placeholder: String?
    var keyboardType: UIKeyboardType = .default
    var clearButtonMode: UITextField.ViewMode = .always
    let actionTitle: String
    let action: (String?) -> Void
}

struct TextFieldAlertModifier: ViewModifier {
    @State private var alertController: UIAlertController?
    @Binding var isPresented: Bool
    let config: TextFieldAlertConfig

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            if isPresented, alertController == nil {
                let alertController = makeAlertController()
                self.alertController = alertController
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                    return
                }
                scene.windows.first?.rootViewController?.present(alertController, animated: true)
            } else if !isPresented, let alertController = alertController {
                alertController.dismiss(animated: true)
                self.alertController = nil
            }
        }
    }

    func makeAlertController() -> UIAlertController {
        let controller = UIAlertController(title: config.title,
                                           message: config.message,
                                           preferredStyle: .alert)
        controller.addTextField {
            $0.placeholder = config.placeholder
            $0.text = config.text
            $0.keyboardType = config.keyboardType
            $0.clearButtonMode = config.clearButtonMode
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            dismiss()
        })
        controller.addAction(UIAlertAction(title: config.actionTitle, style: .default) { _ in
            config.action(controller.textFields?.first?.text)
            dismiss()
        })
        return controller
    }

    private func dismiss() {
        isPresented = false
        alertController = nil
    }
}

extension View {
    func textFieldAlert(isPresented: Binding<Bool>, config: TextFieldAlertConfig) -> some View {
        modifier(TextFieldAlertModifier(isPresented: isPresented, config: config))
    }
}
