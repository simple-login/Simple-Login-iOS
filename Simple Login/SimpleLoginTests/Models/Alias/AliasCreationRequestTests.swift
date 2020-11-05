//
//  AliasCreationRequestTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 05/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class AliasCreationRequestTests: XCTestCase {
    func givenRandomPrefixSuffixAndMailboxIds()
    // swiftlint:disable:next large_tuple
    -> (randomPrefix: String, randomSuffix: Suffix, randomMailboxIds: [Int]) {
        let randomPrefix = String.randomName()
        let randomSuffix = Suffix.random()
        let randomMailboxIds = [0...Int.random(in: 1...10)].map { _ in Int.randomPageId() }

        return (randomPrefix, randomSuffix, randomMailboxIds)
    }

    func testGenerateRequestBodyWithNoMissingValue() {
        let (randomPrefix, randomSuffix, randomMailboxIds) = givenRandomPrefixSuffixAndMailboxIds()
        let randomName = String.randomName()
        let randomNote = String.randomName()

        generateAndTest(prefix: randomPrefix,
                        suffix: randomSuffix,
                        mailboxIds: randomMailboxIds,
                        name: randomName,
                        note: randomNote)
    }

    func testGenerateRequestBodyWithNoName() {
        let (randomPrefix, randomSuffix, randomMailboxIds) = givenRandomPrefixSuffixAndMailboxIds()
        let randomName: String? = nil
        let randomNote = String.randomName()

        generateAndTest(prefix: randomPrefix,
                        suffix: randomSuffix,
                        mailboxIds: randomMailboxIds,
                        name: randomName,
                        note: randomNote)
    }

    func testGenerateRequestBodyWithNoNote() {
        let (randomPrefix, randomSuffix, randomMailboxIds) = givenRandomPrefixSuffixAndMailboxIds()
        let randomName = String.randomName()
        let randomNote: String? = nil

        generateAndTest(prefix: randomPrefix,
                        suffix: randomSuffix,
                        mailboxIds: randomMailboxIds,
                        name: randomName,
                        note: randomNote)
    }

    func testGenerateRequestBodyWithNoNameNoNote() {
        let (randomPrefix, randomSuffix, randomMailboxIds) = givenRandomPrefixSuffixAndMailboxIds()
        let randomName: String? = nil
        let randomNote: String? = nil

        generateAndTest(prefix: randomPrefix,
                        suffix: randomSuffix,
                        mailboxIds: randomMailboxIds,
                        name: randomName,
                        note: randomNote)
    }

    func generateAndTest(prefix: String, suffix: Suffix, mailboxIds: [Int], name: String?, note: String?) {
        let sut = AliasCreationRequest(prefix: prefix,
                                       suffix: suffix,
                                       mailboxIds: mailboxIds,
                                       name: name,
                                       note: note)
        let requestBody = sut.toRequestBody()

        XCTAssertEqual(requestBody["alias_prefix"] as? String, prefix)
        XCTAssertEqual(requestBody["signed_suffix"] as? String, suffix.value[1])
        XCTAssertEqual(requestBody["mailbox_ids"] as? [Int], mailboxIds)
        XCTAssertEqual(requestBody["name"] as? String, name)
        XCTAssertEqual(requestBody["note"] as? String, note)
    }
}
