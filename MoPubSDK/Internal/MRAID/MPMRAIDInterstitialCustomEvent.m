//
//  MPMRAIDInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"

@interface MPMRAIDInterstitialCustomEvent ()

@property (nonatomic, retain) MPMRAIDInterstitialViewController *interstitial;

@end

@implementation MPMRAIDInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Loading MoPub MRAID interstitial");
    self.interstitial = [[MPInstanceProvider sharedProvider] buildMPMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
    [self.interstitial startLoading];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;

    [super dealloc];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller
{
    [self.interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - MPMRAIDInterstitialViewControllerDelegate

- (void)interstitialDidLoadAd:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"MoPub MRAID interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"MoPub MRAID interstitial did fail");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub MRAID interstitial will appear");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub MRAID interstitial did appear");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub MRAID interstitial will disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub MRAID interstitial did disappear");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewController *)interstitial
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"MoPub MRAID interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
