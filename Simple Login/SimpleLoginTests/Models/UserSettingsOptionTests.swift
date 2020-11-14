//
//  UserSettingsOptionTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 14/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class UserSettingsOptionTests: XCTestCase {
    func testRequestBodyInRandomModeCase() {
        let uuid = UserSettings.Option.randomMode(.uuid)
        XCTAssertEqual(uuid.requestBody["alias_generator"] as? String, "uuid")

        let word = UserSettings.Option.randomMode(.word)
        XCTAssertEqual(word.requestBody["alias_generator"] as? String, "word")
    }

    func testRequestBodyInNotificationCase() {
        let trueOption = UserSettings.Option.notification(true)
        XCTAssertEqual(trueOption.requestBody["notification"] as? Bool, true)

        let falseOption = UserSettings.Option.notification(false)
        XCTAssertEqual(falseOption.requestBody["notification"] as? Bool, false)
    }

    func testRequestBodyInRandomAliasDefaultDomainCase() {
        // given
        let expectedDomainName = String.randomName()

        // when
        let option = UserSettings.Option.randomAliasDefaultDomain(expectedDomainName)

        // then
        XCTAssertEqual(option.requestBody["random_alias_default_domain"] as? String, expectedDomainName)
    }
}
