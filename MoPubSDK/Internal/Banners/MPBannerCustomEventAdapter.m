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
#import <WithBuddiesAds/WithBuddiesAds.h>

@interface MPBannerCustomEventAdapter ()

@property (nonatomic, strong) MPBannerCustomEvent *bannerCustomEvent;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

- (void)trackClickOnce;

@end

@implementation MPBannerCustomEventAdapter
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

- (void)unregisterDelegate
{
    if ([self.bannerCustomEvent respondsToSelector:@selector(invalidate)]) {
        // Secret API to allow us to detach the custom event from (shared instance) routers synchronously
        // See the iAd banner custom event for an example use case.
        [self.bannerCustomEvent performSelector:@selector(invalidate)];
    }
    self.bannerCustomEvent.delegate = nil;

    // make sure the custom event isn't released synchronously as objects owned by the custom event
    // may do additional work after a callback that results in unregisterDelegate being called
    [[MPCoreInstanceProvider sharedProvider] keepObjectAliveForCurrentRunLoopIteration:_bannerCustomEvent];

    [super unregisterDelegate];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    AdLogType(WBAdLogLevelDebug, configuration.logType, @"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.bannerCustomEvent = [[MPInstanceProvider sharedProvider] buildBannerCustomEventFromCustomClass:configuration.customEventClass
                                                                                               delegate:self];
    if (self.bannerCustomEvent) {
        AdLogType(WBAdLogLevelInfo, configuration.logType, @"Requesting %@ banner", self.bannerCustomEvent);
        
        WBAdControllerEvent *controllerEvent = [[WBAdControllerEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[self.bannerCustomEvent description] adType:WBAdTypeBanner];
        [WBAdControllerEvent postNotification:controllerEvent];
        
        WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeRequest adNetwork:[self.bannerCustomEvent description] adType:WBAdTypeBanner];
        [WBAdEvent postNotification:event];
        
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
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[event description] adType:WBAdTypeBanner];
    [WBAdEvent postNotification:adEvent];
    AdLogType(WBAdLogLevelInfo, WBAdTypeBanner, @"%@ banner loaded", event);
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
    AdLogType(WBAdLogLevelFatal, WBAdTypeBanner, @"%@ banner didFailToLoadAdWithError %@", event, error.localizedDescription);
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"%@ banner bannerCustomEventWillBeginAction", event);
    [self trackClickOnce];
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEvent *)event
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"%@ banner bannerCustomEventDidFinishAction", event);
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEvent *)event
{
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeLeaveApp adNetwork:[event description] adType:WBAdTypeBanner];
    [WBAdEvent postNotification:adEvent];
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"%@ banner bannerCustomEventWillLeaveApplication", event);
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
