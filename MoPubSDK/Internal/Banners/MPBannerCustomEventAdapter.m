//
//  MPBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBannerCustomEventAdapter.h"

#import "MPAdConfiguration.h"
#import "MPBannerCustomEvent.h"
#import "MPInstanceProvider.h"

#import "WBAdEvent_Internal.h"
#import "WBAdControllerEvent.h"

@interface MPBannerCustomEventAdapter ()

@property (nonatomic, retain) MPBannerCustomEvent *bannerCustomEvent;
@property (nonatomic, retain) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

- (void)trackClickOnce;

@end

@implementation MPBannerCustomEventAdapter
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

- (void)dealloc {
    [_bannerCustomEvent invalidate];
    _bannerCustomEvent.delegate = nil;
    [_bannerCustomEvent release];
    [_configuration release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    CoreLogType(WBLogLevelDebug, configuration.logType, @"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.bannerCustomEvent = [[MPInstanceProvider sharedProvider] buildBannerCustomEventFromCustomClass:configuration.customEventClass
                                                                                               delegate:self];
    if (self.bannerCustomEvent) {
        CoreLogType(WBLogLevelInfo, configuration.logType, @"Requesting %@ banner", self.bannerCustomEvent);
        [WBAdControllerEvent postNotification:[[WBAdControllerEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[self.bannerCustomEvent description] adType:WBAdTypeBanner]];
        [WBAdEvent postNotification:[[WBAdEvent alloc] initWithEventType:WBAdEventTypeRequest adNetwork:[self.bannerCustomEvent description] adType:WBAdTypeBanner]];
        self.configuration.customAdNetwork = [self.bannerCustomEvent description];
        [self.bannerCustomEvent requestAdWithSize:size customEventInfo:configuration.customEventClassData];
    } else {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonMalformedData adNetwork:NSStringFromClass(configuration.customEventClass) adType:WBAdTypeBanner];
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerCustomEvent rotateToOrientation:newOrientation];
}

- (void)didDisplayAd
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }

    [self.bannerCustomEvent didDisplayAd];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MPPrivateBannerCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate banner].adUnitId;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (id)bannerDelegate
{
    return [self.delegate bannerDelegate];
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didLoadAd:(UIView *)ad
{
    [WBAdEvent postNotification:[[WBAdEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[event description] adType:WBAdTypeBanner]];
    CoreLogType(WBLogLevelInfo, WBLogTypeAdBanner, @"%@ banner loaded", event);
    [self didStopLoading];
    if (ad) {
        [self.delegate adapter:self didFinishLoadingAd:ad];
    } else {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didFailToLoadAdWithError:(NSError *)error
{
    [WBAdEvent postAdFailedWithReason:WBAdFailureReasonUnknown adNetwork:[event description] adType:WBAdTypeBanner];
    CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"%@ banner didFailToLoadAdWithError %@", event, error.localizedDescription);
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"%@ banner bannerCustomEventWillBeginAction", event);
    [self trackClickOnce];
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEvent *)event
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"%@ banner bannerCustomEventDidFinishAction", event);
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEvent *)event
{
    [WBAdEvent postNotification:[[WBAdEvent alloc] initWithEventType:WBAdEventTypeLeaveApp adNetwork:[event description] adType:WBAdTypeBanner]];
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"%@ banner bannerCustomEventWillLeaveApplication", event);
    [self trackClickOnce];
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

- (void)trackClickOnce
{
    if ([self.bannerCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }
}

@end
