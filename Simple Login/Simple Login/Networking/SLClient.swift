//
//  SLClient.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

/**
 A client that communicates with SimpleLogin server. To be subclassed.
 */
class SLClient {
    let engine: NetworkEngine
    let baseUrl: URL

    init(engine: NetworkEngine = URLSession.shared, baseUrlString: String = kDefaultBaseUrlString) throws {
        self.engine = engine

        if let baseUrl = URL(string: baseUrlString) {
            self.baseUrl = baseUrl
        } else {
            throw SLError.badUrlString(urlString: baseUrlString)
        }
    }
}
