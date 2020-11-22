//
//  ImageService.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation

final class ImageService {
    static let shared = ImageService()
    private let engine: NetworkEngine
    private(set) var downloadedImages: [String: Data] = [:]

    init(engine: NetworkEngine = URLSession.shared) {
        self.engine = engine
    }

    func getImage(from urlString: String, completion: @escaping (Result<Data, SLError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.badUrlString(urlString: urlString)))
            return
        }

        if let data = downloadedImages[urlString] {
            completion(.success(data))
            return
        }

        engine.performRequest(for: URLRequest(url: url)) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.unknownError(error: error)))
            } else if let data = data, let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    self?.downloadedImages[urlString] = data
                    completion(.success(data))
                } else {
                    completion(.failure(.unknownErrorWithStatusCode(statusCode: response.statusCode)))
                }
            } else {
                completion(.failure(.unknownResponseStatusCode))
            }
        }
    }
}
