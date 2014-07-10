//
//  FacebookBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "FacebookBannerCustomEvent.h"
#import "MPInstanceProvider.h"

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
    FBAdView *adView = [[[FBAdView alloc] initWithPlacementID:placementID
                                                       adSize:kFBAdSize320x50
                                           rootViewController:controller] autorelease];
    adView.delegate = delegate;
    return adView;
}

@end

@interface FacebookBannerCustomEvent ()

@property (nonatomic, retain) FBAdView *fbAdView;

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

    if (![info objectForKey:@"placement_id"]) {
        CoreLogType(WBLogLevelFatal, WBLogTypeAdBanner, @"Placement ID is required for Facebook banner ad");
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    self.fbAdView =
        [[MPInstanceProvider sharedProvider] buildFBAdViewWithPlacementID:[info objectForKey:@"placement_id"]
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
    [_fbAdView release];
    [super dealloc];
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
