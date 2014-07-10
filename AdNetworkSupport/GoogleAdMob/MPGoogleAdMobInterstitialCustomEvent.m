//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import "WBAdService+Internal.h"
#import <CoreLocation/CoreLocation.h>

#if (DEBUG || ADHOC)
#import "WBAdService+Debugging.h"
#endif

@interface MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;
- (GADRequest *)buildGADInterstitialRequest;

@end

@implementation MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[[GADInterstitial alloc] init] autorelease];
}

- (GADRequest *)buildGADInterstitialRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGoogleAdMobInterstitialCustomEvent ()

@property (nonatomic, retain) GADInterstitial *interstitial;
@property (nonatomic) BOOL ready;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.interstitial = [[MPInstanceProvider sharedProvider] buildGADInterstitialAd];

    NSString *adUnitID = info[WBAdUnitID];
#if (DEBUG || ADHOC)
    
    if([[WBAdService sharedAdService] forcedAdNetwork] == WBAdNetworkAM)
    {
        adUnitID = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdAM];
    }
    
#endif

    self.interstitial.adUnitID = adUnitID;
    self.interstitial.delegate = self;

    GADRequest *request = [[MPInstanceProvider sharedProvider] buildGADInterstitialRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of devices that will receive test ads.
    // See: http://code.google.com/mobile/ads/docs/ios/intermediate.html#testdevices
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,
                           // more UDIDs here,
                           nil];

    [self.interstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    [super dealloc];
}

-(NSString *)description
{
    return @"AdMob";
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    self.ready = YES;
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
