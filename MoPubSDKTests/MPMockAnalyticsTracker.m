//
//  MPMockAnalyticsTracker.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAnalyticsTracker.h"

@interface MPMockAnalyticsTracker ()

@property (nonatomic, strong) MPSelectorCounter *selectorCounter;
@property (nonatomic, strong, readwrite) NSArray<NSURL *> *lastTrackedUrls;

@end

@implementation MPMockAnalyticsTracker

- (instancetype)init {
    if ([super init]) {
        _selectorCounter = [MPSelectorCounter new];
        _lastTrackedUrls = nil;
    }
    return self;
}

- (void)reset {
    self.lastTrackedUrls = nil;
    [self resetSelectorCounter];
}

#pragma mark - MPAnalyticsTracker

- (void)sendTrackingRequestForURLs:(NSArray<NSURL *> *)URLs {
    [self.selectorCounter incrementCountForSelector:@selector(sendTrackingRequestForURLs:)];
    if (self.lastTrackedUrls == nil) {
        self.lastTrackedUrls = URLs;
    } else {
        self.lastTrackedUrls = [self.lastTrackedUrls arrayByAddingObjectsFromArray:URLs];
    }

    // Do not call super on @c sendTrackingRequestForURLs: to prevent sending any HTTP requests
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectorCounter incrementCountForSelector:@selector(trackClickForConfiguration:)];

    // Call super to make sure related methods are called
    [super trackClickForConfiguration:configuration];
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectorCounter incrementCountForSelector:@selector(trackImpressionForConfiguration:)];

    // Call super to make sure related methods are called
    [super trackImpressionForConfiguration:configuration];
}

- (void)trackEndImpressionForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectorCounter incrementCountForSelector:@selector(trackEndImpressionForConfiguration:)];

    // Call super to make sure related methods are called
    [super trackEndImpressionForConfiguration:configuration];
}

- (void)trackSKAdNetworkStartImpressionForConfiguration:(MPAdConfiguration *)configuration {
    [self.selectorCounter incrementCountForSelector:@selector(trackSKAdNetworkStartImpressionForConfiguration:)];

    // Call super to make sure related methods are called
    [super trackSKAdNetworkStartImpressionForConfiguration:configuration];
}

#pragma mark - MPSelectorCountable

- (NSUInteger)countOfSelectorCalls:(SEL)selector {
    return [self.selectorCounter countOfSelectorCalls:selector];
}

- (void)resetSelectorCounter {
    [self.selectorCounter resetSelectorCounter];
}

@end
