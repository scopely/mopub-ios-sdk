//
//  ConsentSynchronizationURLCompareTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class ConsentSynchronizationURLCompareTests: XCTestCase {
    /// Validates that two Consent URL requests that have differing POST payloads are correctly flagged
    /// as not duplicates.
    func testConsentSyncPayloadDifferent() throws {
        // Generate two URLs that pretend to go to the GDPR sync endpoint.
        guard let url1 = MPURL(string: "https://ads.mopub.com/m/gdpr_sync"),
              let url2 = MPURL(string: "https://ads.mopub.com/m/gdpr_sync") else {
            XCTFail()
            return
        }
        
        // Generate two POST payloads that differ by consent status.
        url1.postData["current_consent_status"] = "explicit_yes"
        url2.postData["current_consent_status"] = "dnt"
        XCTAssert(url1.postData.count == 1)
        XCTAssert(url2.postData.count == 1)
        
        // Generate the requests from the two URLs
        let request1 = MPURLRequest(url: url1 as URL)
        let request2 = MPURLRequest(url: url2 as URL)
        
        let consentSyncURLComparator = ConsentSynchronizationURLCompare()
        let isDuplicate = consentSyncURLComparator.isRequest(request2, duplicateOf: request1)
        XCTAssertFalse(isDuplicate)
    }
}
