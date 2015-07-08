//
//  MPBaseInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPBaseInterstitialAdapter.h"
#import "MPAdConfiguration.h"
#import "MPGlobal.h"
#import "MPAnalyticsTracker.h"
#import "MPCoreInstanceProvider.h"
#import "MPTimer.h"
#import "MPConstants.h"

#import "WBAdEvent_Internal.h"
#import "WBAdControllerEvent.h"

@interface MPBaseInterstitialAdapter ()

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, strong) MPTimer *timeoutTimer;

- (void)startTimeoutTimerWithConfiguration:(MPAdConfiguration *)configuration;

@end

@implementation MPBaseInterstitialAdapter

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (instancetype)initWithDelegate:(id<MPInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterDelegate];

    [self.timeoutTimer invalidate];
}

- (void)unregisterDelegate
{
    self.delegate = nil;
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.configuration = configuration;

    [self startTimeoutTimerWithConfiguration:configuration];

    MPBaseInterstitialAdapter *strongSelf = self;
    [strongSelf getAdWithConfiguration:configuration];
}

- (void)startTimeoutTimerWithConfiguration:(MPAdConfiguration *)configuration
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : INTERSTITIAL_TIMEOUT_INTERVAL;

    id t = configuration.customEventClassData[@"Timeout"];
    if([t isKindOfClass:[NSString class]] == YES)
    {
        timeInterval = [t intValue];
        AdLogType(WBAdLogLevelTrace, WBAdTypeInterstitial, @"%@ Override timeout available timeout set to %f", NSStringFromClass(configuration.customEventClass), timeInterval);
    }
    
    if(timeInterval > 0)
    {
        self.timeoutTimer = [[MPCoreInstanceProvider sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO
                                                                                      logType:WBAdTypeInterstitial];
        [self.timeoutTimer scheduleNow];
    }
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)timeout
{
    AdLogType(WBAdLogLevelWarn, WBAdTypeInterstitial, @"%@ custom event did time out", NSStringFromClass(self.configuration.customEventClass));
    [WBAdEvent postAdFailedWithReason:WBAdFailureReasonTimeout adNetwork:[self.configuration.customEventClass description] adType:WBAdTypeInterstitial];
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Presentation

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Metrics

- (void)trackImpression
{
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeImpression adNetwork:self.configuration.customAdNetwork adType:WBAdTypeInterstitial];
    [WBAdEvent postNotification:adEvent];
    [[[MPCoreInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    WBAdEvent *adEvent = [[WBAdEvent alloc] initWithEventType:WBAdEventTypeClick adNetwork:self.configuration.customAdNetwork adType:WBAdTypeInterstitial];
    [WBAdEvent postNotification:adEvent];
    [[[MPCoreInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end

