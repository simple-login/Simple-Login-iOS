//
//  NetworkEngine.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

/**
 Encapsulate an engine that make network requests instead of directly using URLSession.
 Makes unit test easier.
*/
protocol NetworkEngine {
    typealias Handler = (Data?, URLResponse?, Error?) -> Void

    func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler)
}

extension URLSession: NetworkEngine {
    typealias Handler = NetworkEngine.Handler

    func performRequest(for urlRequest: URLRequest, completionHandler: @escaping Handler) {
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        task.resume()
    }
}
