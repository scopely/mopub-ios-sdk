//
//  SKAdNetworkServerResponseFactory.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation
@testable import MoPubSDK

class SKAdNetworkServerResponseFactory {
    
    /// 2.0 response
    class func response20() -> [String: Any] {
        let version = "2.0"
        let network = "cDkw7geQsH.skadnetwork"
        let campaign = "45"
        let itunesitem = "880047117"
        let nonce = "473b1a16-b4ef-43ad-9591-fcf3aefa82a7"
        let sourceapp = "123456789"
        let timestamp = "1594406341"
        let signature = "hi i'm a signature"
        
        let clickTrackers = [
            "https://google.com",
            "https://mopub.com"
        ]
        
        let clickMethod = "\(SKAdNetworkData.ClickMethod.interceptAppStoreClicks.rawValue)"
        
        return [
            "click": [
                "version": version,
                "network": network,
                "campaign": campaign,
                "itunesitem": itunesitem,
                "nonce": nonce,
                "sourceapp": sourceapp,
                "timestamp": timestamp,
                "signature": signature,
            ],
            "clicktrackers": clickTrackers,
            "clickmethod": clickMethod
        ]
    }
    
    /// 2.2 response (including click, excluding view)
    class func ctaResponse22() -> [String: Any] {
        let version = "2.2"
        let network = "cDkw7geQsH.skadnetwork"
        let campaign = "45"
        let itunesitem = "880047117"
        let nonce = "473b1a16-b4ef-43ad-9591-fcf3aefa82a7"
        let sourceapp = "123456789"
        let timestamp = "1594406341"
        let signature = "hi i'm a signature"
        let fidelity = "1"
        
        let clickTrackers = [
            "https://google.com",
            "https://mopub.com"
        ]
        
        let clickMethod = "\(SKAdNetworkData.ClickMethod.interceptAllClicks.rawValue)"
        
        return [
            "click": [
                "version": version,
                "network": network,
                "campaign": campaign,
                "itunesitem": itunesitem,
                "nonce": nonce,
                "sourceapp": sourceapp,
                "timestamp": timestamp,
                "signature": signature,
                "fidelity": fidelity,
            ],
            "clicktrackers": clickTrackers,
            "clickmethod": clickMethod
        ]
    }
    
    /// 2.2 response (including click and view both)
    class func vtaResponse22() -> [String: Any] {
        let version = "2.2"
        let network = "cDkw7geQsH.skadnetwork"
        let campaign = "45"
        let itunesitem = "880047117"
        let nonce = "473b1a16-b4ef-43ad-9591-fcf3aefa82a7"
        let sourceapp = "123456789"
        let timestamp = "1594406341"
        let signature = "hi i'm a signature"
        let fidelity = "1"
        
        let clickTrackers = [
            "https://google.com",
            "https://mopub.com"
        ]
        
        let clickMethod = "\(SKAdNetworkData.ClickMethod.interceptAppStoreClicks.rawValue)"
        
        return [
            "click": [
                "version": version,
                "network": network,
                "campaign": campaign,
                "itunesitem": itunesitem,
                "nonce": nonce,
                "sourceapp": sourceapp,
                "timestamp": timestamp,
                "signature": signature,
                "fidelity": fidelity,
            ],
            "view": [
                "signature": signature,
                "version": version,
                "network": network,
                "campaign": campaign,
                "itunesitem": itunesitem,
                "nonce": nonce,
                "sourceapp": sourceapp,
                "timestamp": timestamp,
            ],
            "clicktrackers": clickTrackers,
            "clickmethod": clickMethod
        ]
    }
    
}
