//
//  AdImpressionTimerTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class AdImpressionTimerTests: XCTestCase {
    
    let view = UIView()
    
    override func setUp() {
        // Reset test state.
        AdImpressionTimer.mockIsViewVisible = true
        AdImpressionTimer.mockIsAppActive = true
        view.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
    }
    
    func testPixelTrackingModeFires() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testPercentageTrackingModeFires() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .percentage(0.01)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testZeroImpressionTimeFires() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        // Since the minimum time to fire is 0.1 seconds, an impression time
        // of 0 should still fire.
        let timer = AdImpressionTimer(impressionTime: 0, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testNegativeImpressionTimeFires() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        // Since the minimum time to fire is 0.1 seconds, a negative impression
        // time should still fire.
        let timer = AdImpressionTimer(impressionTime: -1000, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testPixelTrackingModeDoesNotFireWhenViewNotVisible() {
        AdImpressionTimer.mockIsViewVisible = false
        
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }

    func testPercentageTrackingModeDoesNotFireWhenViewNotVisible() {
        AdImpressionTimer.mockIsViewVisible = false
        
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .percentage(0.01)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDoesNotTrackIfAppIsNotActive() {
        AdImpressionTimer.mockIsAppActive = false
        
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .percentage(0.01)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDoesNotFireBeforeImpressionTime() {
        let doesNotTrackExpectation = expectation(description: "Ad impression timer should not fire")
        doesNotTrackExpectation.isInverted = true
        
        let trackExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        // Make sure the impression time takes several ticks of the underlying timer.
        let timer = AdImpressionTimer(impressionTime: Constants.longImpressionTime, trackingMode: .pixels(1)) { _ in
            doesNotTrackExpectation.fulfill()
            trackExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        // After this timeout, the underlying timer should have fired once,
        // but since this is shorter than the impression time, the impression
        // should not have fired yet.
        wait(for: [doesNotTrackExpectation], timeout: Constants.longDelay)
        
        // But then the impression should track after a bit longer.
        wait(for: [trackExpectation], timeout: Constants.timeout)
    }
    
    func testDoesNotFireWhenSetToNil() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        // Make sure the impression time takes several ticks of the underlying timer.
        var timer: AdImpressionTimer? = AdImpressionTimer(impressionTime: Constants.longImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer?.startTracking(view: view)
        
        // Nilling out the timer after a delay should dealloc it, which
        // should invalidate the underlying timer.
        let milliseconds = Int(Constants.longDelay * 1000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            timer = nil
        }
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDoesNotFireWhenViewBecomesNil() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        // Make sure the impression time takes several ticks of the underlying timer.
        let timer = AdImpressionTimer(impressionTime: Constants.longImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        var testView: UIView? = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        timer.startTracking(view: testView!)
        
        // Nilling out the view after a delay should dealloc it, which
        // should invalidate the underlying timer.
        let milliseconds = Int(Constants.longDelay * 1000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            testView = nil
        }
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDoesNotTrackWhenViewIsNoLongerVisible() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        // Make sure the impression time takes several ticks of the underlying timer.
        let timer = AdImpressionTimer(impressionTime: Constants.longImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        // The impression should not track if the view is no longer visible.
        let milliseconds = Int(Constants.longDelay * 1000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            AdImpressionTimer.mockIsViewVisible = false
        }
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTracksWhenViewBecomesVisible() {
        AdImpressionTimer.mockIsViewVisible = false
        
        let doesNotTrackExpectation = expectation(description: "Ad impression timer should not fire")
        doesNotTrackExpectation.isInverted = true
        
        let trackExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            doesNotTrackExpectation.fulfill()
            trackExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        // Since the view is not visible, it should not have tracked by
        // this point.
        wait(for: [doesNotTrackExpectation], timeout: Constants.timeout)

        // Make the view visible, and it should track.
        AdImpressionTimer.mockIsViewVisible = true
        wait(for: [trackExpectation], timeout: Constants.timeout)
    }
    
    func testDoesNotTrackWhenAppIsNoLongerActive() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.isInverted = true
        
        // Make sure the impression time takes several ticks of the underlying timer.
        let timer = AdImpressionTimer(impressionTime: Constants.longImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        // The impression should not track if the app is no longer active.
        let milliseconds = Int(Constants.longDelay * 1000)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
            AdImpressionTimer.mockIsAppActive = false
        }
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testTracksWhenAppBecomesActive() {
        AdImpressionTimer.mockIsAppActive = false
        
        let doesNotTrackExpectation = expectation(description: "Ad impression timer should not fire")
        doesNotTrackExpectation.isInverted = true
        
        let trackExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            doesNotTrackExpectation.fulfill()
            trackExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        // Since the app is not active, it should not have tracked by
        // this point.
        wait(for: [doesNotTrackExpectation], timeout: Constants.timeout)

        // Make the app active, and it should track.
        AdImpressionTimer.mockIsAppActive = true
        wait(for: [trackExpectation], timeout: Constants.timeout)
    }
    
    func testOnlyTracksOneTime() {
        // Create an inverted expectation with a fulfillment count of 2,
        // which will fail if the completion block is called more than once.
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        timerExpectation.expectedFulfillmentCount = 2
        timerExpectation.isInverted = true
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testSameViewInCompletion() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { [weak self] completionView in
            guard let strongSelf = self else {
                return
            }
            
            XCTAssert(strongSelf.view === completionView)
            timerExpectation.fulfill()
        }
        
        timer.startTracking(view: view)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testDoubleStartTracking() {
        let timerExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { [weak self] completionView in
            guard let strongSelf = self else {
                return
            }
            
            XCTAssert(strongSelf.view === completionView)
            timerExpectation.fulfill()
        }
        
        // Call startTracking twice, the second call should have no effect,
        // and the view passed back should be the first view.
        timer.startTracking(view: view)
        let otherView = UIView()
        timer.startTracking(view: otherView)
        
        waitForExpectations(timeout: Constants.timeout) { (error) in
            XCTAssertNil(error)
        }
    }
    
    func testCallStartAfterCompletion() {
        let trackExpectation = expectation(description: "Wait for ad impression timer to fire")
        
        // Create an inverted expectation with a fulfillment count of 2,
        // which will fail if the completion block is called more than once.
        let doesNotTrackExpectation = expectation(description: "Ad impression timer should not fire")
        doesNotTrackExpectation.isInverted = true
        doesNotTrackExpectation.expectedFulfillmentCount = 2
        
        let timer = AdImpressionTimer(impressionTime: Constants.shortImpressionTime, trackingMode: .pixels(1)) { _ in
            trackExpectation.fulfill()
            doesNotTrackExpectation.fulfill()
        }
        
        // Call start tracking, and we should get the initial callback.
        timer.startTracking(view: view)
        wait(for: [trackExpectation], timeout: Constants.timeout)
        
        // Call start tracking on the timer a second time. The completion
        // should not be called again.
        let otherView = UIView()
        timer.startTracking(view: otherView)
        wait(for: [doesNotTrackExpectation], timeout: Constants.timeout)
    }

}

private extension AdImpressionTimerTests {
    struct Constants {
        /// A short impression time so that the timer only takes one tick to fire.
        static let shortImpressionTime: TimeInterval = 0.05
        
        /// A long impression time so that the timer takes several ticks to fire.
        static let longImpressionTime: TimeInterval = 0.25
        
        /// A delay time that can be used to perform actions before timers for `longImpressionTime` fire,
        /// but after one tick of the ad impression timer.
        static let longDelay: TimeInterval = 0.15
        
        /// Timeout for most tests.
        static let timeout: TimeInterval = 0.5
    }
}
