//
//  MPBannerAdManagerDelegate.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdView;
@protocol MPAdViewDelegate;

@protocol MPBannerAdManagerDelegate <NSObject>

- (NSString *)adUnitId;
- (MPNativeAdOrientation)allowedNativeAdsOrientation;
- (MPAdView *)banner;
- (id<MPAdViewDelegate>)bannerDelegate;
- (CGSize)containerSize;
- (NSString *)keywords;
- (NSString *)userDataKeywords;
- (CLLocation *)location;
- (UIViewController *)viewControllerForPresentingModalView;

- (void)invalidateContentView;

- (void)bannerWillStartAttemptForAdManager:(MPBannerAdManager *)manager withCustomEventClass:(NSString *)customEventClass;
- (void)bannerDidSucceedAttemptForAdManager:(MPBannerAdManager *)manager withCreativeId:(NSString*)creativeId;
- (void)bannerDidFailAttemptForAdManager:(MPBannerAdManager *)manager error:(NSError*)error;

- (void)managerDidLoadAd:(UIView *)ad;
- (void)managerDidFailToLoadAd;
- (void)userActionWillBegin;
- (void)userActionDidFinish;
- (void)userWillLeaveApplication;

@end
