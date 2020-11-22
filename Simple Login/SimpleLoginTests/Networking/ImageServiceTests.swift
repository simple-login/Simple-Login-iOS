//
//  ImageServiceTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 22/11/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

@testable import SimpleLogin
import XCTest

class ImageServiceTests: XCTestCase {
    var sut: ImageService!

    override func setUp() {
        super.setUp()
        sut = ImageService.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testGetImageFromBadUrlStringReceiveBadUrlError() {
        // given
        let badUrlString = "a dummy url string"

        // when
        var storedData: Data?
        var storedError: SLError?
        sut.getImage(from: badUrlString) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        XCTAssertNil(storedData)
        XCTAssertEqual(storedError, SLError.badUrlString(urlString: badUrlString))
    }

    func testGetImageWithRandomError() {
        // given
        let (engine, expectedError) = NetworkEngineMock.givenEngineWithRandomError()

        // when
        var storedData: Data?
        var storedError: SLError?

        sut = ImageService(engine: engine)
        sut.getImage(from: String.randomValidUrlString()) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNil(storedData)
        XCTAssertEqual(storedError, SLError.unknownError(error: expectedError))
    }

    func testGetImageWithStatusCode200() throws {
        // given
        let urlString = String.randomValidUrlString()
        let (engine, expectedData) = try NetworkEngineMock.givenEngineWithExpectedDummyData(statusCode: 200)

        // when
        var storedData: Data?
        var storedError: SLError?

        sut = ImageService(engine: engine)
        sut.getImage(from: urlString) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedData, expectedData)
        XCTAssertEqual(sut.downloadedImages[urlString], expectedData)
        XCTAssertNil(storedError)
    }

    func testGetImageFromDownloadedImages() throws {
        // given
        let urlString = String.randomValidUrlString()
        let (engine, expectedData) = try NetworkEngineMock.givenEngineWithExpectedDummyData(statusCode: 200)

        // when
        var storedData: Data?
        var storedError: SLError?

        sut = ImageService(engine: engine)
        sut.getImage(from: urlString) { _ in }
        sut.getImage(from: urlString) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertEqual(storedData, expectedData)
        XCTAssertNil(storedError)
    }

    func testGetImageWithStatusCodeOtherThan200() throws {
        // given
        let expectedStatusCode = Int.randomStatusCode(except: 200)
        let (engine, _) = try NetworkEngineMock.givenEngineWithExpectedDummyData(statusCode: expectedStatusCode)

        // when
        var storedData: Data?
        var storedError: SLError?

        sut = ImageService(engine: engine)
        sut.getImage(from: String.randomValidUrlString()) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNil(storedData)
        XCTAssertEqual(storedError, SLError.unknownErrorWithStatusCode(statusCode: expectedStatusCode))
    }

    func testGetImageWithUnknownResponseStatusCode() {
        // given
        let engine = NetworkEngineMock.givenNullEngine()

        // when
        var storedData: Data?
        var storedError: SLError?

        sut = ImageService(engine: engine)
        sut.getImage(from: String.randomValidUrlString()) { result in
            switch result {
            case .success(let data): storedData = data
            case .failure(let error): storedError = error
            }
        }

        // then
        XCTAssertNil(storedData)
        XCTAssertEqual(storedError, SLError.unknownResponseStatusCode)
    }
}
