//
//  MPInterstitialCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEventAdapter.h"

#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import "MPInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"

#import "WBAdEvent_Internal.h"
#import "WBAdControllerEvent.h"

@interface MPInterstitialCustomEventAdapter ()

@property (nonatomic, retain) MPInterstitialCustomEvent *interstitialCustomEvent;
@property (nonatomic, retain) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

@end

@implementation MPInterstitialCustomEventAdapter
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

@synthesize interstitialCustomEvent = _interstitialCustomEvent;

- (void)dealloc
{
    [_interstitialCustomEvent invalidate];
    _interstitialCustomEvent.delegate = nil;
    [_interstitialCustomEvent release];
    [_configuration release];
    
    [super dealloc];
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"Looking for custom event class named %@.", configuration.customEventClass);
    self.configuration = configuration;

    self.interstitialCustomEvent = [[MPInstanceProvider sharedProvider] buildInterstitialCustomEventFromCustomClass:configuration.customEventClass delegate:self];

    if (self.interstitialCustomEvent) {
        CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Requesting %@ interstitial", self.interstitialCustomEvent);
        WBAdControllerEvent *controllerEvent = [[WBAdControllerEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[self.interstitialCustomEvent description] adType:WBAdTypeInterstitial];
        [WBAdControllerEvent postNotification:controllerEvent];
        [controllerEvent release];
        
        self.configuration.customAdNetwork = [self.interstitialCustomEvent description];
        
        WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeRequest adNetwork:[self.interstitialCustomEvent description] adType:WBAdTypeInterstitial];
        [WBAdEvent postNotification:adEvent];
        [adEvent release];
        
        [self.interstitialCustomEvent requestInterstitialWithCustomEventInfo:configuration.customEventClassData];
    } else {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonMalformedData adNetwork:NSStringFromClass(configuration.customEventClass) adType:WBAdTypeInterstitial];
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self.interstitialCustomEvent showInterstitialFromRootViewController:controller];
}

#pragma mark - MPInterstitialCustomEventDelegate

- (NSString *)adUnitId
{
    return [self.delegate interstitialAdController].adUnitId;
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
                      didLoadAd:(id)ad
{
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeLoaded adNetwork:[customEvent description] adType:WBAdTypeInterstitial];
    [WBAdEvent postNotification:adEvent];
    [adEvent release];
    
    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"%@ interstitial did load", customEvent);
    [self didStopLoading];
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
       didFailToLoadAdWithError:(NSError *)error
{
    [WBAdEvent postAdFailedWithReason:WBAdFailureReasonUnknown adNetwork:[customEvent description] adType:WBAdTypeInterstitial];
    CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"%@ interstitial did Fail To Load Ad error: %@", customEvent, error);
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial will appear", customEvent);
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)interstitialCustomEventDidAppear:(MPInterstitialCustomEvent *)customEvent
{
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeShow adNetwork:[customEvent description] adType:WBAdTypeInterstitial];
    [WBAdEvent postNotification:adEvent];
    [adEvent release];
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial did appear", customEvent);
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedImpression) {
        self.hasTrackedImpression = YES;
        [self trackImpression];
    }
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialCustomEventWillDisappear:(MPInterstitialCustomEvent *)customEvent
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial will disappear", customEvent);
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial did disappear", customEvent);
    [self.delegate interstitialDidDisappearForAdapter:self];
}

- (void)interstitialCustomEventDidExpire:(MPInterstitialCustomEvent *)customEvent
{
    [WBAdEvent postAdFailedWithReason:WBAdFailureReasonExpired adNetwork:[customEvent description] adType:WBAdTypeInterstitial];
    CoreLogType(WBLogLevelWarn, WBLogTypeAdFullPage, @"%@ interstitial did expire", customEvent);
    [self.delegate interstitialDidExpireForAdapter:self];
}

- (void)interstitialCustomEventDidReceiveTapEvent:(MPInterstitialCustomEvent *)customEvent
{
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial received tap", customEvent);
    if ([self.interstitialCustomEvent enableAutomaticImpressionAndClickTracking] && !self.hasTrackedClick) {
        self.hasTrackedClick = YES;
        [self trackClick];
    }

    [self.delegate interstitialDidReceiveTapEventForAdapter:self];
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent
{
    WBAdEvent *event = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeLeaveApp adNetwork:[customEvent description] adType:WBAdTypeInterstitial];
    [WBAdEvent postNotification:event];
    [event release];
    CoreLogType(WBLogLevelDebug, WBLogTypeAdFullPage, @"%@ interstitial will leave application", customEvent);
    [self.delegate interstitialWillLeaveApplicationForAdapter:self];
}

@end
