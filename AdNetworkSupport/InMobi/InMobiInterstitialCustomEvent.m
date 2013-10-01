//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "InMobiInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"
#import "WBAdService+Internal.h"
#import "InMobi+InitializeSdk.h"

@interface MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;

@end

@implementation MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId {
    IMInterstitial *inMobiInterstitial = [[[IMInterstitial alloc] initWithAppId:appId] autorelease];
    inMobiInterstitial.delegate = delegate;
    return inMobiInterstitial;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface InMobiInterstitialCustomEvent ()

@property (nonatomic, retain) IMInterstitial *inMobiInterstitial;

@end

@implementation InMobiInterstitialCustomEvent

@synthesize inMobiInterstitial = _inMobiInterstitial;

-(id)init
{
    self = [super init];
    if(self)
    {
        [InMobi inititializeSdk];
    }
    return self;
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Requesting InMobi interstitial");
    self.inMobiInterstitial = [[MPInstanceProvider sharedProvider] buildIMInterstitialWithDelegate:self appId:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdIM]];
    IMInMobiNetworkExtras *inmobiExtras = [[IMInMobiNetworkExtras alloc] init];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
    [paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    inmobiExtras.additionaParameters = paramsDict; // For supply source identification
    if (self.delegate.location) {
        [InMobi setLocationWithLatitude:self.delegate.location.coordinate.latitude
                               longitude:self.delegate.location.coordinate.longitude
                                accuracy:self.delegate.location.horizontalAccuracy];
    }
    [self.inMobiInterstitial addAdNetworkExtras:inmobiExtras];
    [self.inMobiInterstitial loadInterstitial];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.inMobiInterstitial presentInterstitialAnimated:YES];
}

- (void)dealloc
{
    [self.inMobiInterstitial setDelegate:nil];
    self.inMobiInterstitial = nil;
    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate


- (void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"InMobi interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {

    CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"InMobi banner did fail with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillPresentScreen:(IMInterstitial *)ad {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"InMobi interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];

    // InMobi doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error {
    CoreLogType(WBLogLevelError, WBLogTypeAdFullPage, @"InMobi interstitial failed to present with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillDismissScreen:(IMInterstitial *)ad {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"InMobi interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"InMobi interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"InMobi interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void) interstitialDidInteract:(IMInterstitial *)ad withParams:(NSDictionary *)dictionary {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"InMobi interstitial was tapped");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
