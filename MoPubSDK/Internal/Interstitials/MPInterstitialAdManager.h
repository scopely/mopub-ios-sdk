//
//  MPInterstitialAdManager.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPAdServerCommunicator.h"
#import "MPBaseInterstitialAdapter.h"

@class MPAdTargeting;
@protocol MPInterstitialAdManagerDelegate;

@interface MPInterstitialAdManager : NSObject <MPAdServerCommunicatorDelegate,
    MPInterstitialAdapterDelegate>

@property (nonatomic, weak) id<MPInterstitialAdManagerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL ready;

@property (nonatomic, readonly) Class customEventClass;
@property (nonatomic, readonly) NSString* dspCreativeId;
@property (nonatomic, readonly) NSString* lineItemId;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate;

- (void)loadInterstitialWithAdUnitID:(NSString *)ID targeting:(MPAdTargeting *)targeting;
- (void)presentInterstitialFromViewController:(UIViewController *)controller;

@end
