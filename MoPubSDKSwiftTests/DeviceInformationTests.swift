//
//  DeviceInformationTests.swift
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

class DeviceInformationTests: XCTestCase {
    // MARK: - UserDefaults Keys
    
    struct UserDefaultsKey {
        /// Ad unit ID used for consent.
        /// - Note: This must correspond to `kAdUnitIdUsedForConsentStorageKey`
        static let consentAdUnitId: String = "com.mopub.mopub-ios-sdk.consent.ad.unit.id"
        
        /// ATT last authorization status.
        /// - Note: This must correspond to `kLastATTAuthorizationStatusStorageKey`
        static let consentATTLastAuthorizationStatus: String = "com.mopub.mopub-ios-sdk.last.ATT.authorization.status"
        
        /// Force GDPR applies.
        /// - Note: This must correspond to `kForceGDPRAppliesStorageKey`
        static let consentForceGdprApplies: String = "com.mopub.mopub-ios-sdk.gdpr.force.applies.true"
        
        /// GDPR applies.
        /// - Note: This must correspond to `kGDPRAppliesStorageKey`
        static let consentGdprApplies: String = "com.mopub.mopub-ios-sdk.gdpr.applies"
        
        /// Consented IAB vendor list.
        /// - Note: This must correspond to `kConsentedIabVendorListStorageKey`
        static let consentIabVendorList: String = "com.mopub.mopub-ios-sdk.consented.iab.vendor.list"
        
        /// IFA used for consent.
        /// - Note: This must correspond to `kIfaForConsentStorageKey`
        static let consentIfa: String = "com.mopub.mopub-ios-sdk.ifa.for.consent"
        
        /// Indicates if publisher is whitelisted for consent.
        /// - Note: This must correspond to `kIsWhitelistedStorageKey`
        static let consentIsWhiteListed: String = "com.mopub.mopub-ios-sdk.is.whitelisted"
        
        /// Indicates that consent is in a do not track state.
        /// - Note: This must correspond to `kIsDoNotTrackStorageKey`
        static let consentIsDoNotTrack: String = "com.mopub.mopub-ios-sdk.is.do.not.track"
        
        /// Last changed timestamp in milliseconds.
        /// - Note: This must correspond to `kLastChangedMsStorageKey`
        static let consentLastChangedMilliseconds: String = "com.mopub.mopub-ios-sdk.last.changed.ms"
        
        /// Reason for last consent change.
        /// - Note: This must correspond to `kLastChangedReasonStorageKey`
        static let consentLastChangedReason: String = "com.mopub.mopub-ios-sdk.last.changed.reason"
        
        /// Consented privacy policy version.
        /// - Note: This must correspond to `kConsentedPrivacyPolicyVersionStorageKey`
        static let consentPrivacyPolicyVersion: String = "com.mopub.mopub-ios-sdk.consented.privacy.policy.version"
        
        /// Indicates of consent should be reacquired.
        /// - Note: This must correspond to `kShouldReacquireConsentStorageKey`
        static let consentShouldReacquireConsent: String = "com.mopub.mopub-ios-sdk.should.reacquire.consent"
        
        /// Current consent status.
        /// - Note: This must correspond to `kConsentStatusStorageKey`
        static let consentStatus: String = "com.mopub.mopub-ios-sdk.consent.status"
        
        /// Consented vendor list version.
        /// - Note: This must correspond to `kConsentedVendorListVersionStorageKey`
        static let consentVendorListVersion: String = "com.mopub.mopub-ios-sdk.consented.vendor.list.version"
        
        /// MoPub identifier.
        /// - Note: This must correspond to `DeviceInformation.UserDefaultsKey.mopubIdentifier`
        static let mopubIdentifier: String = "com.mopub.identifier"
        
        /// Timestamp of when the MoPub identifier was last set. This was used prior to SDK version 5.14.0
        /// to keep track of when to rotate the MoPub identifier.
        /// - Note: This must correspond to `DeviceInformation.UserDefaultsKey.deprecatedMoPubIdentifierLastSet`
        static let mopubIdentifierLastSet: String = "com.mopub.identifiertime"
    }
    
    // MARK: - Constants
    
    struct Constants {
        /// 10 second test timeout.
        static let timeout: TimeInterval = 10.0
    }

    // MARK: - Test Setup
    
    /// Reset consent manager for testing
    func setUpConsentManagerForTesting() {
        let defaults = UserDefaults.standard
        defaults.setValue(nil, forKey: UserDefaultsKey.consentAdUnitId)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentIabVendorList)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentPrivacyPolicyVersion)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentVendorListVersion)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentStatus)
        defaults.setValue(MPBool.unknown.rawValue, forKey: UserDefaultsKey.consentGdprApplies)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentIfa)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentIsDoNotTrack)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentLastChangedMilliseconds)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentLastChangedReason)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentShouldReacquireConsent)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentForceGdprApplies)
        defaults.setValue(nil, forKey: UserDefaultsKey.consentATTLastAuthorizationStatus)
        defaults.setValue(true, forKey: UserDefaultsKey.consentIsWhiteListed)
        
        // Clear out overridden properties
        DeviceInformation.mockRawIfa = nil
        
        // Set a fake ad unit ID for Consent
        MPConsentManager.shared().adUnitIdUsedForConsent = "fake_adunit_id"
    }
    
    /// Reset location-based testing properties
    func setUpLocationForTesting() {
        DeviceInformation.enableLocation = true
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .notDetermined
        DeviceInformation.clearCachedLastLocation()
    }
    
    override func setUpWithError() throws {
        // Make sure the UserDefaults entries are removed
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.mopubIdentifier)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.mopubIdentifierLastSet)
        
        // Clear consent
        setUpConsentManagerForTesting()
        
        // Setup location-based properties
        setUpLocationForTesting()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // MARK: - Connectivity

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.notReachable` if `reachabilityFlags`
    /// does not include `.reachable` and the `CellularService` instance returns `.notReachable`
    func testCurrentNetworkStatusNotReachable() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .notReachable)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .notReachable)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.notReachable` if `reachabilityFlags`
    ///  does not include `.reachable` even though the `CellularService` instance returns `.reachableViaWiFi`
    func testCurrentNetworkStatusNotReachableWhenUsingWiFi() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaWiFi)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .notReachable)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaWiFi` only when `reachabilityFlags`
    /// includes `.reachable` and the `CellularService` instance returns `.reachableViaWiFi`
    func testCurrentNetworkStatusReachableViaWiFi() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaWiFi)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaWiFi)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetworkUnknownGeneration`
    /// only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetworkUnknownGeneration`
    func testCurrentNetworkStatusReachableViaUnknownGeneration() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetworkUnknownGeneration)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetworkUnknownGeneration)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork2G`
    /// only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork2G`
    func testCurrentNetworkStatusReachableViaCellularNetwork2G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork2G)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork2G)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork3G`
    /// only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork3G`
    func testCurrentNetworkStatusReachableViaCellularNetwork3G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork3G)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork3G)
    }

    /// Tests that the `currentNetworkStatus` provided by `DeviceInformation` is `.reachableViaCellularNetwork4G`
    ///  only when `reachabilityFlags` includes `.reachable` and `.isWWAN`, and the `CellularService` instance returns `.reachableViaCellularNetwork4G`
    func testCurrentNetworkStatusReachableViaCellularNetwork4G() throws {
        // Setup preconditions
        DeviceInformation.mockReachability = MockNetworkReachable([.reachable, .isWWAN])
        DeviceInformation.mockCellularService = MockCellularService(currentRadioAccessTechnology: .reachableViaCellularNetwork4G)

        // Validate
        let currentNetworkStatus = DeviceInformation.currentNetworkStatus
        XCTAssert(currentNetworkStatus == .reachableViaCellularNetwork4G)
    }

    // MARK: - IFA

    /// Verifies that the `ifa` property is `nil` when the user has not explicity granted consent.
    func testNoIfaWhenNoConsent() throws {
        // Preconditions
        if #available(iOS 14.0, *) {
            AdvertisingTrackingAuthorization.mockStatus = .authorized
        }

        // Enforce GDPR, but do not grant consent.
        DeviceInformation.mockRawIfa = "some_real_ifa"
        MPConsentManager.shared().forceIsGDPRApplicable = true
        XCTAssertTrue(MPConsentManager.shared().currentStatus == .unknown)

        // Retrieve the IFA
        let ifa = DeviceInformation.ifa
        XCTAssertNil(ifa)
    }

    /// Verifies that the `ifa` property is valid even when the user has denied tracking authorization.
    /// This ensures that even if APIs change in the future, the IFA will always be included when available.
    /// iOS will restrict access when it is not available.
    func testIfaWhenNotAllowedToTrack() throws {
        // Preconditions
        if #available(iOS 14.0, *) {
            AdvertisingTrackingAuthorization.mockStatus = .denied
        }

        // Enforce GDPR and grant consent.
        DeviceInformation.mockRawIfa = "some_real_ifa"
        MPConsentManager.shared().forceIsGDPRApplicable = true
        MPConsentManager.shared().grantConsent()
        XCTAssertTrue(MPConsentManager.shared().currentStatus == .consented)

        // Retrieve the IFA
        let ifa = DeviceInformation.ifa
        XCTAssertNotNil(ifa)
        XCTAssertTrue(ifa == "some_real_ifa")
    }

    /// Verifies that the `ifa` property is valid when the user has authorized tracking and consented.
    func testIfaWhenAllowedAndConsented() throws {
        // Preconditions
        if #available(iOS 14.0, *) {
            AdvertisingTrackingAuthorization.mockStatus = .authorized
        }

        // Enforce GDPR and grant consent.
        DeviceInformation.mockRawIfa = "some_real_ifa"
        MPConsentManager.shared().forceIsGDPRApplicable = true
        MPConsentManager.shared().grantConsent()
        XCTAssertTrue(MPConsentManager.shared().currentStatus == .consented)

        // Retrieve the IFA
        let ifa = DeviceInformation.ifa
        XCTAssertNotNil(ifa)
        XCTAssertTrue(ifa == "some_real_ifa")
    }

    // MARK: - IFV

    /// Verifies that the IFV exists
    func testIfvExists() throws {
        let ifv = DeviceInformation.ifv
        XCTAssertNotNil(ifv)
    }
    
    // MARK: - Location
    
    /// Verifies that `locationAuthorizationStatus` returns `.notDetermined` when the CLLocationManager is reporting its authorization status as `.notDetermined`
    func testLocationAuthorizationStatusNotDetermined() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .notDetermined
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .notDetermined)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.restricted` when the CLLocationManager is reporting its authorization status as `.restricted`
    func testLocationAuthorizationStatusRestricted() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .restricted
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .restricted)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.userDenied` when the CLLocationManager is reporting its authorization status as `.denied` and location services are enabled
    func testLocationAuthorizationStatusUserDenied() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .denied
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .userDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.settingsDenied` when the CLLocationManager is reporting its authorization status as `.denied` and location services are not enabled
    func testLocationAuthorizationStatusSettingsDenied() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = false
        DeviceInformation.mockLocationManagerAuthorizationStatus = .denied
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .settingsDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.publisherDenied` when the CLLocationManager is reporting its authorization status as `.authorizedAlways`
    func testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedAlways() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedAlways
        DeviceInformation.enableLocation = false
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .publisherDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.publisherDenied` when the CLLocationManager is reporting its authorization status as `.authorizedWhenInUse`
    func testLocationAuthorizationStatusPublisherDeniedWhenAuthorizedWhenInUse() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        DeviceInformation.enableLocation = false
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .publisherDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.userDenied` when the CLLocationManager is reporting its authorization status as `.denied`, location services are enabled, but the `enableLocation` flag indicates that location services can not be queried (i.e. user denied takes priority over publisher denied)
    func testLocationAuthorizationStatusUserDeniedTakesPriorityOverPublisherDenied() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .denied
        DeviceInformation.enableLocation = false
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .userDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.settingsDenied` when the CLLocationManager is reporting its authorization status as `.denied`, location services are not enabled, the `enableLocation` flag indicates that location services can not be queried (i.e. settings denied takes priority over publisher denied)
    func testLocationAuthorizationStatusSettingsDeniedTakesPriorityOverPublisherDenied() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = false
        DeviceInformation.mockLocationManagerAuthorizationStatus = .denied
        DeviceInformation.enableLocation = false
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .settingsDenied)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.authorizedAlways` when the CLLocationManager is reporting its authorization status as `.authorizedAlways`
    func testLocationAuthorizationStatusAlwaysAuthorized() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedAlways
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .authorizedAlways)
    }

    /// Verifies that `locationAuthorizationStatus` returns `.authorizedWhenInUse` when the CLLocationManager is reporting its authorization status as `.authorizedWhenInUse`
    func testLocationAuthorizationStatusWhileInUseAuthorized() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        // Validate
        let status = DeviceInformation.locationAuthorizationStatus
        XCTAssertTrue(status == .authorizedWhenInUse)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location
    func testLastLocationNil() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, and properly returns `lastLocation` after the CLLocationManager provides a non-nil location
    func testLastLocationNilToSpecified() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, properly returns `lastLocation` after the CLLocationManager provides a non-nil valid location (according to the CLLocation timestamp), and does not update `lastLocation` when the CLManager provides an out of date location
    func testLastLocationSpecifiedNotUpdatedBecauseOutOfDate() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
        
        // Location updated again to an out of date value
        let timestampSevenDaysAgo = timestamp.addingTimeInterval(-7*24*60*60)
        let badLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 14, horizontalAccuracy: 20, verticalAccuracy: 20, timestamp: timestampSevenDaysAgo)
        XCTAssertNotNil(badLocation)
        
        mockManager.location = badLocation
        
        // Validate no update
        guard let anotherFetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(anotherFetchedLocation.altitude == 17)
        XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
    }
    
    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, properly returns `lastLocation` after the CLLocationManager provides a non-nil valid location (according to the CLLocation timestamp), and does not update `lastLocation` when the CLManager provides a CLLocation instance with an invalid horizontal accuracy
    func testLastLocationSpecifiedNotUpdatedBecauseHorizontalAccuracyInvalid() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
        
        // Location updated again to an invalid value
        let newTimestamp = Date()
        let badLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 14, horizontalAccuracy: -1, verticalAccuracy: 20, timestamp: newTimestamp)
        XCTAssertNotNil(badLocation)
        
        mockManager.location = badLocation
        
        // Validate no update
        guard let anotherFetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(anotherFetchedLocation.altitude == 17)
        XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, properly returns `lastLocation` after the CLLocationManager provides a non-nil valid location (according to the CLLocation timestamp), and does not update `lastLocation` when the CLManager is updated with a nil location
    func testLastLocationSpecifiedNotUpdatedBecauseNil() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
        
        // Location updated again to nil
        mockManager.location = nil
        
        // Validate no update
        guard let anotherFetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertNotNil(anotherFetchedLocation)
        XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(anotherFetchedLocation.altitude == 17)
        XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, properly returns `lastLocation` after the CLLocationManager provides a non-nil valid location (according to the CLLocation timestamp), and updates `lastLocation` when the CLManager is updated with another valid location
    func testLastLocationSpecifiedUpdated() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }

        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
        
        // Location updated again to a valid location
        let newTimestamp = Date()
        let anotherGoodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.8269775, -122.440465), altitude: 14, horizontalAccuracy: 20, verticalAccuracy: 20, timestamp: newTimestamp)
        XCTAssertNotNil(anotherGoodLocation)
        
        mockManager.location = anotherGoodLocation
        
        // Validate no update
        guard let anotherFetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(anotherFetchedLocation.coordinate.latitude == 37.8269775)
        XCTAssertTrue(anotherFetchedLocation.coordinate.longitude == -122.440465)
        XCTAssertTrue(anotherFetchedLocation.altitude == 14)
        XCTAssertTrue(anotherFetchedLocation.horizontalAccuracy == 20)
        XCTAssertTrue(anotherFetchedLocation.verticalAccuracy == 20)
        XCTAssertTrue(anotherFetchedLocation.timestamp.timeIntervalSince1970 == newTimestamp.timeIntervalSince1970)
    }

    /// Verifies that `lastLocation` returns nil when the CLLocationManager is reporting a nil location, properly returns `lastLocation` after the CLLocationManager provides a non-nil valid location (according to the CLLocation timestamp), and provides a nil `lastLocation` and `.publisherDenied` status if publisher then disables location
    func testLocationNilWhenPublisherDisablesLocation() {
        // Setup preconditions
        DeviceInformation.mockLocationManagerLocationServiceEnabled = true
        DeviceInformation.mockLocationManagerAuthorizationStatus = .authorizedWhenInUse
        
        let mockManager = MockLocationManager()
        mockManager.location = nil
        DeviceInformation.mockLocationManager = mockManager
        
        // Validate
        XCTAssertNil(DeviceInformation.lastLocation)
        
        // Location updated to a good value
        let timestamp = Date()
        let goodLocation = CLLocation(coordinate: CLLocationCoordinate2DMake(37.7764685, -122.4193891), altitude: 17, horizontalAccuracy: 10, verticalAccuracy: 10, timestamp: timestamp)
        XCTAssertNotNil(goodLocation)
        
        mockManager.location = goodLocation
        
        // Validate update
        guard let fetchedLocation = DeviceInformation.lastLocation else {
            XCTAssert(false)
            return
        }
        
        XCTAssertTrue(fetchedLocation.coordinate.latitude == 37.7764685)
        XCTAssertTrue(fetchedLocation.coordinate.longitude == -122.4193891)
        XCTAssertTrue(fetchedLocation.altitude == 17)
        XCTAssertTrue(fetchedLocation.horizontalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.verticalAccuracy == 10)
        XCTAssertTrue(fetchedLocation.timestamp.timeIntervalSince1970 == timestamp.timeIntervalSince1970)
        
        // Publisher disables location
        DeviceInformation.enableLocation = false
        
        // Fetch location again
        let newlyFetchedLocation = DeviceInformation.lastLocation
        XCTAssertNil(newlyFetchedLocation)
        XCTAssertTrue(DeviceInformation.locationAuthorizationStatus == .publisherDenied)
    }

    // MARK: - MoPub Identifier

    /// Verifies that a MoPub identifier will be automatically generated if it doesn't exist.
    func testGenerateMoPubIdentifier() throws {
        let mopubId = DeviceInformation.mopubIdentifier
        XCTAssertNotNil(mopubId)
        XCTAssertNotNil(UserDefaults.standard.string(forKey: UserDefaultsKey.mopubIdentifier))
        XCTAssertNil(UserDefaults.standard.object(forKey: UserDefaultsKey.mopubIdentifierLastSet))
    }

    /// Verifies that the MoPub identifier follows the expected UUID pattern of `68753A44-4D6F-1226-9C60-0050E4C00067`.
    func testMoPubIdentifierFormat() throws {
        // MoPub Identifier using `UUID` should match the standard format for UUIDs
        // represented in ASCII is a string punctuated by hyphens.
        // For example 68753A44-4D6F-1226-9C60-0050E4C00067.
        let mopubIdPattern = "[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}"

        // Retrieve MoPub identifier
        let mopubId = DeviceInformation.mopubIdentifier
        XCTAssertNotNil(mopubId)

        // Verify the MoPub identifier with the regular expression.
        guard let regex = try? NSRegularExpression(pattern: mopubIdPattern, options: []) else {
            XCTFail("\(mopubId) does not match the UUID regex")
            return
        }

        let matches = regex.matches(in: mopubId, options: [], range: NSRange(location: 0, length: mopubId.count))
        XCTAssert(matches.count == 1)
    }

    /// Verifies the legacy format MoPub identifiers are upgraded to the new format without the `mopub:` prefix.
    func testUpgradeOldMoPubIdentifierFormat() throws {
        // Setup legacy MoPub identifier
        let now = Date()
        UserDefaults.standard.setValue("mopub:11E8F75F-B0AE-461B-810C-18BF5EA59C71", forKey: UserDefaultsKey.mopubIdentifier)
        UserDefaults.standard.setValue(now, forKey: UserDefaultsKey.mopubIdentifierLastSet)

        // Retrieving MoPub identifier will automatically upgrade
        let mopubId = DeviceInformation.mopubIdentifier
        XCTAssertNotNil(mopubId)
        XCTAssertTrue(mopubId == "11E8F75F-B0AE-461B-810C-18BF5EA59C71")
        XCTAssertNil(UserDefaults.standard.object(forKey: UserDefaultsKey.mopubIdentifierLastSet))
    }
}
