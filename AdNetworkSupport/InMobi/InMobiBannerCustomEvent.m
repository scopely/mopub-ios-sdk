//
//  InMobiBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub, Inc. All rights reserved.
//

#import "IMBanner.h"
#import "InMobiBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"
#import "WBAdService+Internal.h"
#import "InMobi+InitializeSdk.h"

#define INVALID_INMOBI_AD_SIZE  -1

static NSString *gAppId = nil;

@interface MPInstanceProvider (InMobiBanners)

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;

@end

@implementation MPInstanceProvider (InMobiBanners)

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    return [[IMBanner alloc] initWithFrame:frame appId:appId adSize:adSize];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface InMobiBannerCustomEvent () <IMBannerDelegate>

@property (nonatomic, strong) IMBanner *inMobiBanner;

- (int)imAdSizeConstantForCGSize:(CGSize)size;

@end

@implementation InMobiBannerCustomEvent

-(id)init
{
    self = [super init];
    if(self)
    {
        [InMobi inititializeSdk];
    }
    return self;
}

#pragma mark - MPBannerCustomEvent Subclass Methods

+ (void)setAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    int imAdSizeConstant = [self imAdSizeConstantForCGSize:size];
    if (imAdSizeConstant == INVALID_INMOBI_AD_SIZE) {
        CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"Failed to create an inMobi Banner with invalid size %@", NSStringFromCGSize(size));
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    NSString *appId = gAppId;
    if ([appId length] == 0) {
        appId = [[WBAdService sharedAdService] bannerIdForAdId:WBAdIdIM];
    }

    self.inMobiBanner = [[MPInstanceProvider sharedProvider] buildIMBannerWithFrame:CGRectMake(0, 0, size.width, size.height) appId:appId adSize:imAdSizeConstant];
    self.inMobiBanner.delegate = self;
    self.inMobiBanner.refreshInterval = REFRESH_INTERVAL_OFF;
    self.inMobiBanner.additionaParameters = @{ @"tp" : @"c_mopub",
                                               @"tp-ver"   : MP_SDK_VERSION };
    if (self.delegate.location) {
        [InMobi setLocationWithLatitude:self.delegate.location.coordinate.latitude
                              longitude:self.delegate.location.coordinate.longitude
                               accuracy:self.delegate.location.horizontalAccuracy];
    }

    [self.inMobiBanner loadBanner];
}

- (int)imAdSizeConstantForCGSize:(CGSize)size
{
    if (CGSizeEqualToSize(size, MOPUB_BANNER_SIZE)) {
        return IM_UNIT_320x50;
    } else if (CGSizeEqualToSize(size, MOPUB_MEDIUM_RECT_SIZE)) {
        return IM_UNIT_300x250;
    } else if (CGSizeEqualToSize(size, MOPUB_LEADERBOARD_SIZE)) {
        return IM_UNIT_728x90;
    } else {
        return INVALID_INMOBI_AD_SIZE;
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Override this method to return NO to perform impression and click tracking manually.

    return NO;
}

- (void)dealloc
{
    [self.inMobiBanner setDelegate:nil];
}

-(NSString *)description
{
    return @"InMobi";
}

#pragma mark - IMAdDelegate

#pragma mark InMobiAdDelegate methods

- (void)bannerDidReceiveAd:(IMBanner *)banner {
    CoreLogType(WBLogLevelInfo, WBLogTypeAdBanner, @"InMobi banner did load");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:banner];
}

- (void)banner:(IMBanner *)banner didFailToReceiveAdWithError:(IMError *)error {
    CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"InMobi banner did fail with error: %@", error.localizedDescription);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"adViewDidDismissScreen");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"adViewWillDismissScreen");
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"InMobi banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)bannerWillLeaveApplication:(IMBanner *)banner {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"InMobi banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (void)bannerDidInteract:(IMBanner *)banner withParams:(NSDictionary *)dictionary {
    CoreLogType(WBLogLevelDebug, WBLogTypeAdBanner, @"InMobi banner was clicked");
    [self.delegate trackClick];
}

@end
