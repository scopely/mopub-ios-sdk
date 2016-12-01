//
//  MPGoogleAdMobInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import <CoreLocation/CoreLocation.h>
#import "WBAdEvent_Internal.h"

@interface MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;
- (GADRequest *)buildGADInterstitialRequest;

@end

@implementation MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[GADInterstitial alloc] init];
}

- (GADRequest *)buildGADInterstitialRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGoogleAdMobInterstitialCustomEvent () <GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation MPGoogleAdMobInterstitialCustomEvent

@synthesize interstitial = _interstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Google AdMob interstitial");
    self.interstitial = [[MPInstanceProvider sharedProvider] buildGADInterstitialAd];

    self.interstitial.adUnitID = [info objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    GADRequest *request = [[MPInstanceProvider sharedProvider] buildGADInterstitialRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of device IDs that will receive test ads.
    // Running in the simulator will automatically show test ads.
    request.testDevices = @[/*more UDIDs here*/];

    request.requestAgent = @"MoPub";

    [self.interstitial loadRequest:request];
    
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeRequest
                                              failureReason:WBAdFailureReasonNone
                                                  adNetwork:[self description]
                                                     adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentFromRootViewController:rootViewController];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

-(NSString *)description
{
    // provide this for analytics
    return @"Google";
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    MPLogInfo(@"Google AdMob Interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeLoaded
                                              failureReason:WBAdFailureReasonNone
                                                  adNetwork:[self description]
                                                     adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];
}

- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    MPLogInfo(@"Google AdMob Interstitial failed to load with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeFailure
                                              failureReason:WBAdFailureReasonNoFill
                                                  adNetwork:[self description]
                                                     adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    MPLogInfo(@"Google AdMob Interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeShow
                                              failureReason:WBAdFailureReasonNone
                                                  adNetwork:[self description]
                                                     adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];
    event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeImpression
                                   failureReason:WBAdFailureReasonNone
                                       adNetwork:[self description]
                                          adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeDismissed
                                              failureReason:WBAdFailureReasonNone
                                                  adNetwork:[self description]
                                                     adType:WBAdTypeInterstitial backfill:NO];
    [WBAdEvent postNotification:event];

}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    MPLogInfo(@"Google AdMob Interstitial will leave application");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
