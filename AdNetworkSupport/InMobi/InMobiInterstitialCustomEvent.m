//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub, Inc. All rights reserved.
//

#import <WithBuddiesAds/WithBuddiesAds.h>
#import "WBAdService+Internal.h"
#import "IMInterstitial.h"
#import "IMInterstitialDelegate.h"
#import "InMobiInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"

static NSString *gAppId = nil;

#define kInMobiAppID    @"YOUR_INMOBI_APP_ID"

@interface MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;

@end

@implementation MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId {
    IMInterstitial *inMobiInterstitial = [[IMInterstitial alloc] initWithAppId:appId];
    inMobiInterstitial.delegate = delegate;
    return inMobiInterstitial;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface InMobiInterstitialCustomEvent () <IMInterstitialDelegate>

@property (nonatomic, strong) IMInterstitial *inMobiInterstitial;

@end

@implementation InMobiInterstitialCustomEvent

@synthesize inMobiInterstitial = _inMobiInterstitial;

+ (void)setAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    AdLogType(WBAdLogLevelInfo, WBAdTypeInterstitial, @"Requesting InMobi interstitial");

    NSString *appId = gAppId;
    if ([appId length] == 0) {
        appId = kInMobiAppID;
    }

    self.inMobiInterstitial = [[MPInstanceProvider sharedProvider] buildIMInterstitialWithDelegate:self appId:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdIM]];
    NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    self.inMobiInterstitial.additionaParameters = paramsDict; // For supply source identification
    if (self.delegate.location) {
        [InMobi setLocationWithLatitude:self.delegate.location.coordinate.latitude
                              longitude:self.delegate.location.coordinate.longitude
                               accuracy:self.delegate.location.horizontalAccuracy];
    }
    [self.inMobiInterstitial loadInterstitial];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.inMobiInterstitial presentInterstitialAnimated:YES];
}

- (void)dealloc
{
    [self.inMobiInterstitial setDelegate:nil];
}

-(NSString *)description
{
    return @"InMobi";
}

#pragma mark - IMAdInterstitialDelegate


- (void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(IMInterstitial *)ad {

    [self.delegate interstitialCustomEventWillAppear:self];

    // InMobi doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillDismissScreen:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void) interstitialDidInteract:(IMInterstitial *)ad withParams:(NSDictionary *)dictionary {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
