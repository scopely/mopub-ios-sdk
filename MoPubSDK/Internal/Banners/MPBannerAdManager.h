//
//  MPBannerAdManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicator.h"
#import "MPBaseBannerAdapter.h"

@protocol MPBannerAdManagerDelegate;

@interface MPBannerAdManager : NSObject <MPAdServerCommunicatorDelegate, MPBannerAdapterDelegate>

@property (nonatomic, weak) id<MPBannerAdManagerDelegate> delegate;

@property (nonatomic, readonly) Class customEventClass;
@property (nonatomic, readonly) NSString* dspCreativeId;


- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate;

- (void)loadAd;
- (void)forceRefreshAd;
- (void)stopAutomaticallyRefreshingContents;
- (void)startAutomaticallyRefreshingContents;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

@end
