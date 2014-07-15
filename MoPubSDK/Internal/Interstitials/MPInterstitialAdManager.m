//
//  MPInterstitialAdManager.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <objc/runtime.h>

#import "MPInterstitialAdManager.h"

#import "MPAdServerURLBuilder.h"
#import "MPInterstitialAdController.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPInstanceProvider.h"
#import "MPCoreInstanceProvider.h"
#import "MPInterstitialAdManagerDelegate.h"

#import "WBAdEvent_Internal.h"
#import "WBAdControllerEvent.h"


@interface MPInterstitialAdManager ()

@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL ready;
@property (nonatomic, retain) MPBaseInterstitialAdapter *adapter;
@property (nonatomic, retain) MPAdServerCommunicator *communicator;
@property (nonatomic, retain) MPAdConfiguration *configuration;

- (void)setUpAdapterWithConfiguration:(MPAdConfiguration *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPInterstitialAdManager

@synthesize loading = _loading;
@synthesize ready = _ready;
@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize adapter = _adapter;
@synthesize configuration = _configuration;

- (id)initWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.communicator = [[MPCoreInstanceProvider sharedProvider] buildMPAdServerCommunicatorWithDelegate:self];
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc
{
    [self.communicator cancel];
    [self.communicator setDelegate:nil];
    self.communicator = nil;

    self.adapter = nil;

    self.configuration = nil;

    [super dealloc];
}

- (void)setAdapter:(MPBaseInterstitialAdapter *)adapter
{
    if (self.adapter != adapter) {
        [_adapter release];
        _adapter = [adapter retain];
    }
}

#pragma mark - Public

- (void)loadAdWithURL:(NSURL *)URL
{
    if (self.loading) {
        CoreLogType(WBLogLevelWarn, WBLogTypeAdFullPage, @"Interstitial controller is already loading an ad. "
                  @"Wait for previous load to finish.");
        return;
    }

    CoreLogType(WBLogLevelTrace, WBLogTypeAdFullPage, @"Interstitial controller is loading ad with MoPub server URL: %@", URL);

    [WBAdControllerEvent postNotification:[[WBAdControllerEvent alloc] initWithEventType:WBAdEventTypeRequest adNetwork:nil adType:WBAdTypeInterstitial]];
    
    self.loading = YES;
    [self.communicator loadURL:URL];
}


- (void)loadInterstitialWithAdUnitID:(NSString *)ID keywords:(NSString *)keywords location:(CLLocation *)location testing:(BOOL)testing
{
    if (self.ready) {
        [self.delegate managerDidLoadInterstitial:self];
    } else {
        [self loadAdWithURL:[MPAdServerURLBuilder URLWithAdUnitID:ID
                                                         keywords:keywords
                                                         location:location
                                                          testing:testing]];
    }
}

- (void)presentInterstitialFromViewController:(UIViewController *)controller
{
    if (self.ready) {
        [self.adapter showInterstitialFromViewController:controller];
    }
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (MPInterstitialAdController *)interstitialAdController
{
    return [self.delegate interstitialAdController];
}

- (id)interstitialDelegate
{
    return [self.delegate interstitialDelegate];
}

#pragma mark - MPAdServerCommunicatorDelegate

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfiguration *)configuration
{
    self.configuration = configuration;

    CoreLogType(WBLogLevelInfo, WBLogTypeAdFullPage, @"Interstatial Ad view is fetching ad network type: %@", self.configuration.networkType);

    if ([self.configuration.networkType isEqualToString:@"clear"]) {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonNoFill adNetwork:nil adType:WBAdTypeInterstitial];
        CoreLogType(WBLogLevelError, WBLogTypeAdFullPage, @"Ad server response indicated no ad available.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    if (self.configuration.adType != MPAdTypeInterstitial) {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonMalformedData adNetwork:nil adType:WBAdTypeInterstitial];
        CoreLogType(WBLogLevelFatal, WBLogTypeAdFullPage, @"Could not load ad: interstitial object received a non-interstitial ad unit ID.");
        self.loading = NO;
        [self.delegate manager:self didFailToLoadInterstitialWithError:nil];
        return;
    }

    [self setUpAdapterWithConfiguration:self.configuration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;
    
    WBAdFailureReason failureReason = ([error.domain isEqualToString:@"mopub.com"] ? WBAdFailureReasonMopubServer : WBAdFailureReasonNetworkError);
    [WBAdControllerEvent postAdFailedWithReason:failureReason adNetwork:nil adType:WBAdTypeInterstitial];

    [self.delegate manager:self didFailToLoadInterstitialWithError:error];
}

- (void)setUpAdapterWithConfiguration:(MPAdConfiguration *)configuration;
{
    MPBaseInterstitialAdapter *adapter = [[MPInstanceProvider sharedProvider] buildInterstitialAdapterForConfiguration:configuration
                                                                                                              delegate:self];
    if (!adapter) {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonMalformedData adNetwork:nil adType:WBAdTypeInterstitial];
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    self.adapter = adapter;
    [self.adapter _getAdWithConfiguration:configuration];
}

#pragma mark - MPInterstitialAdapterDelegate

- (void)adapterDidFinishLoadingAd:(MPBaseInterstitialAdapter *)adapter
{
    self.ready = YES;
    self.loading = NO;
    [self.delegate managerDidLoadInterstitial:self];
}

- (void)adapter:(MPBaseInterstitialAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
    self.ready = NO;
    self.loading = NO;
    [self loadAdWithURL:self.configuration.failoverURL];
}

- (void)interstitialWillAppearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    [self.delegate managerWillPresentInterstitial:self];
}

- (void)interstitialDidAppearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    [self.delegate managerDidPresentInterstitial:self];
}

- (void)interstitialWillDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    [self.delegate managerWillDismissInterstitial:self];
}

- (void)interstitialDidDisappearForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    self.ready = NO;
    [self.delegate managerDidDismissInterstitial:self];
}

- (void)interstitialDidExpireForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    self.ready = NO;
    [self.delegate managerDidExpireInterstitial:self];
}

- (void)interstitialWillLeaveApplicationForAdapter:(MPBaseInterstitialAdapter *)adapter
{
    // TODO: Signal to delegate.
}

#pragma mark - Legacy Custom Events

- (void)customEventDidLoadAd
{
    // XXX: The deprecated custom event behavior is to report an impression as soon as an ad loads,
    // rather than when the ad is actually displayed. Because of this, you may see impression-
    // reporting discrepancies between MoPub and your custom ad networks.
    if ([self.adapter respondsToSelector:@selector(customEventDidLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidLoadAd)];
    }
}

- (void)customEventDidFailToLoadAd
{
    if ([self.adapter respondsToSelector:@selector(customEventDidFailToLoadAd)]) {
        self.loading = NO;
        [self.adapter performSelector:@selector(customEventDidFailToLoadAd)];
    }
}

- (void)customEventActionWillBegin
{
    if ([self.adapter respondsToSelector:@selector(customEventActionWillBegin)]) {
        [self.adapter performSelector:@selector(customEventActionWillBegin)];
    }
}

@end
