//
//  ChartboostInterstitialDelegate.m
//  WithBuddiesAds
//
//  Created by odyth on 9/11/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import "ChartboostInterstitialDelegate.h"
#import "ChartboostInterstitialCustomEvent.h"
#import "WBAdService+Internal.h"

@implementation ChartboostInterstitialDelegate

+(instancetype)sharedChartboostInterstitialDelegate
{
    static ChartboostInterstitialDelegate *_sharedChartboostInterstitialDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedChartboostInterstitialDelegate = [[ChartboostInterstitialDelegate alloc] init];
        [Chartboost startWithAppId:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdCB]
                      appSignature:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdCBSignature]
                          delegate:_sharedChartboostInterstitialDelegate];

    });
    return _sharedChartboostInterstitialDelegate;
}

-(void)trackInstall
{
    //initialize fires
}

#pragma mark - ChartboostDelegate

// Called when an interstitial has been displayed on the screen.
- (void)didDisplayInterstitial:(CBLocation)location
{
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEventWillAppear:self.chartboostInterstitialCustomEvent];
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEventDidAppear:self.chartboostInterstitialCustomEvent];
}

/// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(CBLocation)location
{
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEvent:self.chartboostInterstitialCustomEvent didLoadAd:nil];
}

/// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial:(CBLocation)location  withError:(CBLoadError)error
{
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEvent:self.chartboostInterstitialCustomEvent
                                                    didFailToLoadAdWithError:[NSError errorWithDomain:WBAdSDKDomain code:error userInfo:nil]];
}

/// Called when the user dismisses the interstitial
/// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(CBLocation)location
{
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEventWillDisappear:self.chartboostInterstitialCustomEvent];
    [self.chartboostInterstitialCustomEvent.delegate interstitialCustomEventDidDisappear:self.chartboostInterstitialCustomEvent];
}

@end
