//
//  FacebookBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FacebookBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "WBAdService+Internal.h"

#if (DEBUG || ADHOC)
#import "WBAdService+Debugging.h"
#endif

@interface MPInstanceProvider (FacebookBanners)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID
                        rootViewController:(UIViewController *)controller
                                  delegate:(id<FBAdViewDelegate>)delegate;
@end

@implementation MPInstanceProvider (FacebookBanners)

- (FBAdView *)buildFBAdViewWithPlacementID:(NSString *)placementID
                        rootViewController:(UIViewController *)controller
                                  delegate:(id<FBAdViewDelegate>)delegate
{
    FBAdView *adView = [[FBAdView alloc] initWithPlacementID:placementID
                                                       adSize:kFBAdSize320x50
                                           rootViewController:controller];
    adView.delegate = delegate;
    return adView;
}

@end

@interface FacebookBannerCustomEvent ()

@property (nonatomic, strong) FBAdView *fbAdView;

@end

@implementation FacebookBannerCustomEvent

-(NSString *)description
{
    return @"Facebook";
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    if (!CGSizeEqualToSize(size, kFBAdSize320x50.size)) {
        CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"Invalid size for Facebook banner ad");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    NSString *placementId = [info objectForKey:@"placement_id"] ?: [[WBAdService sharedAdService] bannerIdForAdId:WBAdIdFB];
    
    if (placementId == nil) {
        CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"Placement ID is required for Facebook banner ad");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    self.fbAdView =
        [[MPInstanceProvider sharedProvider] buildFBAdViewWithPlacementID:placementId
                                                       rootViewController:[self.delegate viewControllerForPresentingModalView]
                                                                 delegate:self];

    if (!self.fbAdView) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    [self.fbAdView loadAd];
}

- (void)dealloc
{
    _fbAdView.delegate = nil;
}

#pragma mark FBAdViewDelegate methods

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error;
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewDidLoad:(FBAdView *)adView;
{
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adViewDidClick:(FBAdView *)adView
{
    [self.delegate trackClick];
}

@end
