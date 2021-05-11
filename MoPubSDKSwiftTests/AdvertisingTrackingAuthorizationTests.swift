//
//  AdvertisingTrackingAuthorizationTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest

// In order to get access to our code, without having to make all
// of our types and functions public, we can use the @testable
// keyword to also import all internal symbols from our app target.
@testable import MoPubSDK

class AdvertisingTrackingAuthorizationTests: XCTestCase {
    // MARK: - App Tracking Transparency

    /// Verifies that the ATT authorization status description strings match.
    func testATTAuthorizationStatusDescriptionValueFillsCorrectly() throws {
        if #available(iOS 14.0, *) {
            // Not determined
            AdvertisingTrackingAuthorization.mockStatus = .notDetermined
            XCTAssert(AdvertisingTrackingAuthorization.statusDescription == "not_determined")
            
            // Authorized
            AdvertisingTrackingAuthorization.mockStatus = .authorized
            XCTAssert(AdvertisingTrackingAuthorization.statusDescription == "authorized")
            
            // Denied
            AdvertisingTrackingAuthorization.mockStatus = .denied
            XCTAssert(AdvertisingTrackingAuthorization.statusDescription == "denied")
            
            // Restricted
            AdvertisingTrackingAuthorization.mockStatus = .restricted
            XCTAssert(AdvertisingTrackingAuthorization.statusDescription == "restricted")
        }
    }
    
    /// Verifies that `isAllowed` is set correctly based upon the the ATT authorization status.
    func testAdvertisingTrackingEnabledValueFillsCorrectly() throws {
        if #available(iOS 14.0, *) {
            // Not determined
            AdvertisingTrackingAuthorization.mockStatus = .notDetermined
            XCTAssertFalse(AdvertisingTrackingAuthorization.isAllowed)
            
            // Authorized
            AdvertisingTrackingAuthorization.mockStatus = .authorized
            XCTAssertTrue(AdvertisingTrackingAuthorization.isAllowed)
            
            // Denied
            AdvertisingTrackingAuthorization.mockStatus = .denied
            XCTAssertFalse(AdvertisingTrackingAuthorization.isAllowed)
            
            // Restricted
            AdvertisingTrackingAuthorization.mockStatus = .restricted
            XCTAssertFalse(AdvertisingTrackingAuthorization.isAllowed)
        }
    }
}
