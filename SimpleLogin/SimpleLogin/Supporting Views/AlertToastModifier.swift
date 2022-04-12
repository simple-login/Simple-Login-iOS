//
//  AlertToastModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import AlertToast
import SwiftUI

struct AlertToastLoadingModifier: ViewModifier {
    let isPresenting: Binding<Bool>

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting) {
                AlertToast(type: .loading)
            }
    }
}

struct AlertToastErrorModifier: ViewModifier {
    let isPresenting: Binding<Bool>
    let error: Error?

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: 3.5) {
                AlertToast(displayMode: .banner(.pop),
                           type: .error(.red),
                           title: error?.safeLocalizedDescription)
            }
    }
}

struct AlertToastMessageModifier: ViewModifier {
    let isPresenting: Binding<Bool>
    let message: String?

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: 3.5) {
                AlertToast(displayMode: .banner(.pop),
                           type: .regular,
                           title: message)
            }
    }
}

struct AlertToastCompletionMessage: ViewModifier {
    let isPresenting: Binding<Bool>
    let title: String
    let subTitle: String?

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: 3.5) {
                AlertToast(displayMode: .alert,
                           type: .complete(.green),
                           title: title,
                           subTitle: subTitle)
            }
    }
}

struct AlertToastCopyMessage: ViewModifier {
    let isPresenting: Binding<Bool>
    let message: String?

    func body(content: Content) -> some View {
        content
            .toast(isPresenting: isPresenting, duration: 3.5) {
                AlertToast(displayMode: .alert,
                           type: .systemImage("doc.on.doc", .secondary),
                           title: "Copied",
                           subTitle: message ?? "")
            }
    }
}

extension View {
    func alertToastLoading(isPresenting: Binding<Bool>) -> some View {
        modifier(AlertToastLoadingModifier(isPresenting: isPresenting))
    }

    func alertToastError(_ error: Binding<Error?>) -> some View {
        let binding = Binding<Bool>(get: {
            error.wrappedValue != nil
        }, set: { isPresenting in
            if !isPresenting {
                error.wrappedValue = nil
            }
        })
        return toast(isPresenting: binding, duration: 3.5) {
            AlertToast(displayMode: .banner(.pop),
                       type: .error(.red),
                       title: error.wrappedValue?.safeLocalizedDescription)
        }
    }

    func alertToastMessage(_ message: Binding<String?>) -> some View {
        let binding = Binding<Bool>(get: {
            message.wrappedValue != nil
        }, set: { isPresenting in
            if !isPresenting {
                message.wrappedValue = nil
            }
        })
        return toast(isPresenting: binding, duration: 3.5) {
            AlertToast(displayMode: .banner(.pop),
                       type: .regular,
                       title: message.wrappedValue)
        }
    }

    func alertToastCompletionMessage(isPresenting: Binding<Bool>, title: String, subTitle: String?) -> some View {
        modifier(AlertToastCompletionMessage(isPresenting: isPresenting, title: title, subTitle: subTitle))
    }

    func alertToastCopyMessage(isPresenting: Binding<Bool>, message: String?) -> some View {
        modifier(AlertToastCopyMessage(isPresenting: isPresenting, message: message))
    }
}
