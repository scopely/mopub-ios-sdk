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
#import "MPConstants.h"

@interface MPHTMLBannerCustomEvent ()

@property (nonatomic, retain) MPAdWebViewAgent *bannerAgent;
@property (nonatomic, assign) WBLogType logType;

@end

@implementation MPHTMLBannerCustomEvent

@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    self.logType = (size.height == MOPUB_MEDIUM_RECT_SIZE.height ? WBLogTypeAdFullPage : WBLogTypeAdBanner);
    CoreLogType(WBLogLevelInfo, self.logType, @"Loading MoPub HTML %@", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    CoreLogType(WBLogLevelTrace, self.logType, @"Loading banner with HTML source: %@", [[self.delegate configuration] adResponseHTMLString]);

    CGRect adWebViewFrame = CGRectMake(0, 0, size.width, size.height);
    self.bannerAgent = [[MPInstanceProvider sharedProvider] buildMPAdWebViewAgentWithAdWebViewFrame:adWebViewFrame
                                                                                           delegate:self
                                                                               customMethodDelegate:[self.delegate bannerDelegate]];
    [self.bannerAgent loadConfiguration:[self.delegate configuration]];
}

- (void)dealloc
{
    self.bannerAgent.delegate = nil;
    self.bannerAgent.customMethodDelegate = nil;
    self.bannerAgent = nil;

    [super dealloc];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerAgent rotateToOrientation:newOrientation];
}

#pragma mark - MPAdWebViewAgentDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidFinishLoadingAd:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelInfo, self.logType, @"MoPub HTML %@ did load", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelFatal, self.logType, @"MoPub HTML %@ did fail", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(MPAdWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ will begin action", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ did finish action", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ will leave application", (self.logType == WBLogTypeAdBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end
