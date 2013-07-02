//
//  MPHTMLInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLInterstitialCustomEvent.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

@interface MPHTMLInterstitialCustomEvent ()

@property (nonatomic, retain) MPHTMLInterstitialViewController *interstitial;

@end

@implementation MPHTMLInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Loading MoPub HTML interstitial");
    MPAdConfiguration *configuration = [self.delegate configuration];
    CoreLogType(WBLogLevelTrace, WBLogTypeAdFullPage, @"Loading HTML interstitial with source: %@", [configuration adResponseHTMLString]);

    self.interstitial = [[MPInstanceProvider sharedProvider] buildMPHTMLInterstitialViewControllerWithDelegate:self
                                                                                               orientationType:configuration.orientationType
                                                                                          customMethodDelegate:[self.delegate interstitialDelegate]];
    [self.interstitial loadConfiguration:configuration];
}

- (void)dealloc
{
    [self.interstitial setDelegate:nil];
    [self.interstitial setCustomMethodDelegate:nil];
    self.interstitial = nil;
    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.interstitial presentInterstitialFromViewController:rootViewController];
}

#pragma mark - MPInterstitialViewControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"MoPub HTML interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"MoPub HTML interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub HTML interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub HTML interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub HTML interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub HTML interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub HTML interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
