//
//  Data+fromJsonFile.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import XCTest

extension Data {
    static func fromJson(fileName: String) throws -> Data {
        let bundle = Bundle(for: TestBundleClass.self)
        let url = try XCTUnwrap(bundle.url(forResource: fileName, withExtension: "json"),
                                "Unable to find \(fileName).json in \(bundle.bundleURL)")
        return try Data(contentsOf: url)
    }
}

private class TestBundleClass {}
