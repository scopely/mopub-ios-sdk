//
//  ClickDisplayTrackerTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class ClickDisplayTrackerTests: XCTestCase {
    
    let mockAnalyticsTracker = MockAnalyticsTracker.shared()
    
    override func tearDown() {
        super.tearDown()
        
        // Reset the mock analytics
        mockAnalyticsTracker.reset()
    }
    
    /// Tests that multiple trackers get piped through
    /// Avoids using macros in the URLs which will be tested separately
    func testMultipleTrackersPipeThrough() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        // List of test click trackers
        let clickTrackers = [
            "https://google.com",
            "https://mopub.com"
        ]
        
        // Make a set of click display trackers to check against
        let clickDisplayTrackersAnswerKey = clickTrackers.compactMap { URL(string: $0) }
        
        // Check that the URLs are all tracked with every `DisplayType`
        for displayType in ClickDisplayTracker.DisplayType.allCases {
            // Make SKAdNetworkData
            var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
            serverResponse[.clickDisplayTrackers] = clickTrackers
            
            guard let data = SKAdNetworkData(serverResponse: serverResponse)
            else {
                XCTAssert(false)
                continue
            }
            
            // Fire the trackers
            ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                                  displayType: displayType,
                                                  analyticsTracker: mockAnalyticsTracker)
            
            // Check all the URLs were tracked
            for url in clickDisplayTrackersAnswerKey {
                XCTAssert(mockAnalyticsTracker.lastTrackedURLs.contains(url))
            }
            
            // Reset the mock analytics
            mockAnalyticsTracker.reset()
        }
    }
    
    /// Tests that a single tracker gets piped through
    /// Avoids using macros in the URL which will be tested separately
    func testSingleTrackerPipesThrough() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        // List of test click trackers
        let clickTrackers = [
            "https://mopub.com"
        ]
        
        // Make a set of click display trackers to check against
        let clickDisplayTrackersAnswerKey = clickTrackers.compactMap { URL(string: $0) }
        
        // Check that the URLs are all tracked with every `DisplayType`
        for displayType in ClickDisplayTracker.DisplayType.allCases {
            // Make SKAdNetworkData
            var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
            serverResponse[.clickDisplayTrackers] = clickTrackers
            
            guard let data = SKAdNetworkData(serverResponse: serverResponse)
            else {
                XCTAssert(false)
                return
            }
            
            // Fire the trackers
            ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                                  displayType: displayType,
                                                  analyticsTracker: mockAnalyticsTracker)
            
            // Check all the URLs were tracked
            for url in clickDisplayTrackersAnswerKey {
                XCTAssert(mockAnalyticsTracker.lastTrackedURLs.contains(url))
            }
            
            // Reset the mock analytics
            mockAnalyticsTracker.reset()
        }
    }
    
    /// Tests that an empty array with no trackers gets piped through
    func testEmptyArrayPipesThrough() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        // Make SKAdNetworkData
        let clickTrackers: [String] = []
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickDisplayTrackers] = clickTrackers
        
        guard let data = SKAdNetworkData(serverResponse: serverResponse)
        else {
            XCTAssert(false)
            return
        }
        
        // Check that the empty array is funneled with every `DisplayType`
        for displayType in ClickDisplayTracker.DisplayType.allCases {
            // Fire the trackers
            ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                                  displayType: displayType,
                                                  analyticsTracker: mockAnalyticsTracker)
            
            // Check for no URLs tracked
            XCTAssert(mockAnalyticsTracker.lastTrackedURLs.isEmpty)
            
            // Reset the mock analytics
            mockAnalyticsTracker.reset()
        }
    }
    
    /// Tests that no `clicktrackers` in ad response results in empty array and is handled gracefully
    func testNoClicktrackersResponsePipesToEmptyArray() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        // Make SKAdNetworkData
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickDisplayTrackers] = nil
        
        guard let data = SKAdNetworkData(serverResponse: serverResponse)
        else {
            XCTAssert(false)
            return
        }
        
        // Check that the empty array is funneled with every `DisplayType`
        for displayType in ClickDisplayTracker.DisplayType.allCases {
            // Fire the trackers
            ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                                  displayType: displayType,
                                                  analyticsTracker: mockAnalyticsTracker)
            
            // Check for no URLs tracked
            XCTAssert(mockAnalyticsTracker.lastTrackedURLs.isEmpty)
            
            // Reset the mock analytics
            mockAnalyticsTracker.reset()
        }
    }
    
    /// Tests that URL strings containing macros have them properly replaced
    func testMacroReplacement() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        // List of test click trackers
        let clickTrackers = [
            "https://mopub.com/?click_type=%%SDK_CLICK_TYPE%%&another_param=12345"
        ]
        
        let answerKey: [ClickDisplayTracker.DisplayType: URL] = [
            .safariViewController:       URL(string: "https://mopub.com/?click_type=in_app_browser&another_param=12345")!,
            .nativeSafari:               URL(string: "https://mopub.com/?click_type=native_browser&another_param=12345")!,
            .storeProductViewController: URL(string: "https://mopub.com/?click_type=app_store&another_param=12345")!,
            .error:                      URL(string: "https://mopub.com/?click_type=error&another_param=12345")!,
        ]
        
        // Check that the URLs are all tracked with every `DisplayType`
        for displayType in ClickDisplayTracker.DisplayType.allCases {
            // Make SKAdNetworkData
            var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
            serverResponse[.clickDisplayTrackers] = clickTrackers
            
            guard let data = SKAdNetworkData(serverResponse: serverResponse)
            else {
                XCTAssert(false)
                return
            }
            
            // Fire the trackers
            ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                                  displayType: displayType,
                                                  analyticsTracker: mockAnalyticsTracker)
            
            // Get the tracked URL
            guard let trackedUrl = mockAnalyticsTracker.lastTrackedURLs.first else {
                XCTAssert(false)
                continue
            }
            
            // The tracked URL should match the URL with the corresponding display type in the `answerKey` above
            XCTAssert(trackedUrl == answerKey[displayType])
            
            // Reset the mock analytics
            mockAnalyticsTracker.reset()
        }
    }
    
    /// Tests to ensure one specific `skAdNetworkData` object will not be tracked more than once,
    /// even if `trackClickDisplay` is called with it multiple times.
    func testGivenSkAdNetworkDataIsNotTrackedMoreThanOnce() throws {
        // List of test click trackers
        let clickTrackers = [
            "https://mopub.com/?click_type=%%SDK_CLICK_TYPE%%&another_param=12345"
        ]
        
        // Make SKAdNetworkData
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickDisplayTrackers] = clickTrackers
        
        guard let data = SKAdNetworkData(serverResponse: serverResponse)
        else {
            XCTAssert(false)
            return
        }
        
        // Fire the trackers
        ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                              displayType: .storeProductViewController,
                                              analyticsTracker: mockAnalyticsTracker)
        
        // Get the tracked URL
        guard let trackedUrl = mockAnalyticsTracker.lastTrackedURLs.first else {
            XCTAssert(false)
            return
        }
        
        // The tracked URL should match the URL with the corresponding display type in the `answerKey` above
        XCTAssert(trackedUrl == URL(string: "https://mopub.com/?click_type=app_store&another_param=12345")!)
        
        // Reset tracked URLs
        mockAnalyticsTracker.reset()
        
        // Fire the trackers again
        ClickDisplayTracker.trackClickDisplay(skAdNetworkData: data,
                                              displayType: .storeProductViewController,
                                              analyticsTracker: mockAnalyticsTracker)
        
        // There should be no tracked URL
        XCTAssertNil(mockAnalyticsTracker.lastTrackedURLs.first)
    }
    
}
