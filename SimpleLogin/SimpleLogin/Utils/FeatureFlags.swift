//
//  FeatureFlags.swift
//  SimpleLogin
//
//  Created by Nhon Proton on 18/10/2022.
//

import Foundation

struct FeatureFlags {
    let printNetworkDebugInformation: Bool
}

let featureFlags = {
    #if DEBUG
    FeatureFlags(printNetworkDebugInformation: true)
    #else
    FeatureFlags(printNetworkDebugInformation: false)
    #endif
}()
