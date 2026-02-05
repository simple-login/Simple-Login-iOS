//
//  ShareSheetView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems,
                                                  applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
