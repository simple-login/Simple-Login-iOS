//
//  AliasActivityTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasActivityTests: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: AliasActivity!

    override func setUp() {
        super.setUp()
        // swiftlint:disable:next force_try
        try! givenSutFromJson(fileName: "AliasActivity")
    }

    override func tearDown() {
        dictionary = nil
        sut = nil
        super.tearDown()
    }

    func testConformsToDecodable() {
        XCTAssertTrue((sut as Any) is Decodable)
    }

    // MARK: - Decodable test
    func testDecodeAction() throws {
        let actionString = try XCTUnwrap(dictionary["action"] as? String)
        let expectedAction = try XCTUnwrap(AliasActivity.Action(rawValue: actionString))
        XCTAssertEqual(sut.action, expectedAction)
    }

    func testDecodeReverseAlias() {
        XCTAssertEqual(sut.reverseAlias, dictionary["reverse_alias"] as? String)
    }

    func testDecodeFrom() {
        XCTAssertEqual(sut.from, dictionary["from"] as? String)
    }

    func testDecodeTo() {
        XCTAssertEqual(sut.to, dictionary["to"] as? String)
    }

    func testDecodeTimestamp() {
        XCTAssertEqual(sut.timestamp, dictionary["timestamp"] as? TimeInterval)
    }
}

extension AliasActivityTests {
    func testInitActionReply() throws {
        let replyAction = try XCTUnwrap(AliasActivity.Action(rawValue: "reply"))
        XCTAssertEqual(replyAction, .reply)
    }

    func testInitActionBlock() throws {
        let blockAction = try XCTUnwrap(AliasActivity.Action(rawValue: "block"))
        XCTAssertEqual(blockAction, .block)
    }

    func testInitActionBounced() throws {
        let bouncedAction = try XCTUnwrap(AliasActivity.Action(rawValue: "bounced"))
        XCTAssertEqual(bouncedAction, .bounced)
    }

    func testInitActionForward() throws {
        let forwardAction = try XCTUnwrap(AliasActivity.Action(rawValue: "forward"))
        XCTAssertEqual(forwardAction, .forward)
    }
}
