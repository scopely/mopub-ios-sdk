//
//  MPInterstitialAdManagerDelegate.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>

@class MPInterstitialAdManager;
@class MPInterstitialAdController;
@class CLLocation;

@protocol MPInterstitialAdManagerDelegate <NSObject>

- (MPInterstitialAdController *)interstitialAdController;
- (CLLocation *)location;
- (id)interstitialDelegate;

- (void)managerWillStartInterstitialAttempt:(MPInterstitialAdManager *)manager;
- (void)managerDidSucceedInterstitialAttempt:(MPInterstitialAdManager *)manager;
- (void)manager:(MPInterstitialAdManager *)manager didFailInterstitialAttemptWithError:(NSError*)error;

- (void)managerDidLoadInterstitial:(MPInterstitialAdManager *)manager;
- (void)manager:(MPInterstitialAdManager *)manager didFailToLoadInterstitialWithError:(NSError *)error;
- (void)managerWillPresentInterstitial:(MPInterstitialAdManager *)manager;
- (void)managerDidPresentInterstitial:(MPInterstitialAdManager *)manager;
- (void)managerWillDismissInterstitial:(MPInterstitialAdManager *)manager;
- (void)managerDidDismissInterstitial:(MPInterstitialAdManager *)manager;
- (void)managerDidExpireInterstitial:(MPInterstitialAdManager *)manager;
- (void)managerDidReceiveTapEventFromInterstitial:(MPInterstitialAdManager *)manager;

@end
