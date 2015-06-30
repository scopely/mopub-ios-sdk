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

@interface MPMRAIDBannerCustomEvent ()

@property (nonatomic, strong) MRAdView *banner;

@end

@implementation MPMRAIDBannerCustomEvent

@dynamic delegate;
@synthesize banner = _banner;

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPAdConfiguration *configuration = [self.delegate configuration];

    CGRect adViewFrame = CGRectZero;
    if ([configuration hasPreferredSize]) {
        adViewFrame = CGRectMake(0, 0, configuration.preferredSize.width,
                                 configuration.preferredSize.height);
    }

    self.banner = [[MPInstanceProvider sharedProvider] buildMRAdViewWithFrame:adViewFrame
                                                              allowsExpansion:YES
                                                             closeButtonStyle:MRAdViewCloseButtonStyleAdControlled
                                                                placementType:MRAdViewPlacementTypeInline
                                                                     delegate:self];

    self.banner.delegate = self;
    [self.banner loadCreativeWithHTMLString:[configuration adResponseHTMLString]
                                    baseURL:nil];
}

- (void)dealloc
{
    self.banner.delegate = nil;
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.banner rotateToOrientation:newOrientation];
}

-(NSString *)description
{
    return @"MRAID";
}

#pragma mark - MRAdViewDelegate

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

- (void)adDidLoad:(MRAdView *)adView
{
    CoreLogType(WBLogLevelInfo, WBAdTypeBanner, @"MoPub MRAID banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adDidFailToLoad:(MRAdView *)adView
{
    CoreLogType(WBLogLevelFatal, WBAdTypeBanner, @"MoPub MRAID banner did fail");
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)closeButtonPressed
{
    //don't care
}

- (void)appShouldSuspendForAd:(MRAdView *)adView
{
    CoreLogType(WBLogLevelDebug, WBAdTypeBanner, @"MoPub MRAID banner will begin action");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)appShouldResumeFromAd:(MRAdView *)adView
{
    CoreLogType(WBLogLevelDebug, WBAdTypeBanner, @"MoPub MRAID banner did end action");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
