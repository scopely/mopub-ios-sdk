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

@dynamic delegate;
@synthesize interstitial = _interstitial;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.interstitial = [[MPInstanceProvider sharedProvider] buildMPMRAIDInterstitialViewControllerWithDelegate:self
                                                                                                  configuration:[self.delegate configuration]];

    // The MRAID ad view will handle the close button so we don't need the MPInterstitialViewController's close button.
    [self.interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAlwaysHidden];
    [self.interstitial startLoading];
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

    // Deallocate the interstitial as we don't need it anymore. If we don't deallocate the interstitial after dismissal,
    // then the html in the webview will continue to run which could lead to bugs such as continuing to play the sound of an inline
    // video since the app may hold onto the interstitial ad controller. Moreover, we keep an array of controllers around as well.
    self.interstitial = nil;
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
