//
//  DeviceInformation+Testing.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
import CoreLocation
@testable import MoPubSDK

// <SANITIZE>
// TODO: Remove from MoPubSDKTests target once MPAdServerURLBuilderTests and MPSKAdNetworkManagerTests have been migrated to Swift
// </SANITIZE>
extension DeviceInformation {
    // MARK: - Application

    /// Swizzles `applicationVersion`
    @_dynamicReplacement(for: applicationVersion)
    static var swizzle_applicationVersion: String? {
        // The main bundle's info plist does not have a version when testing.
        return "5.0.0"
    }
    
    // MARK: - Connectivity
    
    /// Backing storage for `cellularService`
    static var mockCellularService: CellularService?
    
    /// Swizzles `cellularService`
    @_dynamicReplacement(for: cellularService)
    static var swizzle_cellularService: CellularService? {
        return mockCellularService
    }
    
    /// Backing storage for `reachability`
    static var mockReachability: NetworkReachable?
    
    /// Swizzles `reachability`
    @_dynamicReplacement(for: reachability)
    static var swizzle_reachability: NetworkReachable? {
        return mockReachability
    }
    
    // MARK: - Identifiers
    
    /// Backing storage for `rawIfa`
    static var mockRawIfa: String? = nil
    
    /// Swizzles `rawIfa`
    @_dynamicReplacement(for: rawIfa)
    static var swizzle_rawIfa: String? {
        return mockRawIfa
    }
    
    // MARK: - Location
    
    /// Backing storage for `locationManagerLocationServiceEnabled`
    static var mockLocationManagerLocationServiceEnabled = true
    
    /// Swizzles `locationManagerLocationServiceEnabled`
    @_dynamicReplacement(for: locationManagerLocationServiceEnabled)
    static var swizzle_locationManagerLocationServiceEnabled: Bool {
        return mockLocationManagerLocationServiceEnabled
    }
    
    /// Backing storage for `locationManagerAuthorizationStatus`
    static var mockLocationManagerAuthorizationStatus = CLAuthorizationStatus.notDetermined

    /// Swizzles `locationManagerAuthorizationStatus`
    @_dynamicReplacement(for: locationManagerAuthorizationStatus)
    static var swizzle_locationManagerAuthorizationStatus: CLAuthorizationStatus {
        return mockLocationManagerAuthorizationStatus
    }
    
    /// Backing storage for `locationManager`
    static var mockLocationManager = CLLocationManager()
    
    /// Swizzles `locationManager`
    @_dynamicReplacement(for: locationManager)
    static var swizzle_locationManager: CLLocationManager {
        return mockLocationManager
    }
}
