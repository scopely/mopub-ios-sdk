//
//  MPBannerCustomEventAdapter.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBaseBannerAdapter.h"

#import "MPPrivateBannerCustomEventDelegate.h"

@class MPBannerCustomEvent;
@class WBBannerProxy;

@interface MPBannerCustomEventAdapter : MPBaseBannerAdapter <MPPrivateBannerCustomEventDelegate>

- (instancetype)initWithConfiguration:(MPAdConfiguration *)configuration delegate:(id<MPBannerAdapterDelegate>)delegate;

- (instancetype)withBannerProxy:(WBBannerProxy *)proxy;
@end
