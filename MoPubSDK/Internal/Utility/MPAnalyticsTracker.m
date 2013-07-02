//
//  MPAnalyticsTracker.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTracker.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

@interface MPAnalyticsTracker ()

- (NSURLRequest *)requestForURL:(NSURL *)URL;

@end

@implementation MPAnalyticsTracker

+ (MPAnalyticsTracker *)tracker
{
    return [[[MPAnalyticsTracker alloc] init] autorelease];
}

- (void)trackImpressionForConfiguration:(MPAdConfiguration *)configuration
{
    CoreLogType(WBLogLevelTrace, (configuration.adType == MPAdTypeBanner ? WBLogTypeAdBanner : WBLogTypeAdBanner), @"Tracking impression: %@", configuration.impressionTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.impressionTrackingURL]
                                  delegate:nil];
}

- (void)trackClickForConfiguration:(MPAdConfiguration *)configuration
{
    CoreLogType(WBLogLevelTrace, (configuration.adType == MPAdTypeBanner ? WBLogTypeAdBanner : WBLogTypeAdBanner), @"Tracking click: %@", configuration.clickTrackingURL);
    [NSURLConnection connectionWithRequest:[self requestForURL:configuration.clickTrackingURL]
                                  delegate:nil];
}

- (NSURLRequest *)requestForURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[MPInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:URL];
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    return request;
}

@end
