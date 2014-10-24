//
//  MPMRAIDInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"

@interface MPMRAIDInterstitialCustomEvent ()

@property (nonatomic, strong) MPMRAIDInterstitialViewController *interstitial;

@end

@implementation MPMRAIDInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.interstitial = [[MPInstanceProvider sharedProvider] buildMPMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
    [self.interstitial startLoading];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller
{
    [self.interstitial presentInterstitialFromViewController:controller];
}

-(NSString *)description
{
    return @"MoPub MRAID";
}

#pragma mark - MPMRAIDInterstitialViewControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (void)interstitialDidLoadAd:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)interstitialDidAppear:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitialWillDisappear:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDisappear:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialDidReceiveTapEvent:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)interstitialWillLeaveApplication:(MPInterstitialViewController *)interstitial
{
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

@end
