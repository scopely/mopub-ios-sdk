//
//  AdImpressionTimer+Testing.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
@testable import MoPubSDK

extension AdImpressionTimer {
    static var mockIsViewVisible = false
    
    @_dynamicReplacement(for: isViewVisible)
    static func swizzle_isViewVisible(_ view: UIView, trackingMode: ViewVisibilityTrackingMode) -> Bool {
        return mockIsViewVisible
    }
    
    static var mockIsAppActive = false
    
    @_dynamicReplacement(for: isAppActive)
    static var swizzle_isAppActive: Bool {
        return mockIsAppActive
    }
}
