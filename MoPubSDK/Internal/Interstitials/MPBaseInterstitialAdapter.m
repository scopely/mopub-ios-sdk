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
#import "MPInstanceProvider.h"
#import "MPTimer.h"
#import "MPConstants.h"

@interface MPBaseInterstitialAdapter ()

@property (nonatomic, retain) MPAdConfiguration *configuration;
@property (nonatomic, retain) MPTimer *timeoutTimer;

- (void)startTimeoutTimerWithConfiguration:(MPAdConfiguration *)configuration;

@end

@implementation MPBaseInterstitialAdapter

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_configuration release];
    [_timeoutTimer invalidate];

    [super dealloc];
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

    [self retain];
    [self getAdWithConfiguration:configuration];
    [self release];
}

- (void)startTimeoutTimerWithConfiguration:(MPAdConfiguration *)configuration
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : INTERSTITIAL_TIMEOUT_INTERVAL;

    id t = configuration.customEventClassData[@"Timeout"];
    if([t isKindOfClass:[NSString class]] == YES)
    {
        timeInterval = [t intValue];
        CoreLogType(WBLogLevelTrace, WBLogTypeAdFullPage, @"%@ Override timeout available timeout set to %d", NSStringFromClass(configuration.customEventClass), timeInterval);
    }
    
    if(timeInterval > 0)
    {
        self.timeoutTimer = [[MPInstanceProvider sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO
                                                                                      logType:WBLogTypeAdFullPage];

        [self.timeoutTimer scheduleNow];
    }
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)timeout
{
    CoreLogType(WBLogLevelWarn, WBLogTypeAdFullPage, @"%@ custom event did time out", NSStringFromClass(self.configuration.customEventClass));
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
    [[[MPInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [[[MPInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end

