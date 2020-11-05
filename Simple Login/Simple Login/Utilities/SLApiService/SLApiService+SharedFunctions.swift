//
//  SLApiService+SharedFunctions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Alamofire
import Foundation

// swiftlint:disable cyclomatic_complexity
final class SLApiService {
    private init() {}

    static let shared = SLApiService()

    private(set) var baseUrl: String = "https://app.simplelogin.io"

    func refreshBaseUrl() {
        baseUrl = Settings.shared.apiUrl
    }
}
