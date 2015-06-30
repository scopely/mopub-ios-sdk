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
#import "WBAdLogging.h"

@interface MPHTMLBannerCustomEvent ()

@property (nonatomic, assign) WBAdType logType;
@property (nonatomic, strong) MPAdWebViewAgent *bannerAgent;

@end

@implementation MPHTMLBannerCustomEvent

@dynamic delegate;
@synthesize bannerAgent = _bannerAgent;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    self.logType = (size.height == MOPUB_MEDIUM_RECT_SIZE.height ? WBAdTypeInterstitial : WBAdTypeBanner);
    CoreLogType(WBLogLevelInfo, self.logType, @"Loading MoPub HTML %@", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
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
}

-(NSString *)description
{
    return @"MPHTML";
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
    CoreLogType(WBLogLevelInfo, self.logType, @"MoPub HTML %@ did load", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEvent:self didLoadAd:ad];
}

- (void)adDidFailToLoadAd:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelFatal, self.logType, @"MoPub HTML %@ did fail", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adDidClose:(MPAdWebView *)ad
{
    //don't care
}

- (void)adActionWillBegin:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ will begin action", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adActionDidFinish:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ did finish action", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adActionWillLeaveApplication:(MPAdWebView *)ad
{
    CoreLogType(WBLogLevelDebug, self.logType, @"MoPub HTML %@ will leave application", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"));
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}


@end
