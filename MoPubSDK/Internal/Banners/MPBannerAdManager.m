//
//  MPBannerAdManager.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdManager.h"
#import "MPAdServerURLBuilder.h"
#import "MPInstanceProvider.h"
#import "MPCoreInstanceProvider.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPError.h"
#import "MPTimer.h"
#import "MPConstants.h"
#import "MPLogging.h"

#import "WBAdEvent_Internal.h"
#import "WBAdControllerEvent.h"
#import "MPLogging.h"
#import "WBAdLogging.h"

@interface MPBannerAdManager ()

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPBaseBannerAdapter *onscreenAdapter;
@property (nonatomic, strong) MPBaseBannerAdapter *requestingAdapter;
@property (nonatomic, strong) UIView *requestingAdapterAdContentView;
@property (nonatomic, strong) MPAdConfiguration *requestingConfiguration;
@property (nonatomic, strong) MPTimer *refreshTimer;
@property (nonatomic, assign) BOOL adActionInProgress;
@property (nonatomic, assign) BOOL automaticallyRefreshesContents;
@property (nonatomic, assign) BOOL hasRequestedAtLeastOneAd;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, assign) WBAdType logType;

- (void)loadAdWithURL:(NSURL *)URL;
- (void)applicationWillEnterForeground;
- (void)scheduleRefreshTimer;
- (void)refreshTimerDidFire;

@end

@implementation MPBannerAdManager

@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize onscreenAdapter = _onscreenAdapter;
@synthesize requestingAdapter = _requestingAdapter;
@synthesize refreshTimer = _refreshTimer;
@synthesize adActionInProgress = _adActionInProgress;
@synthesize currentOrientation = _currentOrientation;

- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.communicator = [[MPCoreInstanceProvider sharedProvider] buildMPAdServerCommunicatorWithDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];

        self.automaticallyRefreshesContents = YES;
        self.currentOrientation = MPInterfaceOrientation();
        self.logType = (delegate.containerSize.height == MOPUB_MEDIUM_RECT_SIZE.height ? WBAdTypeInterstitial : WBAdTypeBanner);
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.communicator cancel];
    [self.communicator setDelegate:nil];

    [self.refreshTimer invalidate];

    [self.onscreenAdapter unregisterDelegate];

    [self.requestingAdapter unregisterDelegate];

}

- (BOOL)loading
{
    return self.communicator.loading || self.requestingAdapter;
}

- (void)loadAd
{
    if (!self.hasRequestedAtLeastOneAd) {
        self.hasRequestedAtLeastOneAd = YES;
    }

    if (self.loading) {
        AdLogType(WBAdLogLevelWarn, self.logType, @"%@ view (%@) is already loading an ad. Wait for previous load to finish.", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"), [self.delegate adUnitId]);
        return;
    }

    [self loadAdWithURL:nil];
}

- (void)forceRefreshAd
{
    [self loadAdWithURL:nil];
}

- (void)cancelAd
{
    [self.communicator cancel];
}

- (void)applicationWillEnterForeground
{
    if (self.automaticallyRefreshesContents && self.hasRequestedAtLeastOneAd) {
        [self loadAdWithURL:nil];
    }
}

- (void)applicationDidEnterBackground
{
    [self pauseRefreshTimer];
}

- (void)pauseRefreshTimer
{
    if ([self.refreshTimer isValid]) {
        [self.refreshTimer pause];
    }
}

- (void)stopAutomaticallyRefreshingContents
{
    self.automaticallyRefreshesContents = NO;

    [self pauseRefreshTimer];
}

- (void)startAutomaticallyRefreshingContents
{
    self.automaticallyRefreshesContents = YES;

    if ([self.refreshTimer isValid]) {
        [self.refreshTimer resume];
    } else if (self.refreshTimer) {
        [self scheduleRefreshTimer];
    }
}

- (void)loadAdWithURL:(NSURL *)URL
{
    URL = [URL copy]; //if this is the URL from the requestingConfiguration, it's about to die...
    // Cancel the current request/requesting adapter
    self.requestingConfiguration = nil;
    [self.requestingAdapter unregisterDelegate];
    self.requestingAdapter = nil;
    self.requestingAdapterAdContentView = nil;

    [self.communicator cancel];

    URL = (URL) ? URL : [MPAdServerURLBuilder URLWithAdUnitID:[self.delegate adUnitId]
                                                     keywords:[self.delegate keywords]
                                                     location:[self.delegate location]
                                                      testing:[self.delegate isTesting]];
    AdLogType(WBAdLogLevelTrace, self.logType, @"%@ view (%@) loading ad with MoPub server URL: %@", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"),[self.delegate adUnitId], URL);
    
    if(self.logType == WBAdTypeBanner)
    {
        WBAdControllerEvent *controllerEvent = [[WBAdControllerEvent alloc] initWithEventType:WBAdEventTypeRequest adNetwork:nil adType:WBAdTypeBanner];
        [WBAdControllerEvent postNotification:controllerEvent];
    }

    [self.communicator loadURL:URL];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    self.currentOrientation = orientation;
    [self.requestingAdapter rotateToOrientation:orientation];
    [self.onscreenAdapter rotateToOrientation:orientation];
}

#pragma mark - Internal

- (void)scheduleRefreshTimer
{
    [self.refreshTimer invalidate];
    NSTimeInterval timeInterval = self.requestingConfiguration ? self.requestingConfiguration.refreshInterval : DEFAULT_BANNER_REFRESH_INTERVAL;

    if (timeInterval > 0) {
        self.refreshTimer = [[MPCoreInstanceProvider sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(refreshTimerDidFire)
                                                                                      repeats:NO];
        [self.refreshTimer scheduleNow];
        AdLogType(WBAdLogLevelDebug, self.logType, @"Scheduled the autorefresh timer to fire in %.1f seconds (%p).", timeInterval, self.refreshTimer);
    }
}

- (void)refreshTimerDidFire
{
    if (!self.loading && self.automaticallyRefreshesContents) {
        [self loadAd];
    }
}

#pragma mark - <MPAdServerCommunicatorDelegate>

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfiguration *)configuration
{
    self.requestingConfiguration = configuration;

    AdLogType(WBAdLogLevelDebug, self.logType, @"Banner ad view is fetching ad network type: %@", self.requestingConfiguration.networkType);

    if (configuration.adType == MPAdTypeUnknown) {
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorServerError]];
        return;
    }

    if (configuration.adType == MPAdTypeInterstitial) {
        MPLogWarn(@"Could not load ad: banner object received an interstitial ad unit ID.");
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorAdapterInvalid]];
        return;
    }

    if (configuration.adUnitWarmingUp) {
        MPLogInfo(kMPWarmingUpErrorLogFormatWithAdUnitID, self.delegate.adUnitId);
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorAdUnitWarmingUp]];
        return;
    }

    if ([configuration.networkType isEqualToString:kAdTypeClear]) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.delegate.adUnitId);
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorNoInventory]];
        return;
    }

    self.requestingAdapter = [[MPInstanceProvider sharedProvider] buildBannerAdapterForConfiguration:configuration
                                                                                            delegate:self];
    if (!self.requestingAdapter) {
        [WBAdControllerEvent postAdFailedWithReason:WBAdFailureReasonMalformedData adNetwork:nil adType:WBAdTypeBanner];
        [self loadAdWithURL:self.requestingConfiguration.failoverURL];
        return;
    }

    [self.requestingAdapter _getAdWithConfiguration:configuration containerSize:self.delegate.containerSize];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    [self didFailToLoadAdapterWithError:error];
}

- (void)didFailToLoadAdapterWithError:(NSError *)error
{
    
    if(self.logType == WBAdTypeBanner)
    {
        WBAdFailureReason failureReason = WBAdFailureReasonNetworkError;
        
        switch (error.code) {
            case MPErrorServerError:
                failureReason = WBAdFailureReasonMalformedData;
                break;
            case MPErrorAdapterInvalid:
                failureReason = WBAdFailureReasonMalformedData;
                break;
            case MPErrorNoInventory:
                failureReason = WBAdFailureReasonNoFill;
                break;
            default:
                break;
        }
        
        [WBAdControllerEvent postAdFailedWithReason:failureReason adNetwork:nil adType:WBAdTypeBanner];
    }

    [self.delegate managerDidFailToLoadAd];
    [self scheduleRefreshTimer];

    AdLogType(WBAdLogLevelError, self.logType, @"%@ view (%@) failed. Error: %@", (self.logType == WBAdTypeBanner ? @"Banner" : @"MedRect"), [self.delegate adUnitId], error);
}

#pragma mark - <MPBannerAdapterDelegate>

- (MPAdView *)banner
{
    return [self.delegate banner];
}

- (id<MPAdViewDelegate>)bannerDelegate
{
    return [self.delegate bannerDelegate];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (MPNativeAdOrientation)allowedNativeAdsOrientation
{
    return [self.delegate allowedNativeAdsOrientation];
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (BOOL)requestingAdapterIsReadyToBePresented
{
    return self.requestingAdapterAdContentView != nil;
}

- (void)presentRequestingAdapter
{
    if (!self.adActionInProgress && self.requestingAdapterIsReadyToBePresented) {
        [self.onscreenAdapter unregisterDelegate];
        self.onscreenAdapter = self.requestingAdapter;
        self.requestingAdapter = nil;

        [self.onscreenAdapter rotateToOrientation:self.currentOrientation];
        [self.delegate managerDidLoadAd:self.requestingAdapterAdContentView];
        [self.onscreenAdapter didDisplayAd];

        self.requestingAdapterAdContentView = nil;
        [self scheduleRefreshTimer];
    }
}

- (void)adapter:(MPBaseBannerAdapter *)adapter didFinishLoadingAd:(UIView *)ad
{
    if (self.requestingAdapter == adapter) {
        self.requestingAdapterAdContentView = ad;
        [self presentRequestingAdapter];
    }
}

- (void)adapter:(MPBaseBannerAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
    if (self.requestingAdapter == adapter) {
        [self loadAdWithURL:self.requestingConfiguration.failoverURL];
    }

    if (self.onscreenAdapter == adapter) {
        // the onscreen adapter has failed.  we need to:
        // 1) remove it
        // 2) tell the delegate
        // 3) and note that there can't possibly be a modal on display any more
        [self.delegate managerDidFailToLoadAd];
        [self.delegate invalidateContentView];
        [self.onscreenAdapter unregisterDelegate];
        self.onscreenAdapter = nil;
        if (self.adActionInProgress) {
            [self.delegate userActionDidFinish];
            self.adActionInProgress = NO;
        }
        if (self.requestingAdapterIsReadyToBePresented) {
            [self presentRequestingAdapter];
        } else {
            [self loadAd];
        }
    }
}

- (void)userActionWillBeginForAdapter:(MPBaseBannerAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        self.adActionInProgress = YES;
        [self.delegate userActionWillBegin];
    }
}

- (void)userActionDidFinishForAdapter:(MPBaseBannerAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        [self.delegate userActionDidFinish];
        self.adActionInProgress = NO;
        [self presentRequestingAdapter];
    }
}

- (void)userWillLeaveApplicationFromAdapter:(MPBaseBannerAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        [self.delegate userWillLeaveApplication];
    }
}

@end


