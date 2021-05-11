//
//  StopwatchTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class StopwatchTests: XCTestCase {
    func testForegroundOnlySuccess() {
        let stopwatch = Stopwatch()
        XCTAssertNotNil(stopwatch)
        XCTAssertFalse(stopwatch.isRunning)

        let expectation = self.expectation(description: "Wait for timer to fire")
        expectation.expectedFulfillmentCount = 1

        stopwatch.start()
        XCTAssertTrue(stopwatch.isRunning)

        var duration: TimeInterval = 0.0
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.testTimeout) {
            XCTAssertTrue(stopwatch.isRunning)
            duration = stopwatch.stop()
            XCTAssertFalse(stopwatch.isRunning)
            expectation.fulfill()
        }

        let totalToleratedTimeout = Constants.testTimeout + Constants.testTimeoutTolerance
        waitForExpectations(timeout: totalToleratedTimeout) { error in
            XCTAssertNil(error)
        }

        // Validate that the stopwatch duration is within tolerance
        XCTAssert(duration > Constants.testTimeout && duration < totalToleratedTimeout)
    }

    func testDoubleStart() {
        let stopwatch = Stopwatch()
        XCTAssertNotNil(stopwatch)
        XCTAssertFalse(stopwatch.isRunning)

        stopwatch.start()
        XCTAssertTrue(stopwatch.isRunning)

        stopwatch.start()
        XCTAssertTrue(stopwatch.isRunning)
    }

    func testEndBeforeStart() {
        let stopwatch = Stopwatch()
        XCTAssertNotNil(stopwatch)
        XCTAssertFalse(stopwatch.isRunning)

        let duration: TimeInterval = stopwatch.stop()
        XCTAssert(duration == 0.0)
    }

    func testDoubleEndAfterStart() {
        let stopwatch = Stopwatch()
        XCTAssertNotNil(stopwatch)
        XCTAssertFalse(stopwatch.isRunning)

        stopwatch.start()
        XCTAssertTrue(stopwatch.isRunning)

        var duration: TimeInterval = stopwatch.stop()
        XCTAssert(duration == 0.0)

        duration = stopwatch.stop()
        XCTAssert(duration == 0.0)

    }
}


private extension StopwatchTests {
    struct Constants {
        static let testTimeout: TimeInterval = 4.0
        static let testTimeoutTolerance: TimeInterval = 0.5
    }
}
