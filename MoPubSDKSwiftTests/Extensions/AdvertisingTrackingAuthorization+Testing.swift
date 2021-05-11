//
//  AdvertisingTrackingAuthorization+Testing.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import AppTrackingTransparency
import Foundation
@testable import MoPubSDK

/// Provides swizzling of `dynamic` properties for unit testing.
public extension AdvertisingTrackingAuthorization {
    /// Backing storage for `advertisingIdentifier`
    @objc static var mockAdvertisingIdentifier: String? = nil
    
    /// Swizzles `advertisingIdentifier`
    @_dynamicReplacement(for: advertisingIdentifier)
    static var swizzle_advertisingIdentifier: String? {
        return mockAdvertisingIdentifier
    }
        
    /// Backing storage for `status`
    @available(iOS 14.0, *)
    @objc static var mockStatus: ATTrackingManager.AuthorizationStatus = .notDetermined
    
    /// Swizzles `status`
    @_dynamicReplacement(for: status)
    @available(iOS 14.0, *)
    static var swizzle_status: ATTrackingManager.AuthorizationStatus {
        return mockStatus
    }
}
