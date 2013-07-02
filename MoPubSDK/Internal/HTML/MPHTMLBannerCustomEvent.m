//
//  MPHTMLBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPHTMLBannerCustomEvent.h"
#import "MPAdWebView.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

@interface MPHTMLBannerCustomEvent ()

@property (nonatomic, retain) MPAdWebViewAgent *bannerAgent;

@end

@implementation MPHTMLBannerCustomEvent

@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdBanner, @"Loading MoPub HTML banner");
    CoreLogType(WBLogLevelTrace, WBLogTypeAdBanner, @"Loading banner with HTML source: %@", [[self.delegate configuration] adResponseHTMLString]);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPInstanceProvider sharedProvider] buildMPAdWebViewAgentWithAdWebViewFrame:adWebViewFrame
                                                                                           delegate:self
                                                                               customMethodDelegate:[self.delegate bannerDelegate]];
    [self.bannerAgent loadConfiguration:[self.delegate configuration]];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
    self.bannerAgent = nil;

    [super dealloc];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerAgent rotateToOrientation:newOrientation];
}

#pragma mark - MPAdWebViewAgentDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidFinishLoadingAd:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelInfo, WBLogTypeAdBanner, @"MoPub HTML banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"MoPub HTML banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(MPAdWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"MoPub HTML banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"MoPub HTML banner did finish action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"MoPub HTML banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end
