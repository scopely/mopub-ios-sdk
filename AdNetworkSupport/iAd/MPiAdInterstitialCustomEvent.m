//
//  MPiAdInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPiAdInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"

@interface MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd;

@end

@implementation MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd
{
    return [[[ADInterstitialAd alloc] init] autorelease];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPiAdInterstitialCustomEvent ()

@property (nonatomic, retain) ADInterstitialAd *iAdInterstitial;
@property (nonatomic, assign) BOOL isOnScreen;

@end

@implementation MPiAdInterstitialCustomEvent

@synthesize iAdInterstitial = _iAdInterstitial;
@synthesize isOnScreen = _isOnScreen;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Requesting iAd interstitial");

    self.iAdInterstitial = [[MPInstanceProvider sharedProvider] buildADInterstitialAd];
    self.iAdInterstitial.delegate = self;
}

- (void)dealloc {
    self.iAdInterstitial.delegate = nil;
    self.iAdInterstitial = nil;
    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    // ADInterstitialAd throws an exception if we don't check the loaded flag prior to presenting.
    if (self.iAdInterstitial.loaded) {
        [self.delegate interstitialCustomEventWillAppear:self];
        [self.iAdInterstitial presentFromViewController:controller];
        self.isOnScreen = YES;
        [self.delegate interstitialCustomEventDidAppear:self];
    } else {
        CoreLogType(WBLogLevelError, WBLogTypeAdFullPage, @"Failed to show iAd interstitial: a previously loaded iAd interstitial now claims not to be ready.");
    }
}

-(NSString *)description
{
    return @"iAd";
}

- (void)interstitialAdDismissed
{
    if (self.isOnScreen) {
        [self.delegate interstitialCustomEventWillDisappear:self];
        [self.delegate interstitialCustomEventDidDisappear:self];
        self.isOnScreen = NO; //technically not necessary as iAd interstitials are single use
    }
}

#pragma mark - <ADInterstitialAdDelegate>

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    [self.delegate interstitialCustomEvent:self didLoadAd:self.iAdInterstitial];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    // This method may be called whether the ad is on-screen or not. We only want to invoke the
    // "disappear" callbacks if the ad is on-screen.
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"iAd interstitial did unload");

    [self interstitialAdDismissed];

    // ADInterstitialAd can't be shown again after it has unloaded, so notify the controller.
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd
                   willLeaveApplication:(BOOL)willLeave {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    return YES; // YES allows the action to execute (NO would instead cancel the action).
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"iAd interstitial did finish");

    [self interstitialAdDismissed];
}

@end
