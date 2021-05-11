//
//  MPMockAdDestinationDisplayAgent.m
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPMockAdDestinationDisplayAgent.h"

// For non-module targets, UIKit must be explicitly imported
// since MoPubSDK-Swift.h will not import it.
#if __has_include(<MoPubSDK/MoPubSDK-Swift.h>)
    #import <UIKit/UIKit.h>
    #import <MoPubSDK/MoPubSDK-Swift.h>
#else
    #import <UIKit/UIKit.h>
    #import "MoPubSDK-Swift.h"
#endif

@implementation MPMockAdDestinationDisplayAgent

- (void)displayDestinationForURL:(NSURL *)URL skAdNetworkData:(MPSKAdNetworkData *)skAdNetworkData {
    self.lastDisplayDestinationUrl = URL;
}

@end
