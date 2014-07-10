//
//  ChartboostInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "WBAdService+Internal.h"
#import "Chartboost.h"

@interface ChartboostInterstitialCustomEvent() <ChartboostDelegate>

@end

@implementation ChartboostInterstitialCustomEvent

+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Chartboost startWithAppId:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdCB]
                      appSignature:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdCBSignature]
                          delegate:nil];
    });
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [Chartboost sharedChartboost].delegate = self;
    }
    return self;
}

-(void)invalidate
{
    [Chartboost sharedChartboost].delegate = nil;
}

#pragma mark - methods

-(NSString *)description
{
    return @"Chartboost";
}

+(void)trackInstall
{
    //initialize fires
}

-(void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    if([[Chartboost sharedChartboost]hasCachedInterstitial:CBLocationTurnComplete] == YES)
    {
        [self didCacheInterstitial:CBLocationTurnComplete];
    }
    else
    {
        [[Chartboost sharedChartboost] cacheInterstitial:CBLocationTurnComplete];
    }
}

-(void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [[Chartboost sharedChartboost] showInterstitial:CBLocationTurnComplete];
}

#pragma mark - ChartboostDelegate

// Called when an interstitial has been displayed on the screen.
- (void)didDisplayInterstitial:(CBLocation)location
{
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

/// Called when an interstitial has been received and cached.
- (void)didCacheInterstitial:(CBLocation)location
{
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

/// Called when an interstitial has failed to come back from the server
- (void)didFailToLoadInterstitial:(CBLocation)location  withError:(CBLoadError)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[NSError errorWithDomain:WBAdSDKDomain code:error userInfo:nil]];
}

/// Called when the user dismisses the interstitial
/// If you are displaying the add yourself, dismiss it now.
- (void)didDismissInterstitial:(CBLocation)location
{
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
