//
//  MockAnalyticsTracker.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import MoPubSDK

class MockAnalyticsTracker: MPAnalyticsTracker {
    private(set) var lastTrackedURLs: [URL] = []
    
    override class func shared() -> MockAnalyticsTracker {
        return super.shared() as! MockAnalyticsTracker
    }
    
    /// Override `sendTrackingRequest(for:)` to simply keep track of the URLs that were tracked
    override func sendTrackingRequest(for URLs: [URL]!) {
        for URL in URLs {
            lastTrackedURLs.append(URL)
        }
    }
    
    func reset() {
        lastTrackedURLs = []
    }
}
