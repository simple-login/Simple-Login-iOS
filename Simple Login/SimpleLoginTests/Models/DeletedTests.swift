//
//  DeletedTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 02/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class DeletedTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: Deleted!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "Deleted")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    func testDecodeValue() {
        XCTAssertEqual(sut.value, dictionary["deleted"] as? Bool)
    }
}
