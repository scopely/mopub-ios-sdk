//
//  MPBannerAdManager.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicator.h"
#import "MPBaseBannerAdapter.h"

@class MPAdTargeting;

@protocol MPBannerAdManagerDelegate;

@interface MPBannerAdManager : NSObject <MPAdServerCommunicatorDelegate, MPBannerAdapterDelegate>

@property (nonatomic, weak) id<MPBannerAdManagerDelegate> delegate;

@property (nonatomic, readonly) Class customEventClass;
@property (nonatomic, readonly) NSString* dspCreativeId;


- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate;

- (void)loadAdWithTargeting:(MPAdTargeting *)targeting;
- (void)forceRefreshAd;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

- (NSString *)getDspCreativeId;
@end
