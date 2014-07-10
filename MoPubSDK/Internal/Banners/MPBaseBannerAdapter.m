//
//  MPBaseBannerAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPBaseBannerAdapter.h"
#import "MPConstants.h"

#import "MPAdConfiguration.h"
#import "MPCoreInstanceProvider.h"
#import "MPAnalyticsTracker.h"
#import "MPTimer.h"

@interface MPBaseBannerAdapter ()

@property (nonatomic, retain) MPAdConfiguration *configuration;
@property (nonatomic, retain) MPTimer *timeoutTimer;

- (void)startTimeoutTimer;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPBaseBannerAdapter

@synthesize delegate = _delegate;
@synthesize configuration = _configuration;
@synthesize timeoutTimer = _timeoutTimer;

- (id)initWithDelegate:(id<MPBannerAdapterDelegate>)delegate
{
    if (self = [super init]) {
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


#pragma mark - Requesting Ads

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    // To be implemented by subclasses.
    [self doesNotRecognizeSelector:_cmd];
}

- (void)_getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    self.configuration = configuration;

    [self startTimeoutTimer];

    [self retain];
    [self getAdWithConfiguration:configuration containerSize:size];
    [self release];
}

- (void)didStopLoading
{
    [self.timeoutTimer invalidate];
}

- (void)didDisplayAd
{
    [self trackImpression];
}

- (void)startTimeoutTimer
{
    NSTimeInterval timeInterval = (self.configuration && self.configuration.adTimeoutInterval >= 0) ?
    self.configuration.adTimeoutInterval : BANNER_TIMEOUT_INTERVAL;
    
    if (timeInterval > 0) {
        self.timeoutTimer = [[MPCoreInstanceProvider sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(timeout)
                                                                                      repeats:NO
                                                                                      logType:(self.configuration.adType == MPAdTypeBanner ? WBLogTypeAdBanner : WBLogTypeAdFullPage)];
        [self.timeoutTimer scheduleNow];
    }
}

- (void)timeout
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

#pragma mark - Rotation

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    // Do nothing by default. Subclasses can override.
    CoreLogType(WBLogLevelTrace, WBLogTypeAdBanner, @"rotateToOrientation %d called for adapter %@ (%p)",
          (int)newOrientation, NSStringFromClass([self class]), self);
}

#pragma mark - Metrics

- (void)trackImpression
{
    [[[MPCoreInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackImpressionForConfiguration:self.configuration];
}

- (void)trackClick
{
    [[[MPCoreInstanceProvider sharedProvider] sharedMPAnalyticsTracker] trackClickForConfiguration:self.configuration];
}

@end
