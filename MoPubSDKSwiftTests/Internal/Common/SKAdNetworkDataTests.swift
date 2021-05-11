//
//  SKAdNetworkDataTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class SKAdNetworkDataTests: XCTestCase {

    /// Tests that an empty dictionary leads to failure to initialize
    func testEmptyDataLeadsToFailureToInitialize() throws {
        let data = SKAdNetworkData(serverResponse: [:])
        
        XCTAssertNil(data)
    }
    
    /// Tests that a nil dictionary leads to failure to initialize
    func testNilDataLeadsToFailureToInitialize() throws {
        let data = SKAdNetworkData(serverResponse: nil)
        
        XCTAssertNil(data)
    }
    
    /// Tests that incomplete data for SKAdNetwork 2.0/2.1 fails to initialize
    func testIncompleteDataFailsToInitialize20() throws {
        let baseResponse = SKAdNetworkServerResponseFactory.response20()
        var modifiedResponse = baseResponse
        
        // Full
        let data0 = SKAdNetworkData(serverResponse: baseResponse)
        XCTAssertNotNil(data0)
        
        // Missing version
        modifiedResponse = removeClickEntry(for: .version, from: baseResponse)
        let data1 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data1)
        
        // Missing network
        modifiedResponse = removeClickEntry(for: .network, from: baseResponse)
        let data2 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data2)
        
        // Missing campaign
        modifiedResponse = removeClickEntry(for: .campaign, from: baseResponse)
        let data3 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data3)
        
        // Missing itunesitem
        modifiedResponse = removeClickEntry(for: .destinationAppStoreIdentifier, from: baseResponse)
        let data4 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data4)
        
        // Missing nonce
        modifiedResponse = removeClickEntry(for: .nonce, from: baseResponse)
        let data5 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data5)
        
        // Missing sourceapp
        modifiedResponse = removeClickEntry(for: .sourceAppStoreIdentifier, from: baseResponse)
        let data6 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data6)
        
        // Missing timestamp
        modifiedResponse = removeClickEntry(for: .timestamp, from: baseResponse)
        let data7 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data7)
        
        // Missing signature
        modifiedResponse = removeClickEntry(for: .signature, from: baseResponse)
        let data8 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data8)
    }
    
    /// Tests that incomplete clickthrough data for SKAdNetwork 2.2 fails to initialize
    func testIncompleteClickthroughDataFailsToInitialize22() throws {
        let baseResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        var modifiedResponse = baseResponse
        
        // Full
        let data0 = SKAdNetworkData(serverResponse: baseResponse)
        XCTAssertNotNil(data0)
        
        // Missing version
        modifiedResponse = removeClickEntry(for: .version, from: baseResponse)
        let data1 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data1)
        
        // Missing network
        modifiedResponse = removeClickEntry(for: .network, from: baseResponse)
        let data2 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data2)
        
        // Missing campaign
        modifiedResponse = removeClickEntry(for: .campaign, from: baseResponse)
        let data3 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data3)
        
        // Missing itunesitem
        modifiedResponse = removeClickEntry(for: .destinationAppStoreIdentifier, from: baseResponse)
        let data4 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data4)
        
        // Missing nonce
        modifiedResponse = removeClickEntry(for: .nonce, from: baseResponse)
        let data5 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data5)
        
        // Missing sourceapp
        modifiedResponse = removeClickEntry(for: .sourceAppStoreIdentifier, from: baseResponse)
        let data6 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data6)
        
        // Missing timestamp
        modifiedResponse = removeClickEntry(for: .timestamp, from: baseResponse)
        let data7 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data7)
        
        // Missing signature
        modifiedResponse = removeClickEntry(for: .signature, from: baseResponse)
        let data8 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data8)
        
        // Missing fidelity-type
        modifiedResponse = removeClickEntry(for: .fidelityType, from: baseResponse)
        let data9 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNil(data9)
    }
    
    /// Tests that incomplete viewthrough data for SKAdNetwork 2.2 fails to initialize
    func testIncompleteViewthroughDataFailsToInitialize22() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        let baseResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        var modifiedResponse = baseResponse
        
        // Full
        let data0 = SKAdNetworkData(serverResponse: baseResponse)
        XCTAssertNotNil(data0)
        XCTAssertNotNil(data0?.impressionData)
        
        // Missing version
        modifiedResponse = removeViewEntry(for: .version, from: baseResponse)
        let data1 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data1)
        XCTAssertNil(data1?.impressionData)
        
        // Missing network
        modifiedResponse = removeViewEntry(for: .network, from: baseResponse)
        let data2 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data2)
        XCTAssertNil(data2?.impressionData)
        
        // Missing campaign
        modifiedResponse = removeViewEntry(for: .campaign, from: baseResponse)
        let data3 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data3)
        XCTAssertNil(data3?.impressionData)
        
        // Missing itunesitem
        modifiedResponse = removeViewEntry(for: .destinationAppStoreIdentifier, from: baseResponse)
        let data4 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data4)
        XCTAssertNil(data4?.impressionData)
        
        // Missing nonce
        modifiedResponse = removeViewEntry(for: .nonce, from: baseResponse)
        let data5 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data5)
        XCTAssertNil(data5?.impressionData)
        
        // Missing sourceapp
        modifiedResponse = removeViewEntry(for: .sourceAppStoreIdentifier, from: baseResponse)
        let data6 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data6)
        XCTAssertNil(data6?.impressionData)
        
        // Missing timestamp
        modifiedResponse = removeViewEntry(for: .timestamp, from: baseResponse)
        let data7 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data7)
        XCTAssertNil(data7?.impressionData)
        
        // Missing signature
        modifiedResponse = removeViewEntry(for: .signature, from: baseResponse)
        let data8 = SKAdNetworkData(serverResponse: modifiedResponse)
        XCTAssertNotNil(data8)
        XCTAssertNil(data8?.impressionData)
    }
    
    /// Tests that valid SKAdNetwork 2.0 clickthrough data initializes correctly
    func testValidClickthoughInitialization20() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        let serverResponse = SKAdNetworkServerResponseFactory.response20()
        guard let clickResponse = serverResponse[.clickResponse] as? [String: String],
              let version = clickResponse[.version],
              let network = clickResponse[.network],
              let campaign = clickResponse[.campaign],
              let itunesitem = clickResponse[.destinationAppStoreIdentifier],
              let nonce = clickResponse[.nonce],
              let sourceapp = clickResponse[.sourceAppStoreIdentifier],
              let timestamp = clickResponse[.timestamp],
              let signature = clickResponse[.signature]
        else {
            XCTAssert(false)
            return
        }
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        
        // Test dictionary is populated correctly
        // Check data types compared to apple doc
        // Check that data is piped correctly into the dictionary
        
        // Version should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkversion?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkVersion] as? String {
            XCTAssert(value == version)
        }
        else {
            XCTAssert(false)
        }
        
        // Network ID should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkidentifier?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkIdentifier] as? String {
            XCTAssert(value == network)
        }
        else {
            XCTAssert(false)
        }
        
        // Network Campaign ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkcampaignidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkCampaignIdentifier] as? NSNumber {
            XCTAssert("\(value)" == campaign)
        }
        else {
            XCTAssert(false)
        }
        
        // Destination app ID should be NSNumber (note that this is intentionally inconsistent with source app ID)
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteritunesitemidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterITunesItemIdentifier] as? NSNumber {
            XCTAssert("\(value)" == itunesitem)
        }
        else {
            XCTAssert(false)
        }
        
        // Nonce should be UUID
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworknonce?language=objc -- "The value for this key is an NSUUID."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkNonce] as? UUID {
            XCTAssert("\(value)".lowercased() == nonce.lowercased())
        }
        else {
            XCTAssert(false)
        }
        
        // Source app ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworksourceappstoreidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] as? NSNumber {
            XCTAssert("\(value)" == sourceapp)
        }
        else {
            XCTAssert(false)
        }
        
        // Timestamp should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworktimestamp?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber {
            XCTAssert("\(value)" == timestamp)
        }
        else {
            XCTAssert(false)
        }
        
        // Signature should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkattributionsignature?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkAttributionSignature] as? String {
            XCTAssert(value == signature)
        }
        else {
            XCTAssert(false)
        }
    }
    
    /// Tests that valid SKAdNetwork 2.2 clickthrough data initializes correctly
    func testValidClickthoughInitialization22() throws {
        guard #available(iOS 14.0, *) else {
            return
        }
        
        let serverResponse = SKAdNetworkServerResponseFactory.ctaResponse22()
        guard let clickResponse = serverResponse[.clickResponse] as? [String: String],
              let version = clickResponse[.version],
              let network = clickResponse[.network],
              let campaign = clickResponse[.campaign],
              let itunesitem = clickResponse[.destinationAppStoreIdentifier],
              let nonce = clickResponse[.nonce],
              let sourceapp = clickResponse[.sourceAppStoreIdentifier],
              let timestamp = clickResponse[.timestamp],
              let signature = clickResponse[.signature],
              let fidelity = clickResponse[.fidelityType]
        else {
            XCTAssert(false)
            return
        }
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        
        // Test dictionary is populated correctly
        // Check data types compared to apple doc
        // Check that data is piped correctly into the dictionary
        
        // Version should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkversion?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkVersion] as? String {
            XCTAssert(value == version)
        }
        else {
            XCTAssert(false)
        }
        
        // Network ID should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkidentifier?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkIdentifier] as? String {
            XCTAssert(value == network)
        }
        else {
            XCTAssert(false)
        }
        
        // Network Campaign ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkcampaignidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkCampaignIdentifier] as? NSNumber {
            XCTAssert("\(value)" == campaign)
        }
        else {
            XCTAssert(false)
        }
        
        // Destination app ID should be NSNumber (note that this is intentionally inconsistent with source app ID)
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteritunesitemidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterITunesItemIdentifier] as? NSNumber {
            XCTAssert("\(value)" == itunesitem)
        }
        else {
            XCTAssert(false)
        }
        
        // Nonce should be UUID
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworknonce?language=objc -- "The value for this key is an NSUUID."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkNonce] as? UUID {
            XCTAssert("\(value)".lowercased() == nonce.lowercased())
        }
        else {
            XCTAssert(false)
        }
        
        // Source app ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworksourceappstoreidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] as? NSNumber {
            XCTAssert("\(value)" == sourceapp)
        }
        else {
            XCTAssert(false)
        }
        
        // Timestamp should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworktimestamp?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber {
            XCTAssert("\(value)" == timestamp)
        }
        else {
            XCTAssert(false)
        }
        
        // Signature should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkattributionsignature?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkAttributionSignature] as? String {
            XCTAssert(value == signature)
        }
        else {
            XCTAssert(false)
        }
        
        // Fidelity type should be an NSNumber
        if let value = data?.clickDataDictionary["fidelity-type"] as? NSNumber {
            XCTAssert("\(value)" == fidelity)
        }
        else {
            XCTAssert(false)
        }
    }
    
    /// Tests that valid SKAdNetwork 2.2 clickthrough data with viewthrough data included initializes correctly
    func testValidClickthoughAndViewthroughInitialization22() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        let serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        guard let clickResponse = serverResponse[.clickResponse] as? [String: String],
              let version = clickResponse[.version],
              let network = clickResponse[.network],
              let campaign = clickResponse[.campaign],
              let itunesitem = clickResponse[.destinationAppStoreIdentifier],
              let nonce = clickResponse[.nonce],
              let sourceapp = clickResponse[.sourceAppStoreIdentifier],
              let timestamp = clickResponse[.timestamp],
              let signature = clickResponse[.signature],
              let fidelity = clickResponse[.fidelityType]
        else {
            XCTAssert(false)
            return
        }
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        XCTAssertNotNil(data?.impressionData)
        
        // Test click dictionary is populated correctly
        // Check data types compared to apple doc
        // Check that data is piped correctly into the dictionary
        
        // Version should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkversion?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkVersion] as? String {
            XCTAssert(value == version)
        }
        else {
            XCTAssert(false)
        }
        
        // Network ID should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkidentifier?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkIdentifier] as? String {
            XCTAssert(value == network)
        }
        else {
            XCTAssert(false)
        }
        
        // Network Campaign ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkcampaignidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkCampaignIdentifier] as? NSNumber {
            XCTAssert("\(value)" == campaign)
        }
        else {
            XCTAssert(false)
        }
        
        // Destination app ID should be NSNumber (note that this is intentionally inconsistent with source app ID)
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteritunesitemidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterITunesItemIdentifier] as? NSNumber {
            XCTAssert("\(value)" == itunesitem)
        }
        else {
            XCTAssert(false)
        }
        
        // Nonce should be UUID
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworknonce?language=objc -- "The value for this key is an NSUUID."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkNonce] as? UUID {
            XCTAssert("\(value)".lowercased() == nonce.lowercased())
        }
        else {
            XCTAssert(false)
        }
        
        // Source app ID should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworksourceappstoreidentifier?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] as? NSNumber {
            XCTAssert("\(value)" == sourceapp)
        }
        else {
            XCTAssert(false)
        }
        
        // Timestamp should be NSNumber
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworktimestamp?language=objc -- "The value for this key is an NSNumber."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkTimestamp] as? NSNumber {
            XCTAssert("\(value)" == timestamp)
        }
        else {
            XCTAssert(false)
        }
        
        // Signature should be String
        // From https://developer.apple.com/documentation/storekit/skstoreproductparameteradnetworkattributionsignature?language=objc -- "The value for this key is an NSString."
        if let value = data?.clickDataDictionary[SKStoreProductParameterAdNetworkAttributionSignature] as? String {
            XCTAssert(value == signature)
        }
        else {
            XCTAssert(false)
        }
        
        // Fidelity type should be an NSNumber
        if let value = data?.clickDataDictionary["fidelity-type"] as? NSNumber {
            XCTAssert("\(value)" == fidelity)
        }
        else {
            XCTAssert(false)
        }
        
        
        // Test impression data is populated correctly
        guard let impressionData = data?.impressionData else {
            XCTAssert(false)
            return
        }
        
        XCTAssert(impressionData.signature == signature)
        XCTAssert(impressionData.version == version)
        XCTAssert(impressionData.adNetworkIdentifier == network)
        XCTAssert("\(impressionData.adCampaignIdentifier)" == campaign)
        XCTAssert("\(impressionData.advertisedAppStoreItemIdentifier)" == itunesitem)
        XCTAssert(impressionData.adImpressionIdentifier == nonce) //NOTE: nonce is a string in SKAdImpression despite being a UUID in the click dictionary 🤪
        XCTAssert("\(impressionData.sourceAppStoreItemIdentifier)" == sourceapp)
        XCTAssert("\(impressionData.timestamp)" == timestamp)
    }
    
    /// Tests that clickmethod pipes through
    func testClickMethod() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        
        // With App Store clicks
        serverResponse[.clickMethod] = "0"
        let data1 = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data1)
        XCTAssertNotNil(data1?.impressionData)
        
        // Test that the clickmethod piped through
        XCTAssert(data1?.clickMethod == .interceptAppStoreClicks)
        
        // Again with all clicks
        serverResponse[.clickMethod] = "1"
        let data2 = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data2)
        XCTAssertNotNil(data2?.impressionData)
        
        // Test that the clickmethod piped through
        XCTAssert(data2?.clickMethod == .interceptAllClicks)
    }
    
    /// Tests clickMethod has a default
    func testClickMethodDefault() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickMethod] = nil
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        XCTAssertNotNil(data?.impressionData)
        
        // Test that the clickmethod defaulted to app store clicks
        XCTAssert(data?.clickMethod == .interceptAppStoreClicks)
    }
    
    /// Tests click trackers are piped through
    func testFilledClickTrackers() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        let clickTrackers = [
            "https://google.com",
            "https://mopub.com"
        ]
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickDisplayTrackers] = clickTrackers
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        XCTAssertNotNil(data?.impressionData)
        
        XCTAssert(data?.clickDisplayTrackers.count == clickTrackers.count)
        XCTAssert(data?.clickDisplayTrackers == clickTrackers)
    }
    
    /// Tests no click trackers results in an empty array
    func testUnfilledClickTrackers() throws {
        guard #available(iOS 14.5, *) else {
            return
        }
        
        var serverResponse = SKAdNetworkServerResponseFactory.vtaResponse22()
        serverResponse[.clickDisplayTrackers] = nil
        
        let data = SKAdNetworkData(serverResponse: serverResponse)
        XCTAssertNotNil(data)
        XCTAssertNotNil(data?.impressionData)
        
        XCTAssert(data?.clickDisplayTrackers.count == 0)
        XCTAssert(data?.clickDisplayTrackers == [])
    }
    
    //MARK: Helper methods
    
    /// Removes the entry at the given key in the "view" section of the response
    func removeViewEntry(for key: SKAdNetworkServerKey, from response: [String: Any]) -> [String: Any] {
        guard let viewResponse = response[.impressionResponse] as? [String: Any] else {
            return response
        }
        
        let newViewResponse = removeEntry(for: key, from: viewResponse)
        var modifiedResponse = response
        modifiedResponse[.impressionResponse] = newViewResponse
        
        return modifiedResponse
    }
    
    /// Removes the entry at the given key in the "click" section of the response
    func removeClickEntry(for key: SKAdNetworkServerKey, from response: [String: Any]) -> [String: Any] {
        guard let clickResponse = response[.clickResponse] as? [String: Any] else {
            return response
        }
        
        let newClickResponse = removeEntry(for: key, from: clickResponse)
        var modifiedResponse = response
        modifiedResponse[.clickResponse] = newClickResponse
        
        return modifiedResponse
    }
    
    /// Removes the entry at the given key from the given dictionary
    func removeEntry(for key: SKAdNetworkServerKey, from dictionary: [String: Any]) -> [String: Any] {
        var dictCopy = dictionary
        
        dictCopy[key] = nil
        
        return dictCopy
    }
}
