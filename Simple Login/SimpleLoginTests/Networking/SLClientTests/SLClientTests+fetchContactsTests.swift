//
//  SLClientTests+fetchContactsTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 01/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class SLClientFetchContactsTests: XCTestCase {
    func whenFetchingContactsWith(engine: NetworkEngine) throws
    -> (contactArray: ContactArray?, error: SLError?) {
        var storedContactArray: ContactArray?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.fetchContacts(apiKey: ApiKey(value: ""),
                             aliasId: 128,
                             page: 12) { result in
            switch result {
            case .success(let contactArray): storedContactArray = contactArray
            case .failure(let error): storedError = error
            }
        }

        return (storedContactArray, storedError)
    }

    func testFetchMailboxesSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "ContactArray"))
        let engine = NetworkEngineMock(data: data, statusCode: 200, error: nil)

        // when
        let result = try whenFetchingContactsWith(engine: engine)

        // then
        XCTAssertNotNil(result.contactArray)
        XCTAssertNil(result.error)
    }
}
