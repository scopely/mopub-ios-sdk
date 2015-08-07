//
//  MPMRAIDBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <WithBuddiesAds/WithBuddiesAds.h>
#import "MPMRAIDBannerCustomEvent.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import "MRController.h"

@interface MPMRAIDBannerCustomEvent () <MRControllerDelegate>

@property (nonatomic, strong) MRController *mraidController;

@end

@implementation MPMRAIDBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPAdConfiguration *configuration = [self.delegate configuration];

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.mraidController = [[MPInstanceProvider sharedProvider] buildBannerMRControllerWithFrame:adViewFrame delegate:self];
    [self.mraidController loadAdWithConfiguration:configuration];
}

-(NSString *)description
{
    return @"MRAID";
}

#pragma mark - MRControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (MPAdConfiguration *)adConfiguration
{
    return [self.delegate configuration];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)adDidLoad:(UIView *)adView
{
    AdLogType(WBAdLogLevelInfo, WBAdTypeBanner, @"MoPub MRAID banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adDidFailToLoad:(UIView *)adView
{
    AdLogType(WBAdLogLevelFatal, WBAdTypeBanner, @"MoPub MRAID banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForAd:(UIView *)adView
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"MoPub MRAID banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)appShouldResumeFromAd:(UIView *)adView
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"MoPub MRAID banner did end action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
