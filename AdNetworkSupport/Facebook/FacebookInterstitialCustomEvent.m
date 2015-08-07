//
//  FacebookInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "WBAdService+Internal.h"

#if (DEBUG || ADHOC)
#import "WBAdService+Debugging.h"
#endif
@interface MPInstanceProvider (FacebookInterstitials)

- (FBInterstitialAd *)buildFBInterstitialAdWithPlacementID:(NSString *)placementID
                                                  delegate:(id<FBInterstitialAdDelegate>)delegate;

@end

@implementation MPInstanceProvider (FacebookInterstitials)

- (FBInterstitialAd *)buildFBInterstitialAdWithPlacementID:(NSString *)placementID
                                                  delegate:(id<FBInterstitialAdDelegate>)delegate
{
    FBInterstitialAd *interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:placementID];
    interstitialAd.delegate = delegate;
    return interstitialAd;
}

@end

@interface FacebookInterstitialCustomEvent () <FBInterstitialAdDelegate>

@property (nonatomic, strong) FBInterstitialAd *fbInterstitialAd;

@end

@implementation FacebookInterstitialCustomEvent

-(NSString *)description
{
    return @"Facebook";
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *placementId = [info objectForKey:@"placement_id"] ?: [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdFB];
    
    if (placementId == nil) {
        CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"Placement ID is required for Facebook interstitial ad");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    self.fbInterstitialAd =
        [[MPInstanceProvider sharedProvider] buildFBInterstitialAdWithPlacementID:placementId
                                                                        delegate:self];
    [self.fbInterstitialAd loadAd];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    if (!self.fbInterstitialAd || !self.fbInterstitialAd.isAdValid) {
        [self.delegate interstitialCustomEventDidExpire:self];
    } else {
        [self.delegate interstitialCustomEventWillAppear:self];
        [self.fbInterstitialAd showAdFromRootViewController:controller];
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

- (void)dealloc
{
    _fbInterstitialAd.delegate = nil;
}

#pragma mark FBInterstitialAdDelegate methods

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    [self.delegate interstitialCustomEvent:self didLoadAd:interstitialAd];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

@end
