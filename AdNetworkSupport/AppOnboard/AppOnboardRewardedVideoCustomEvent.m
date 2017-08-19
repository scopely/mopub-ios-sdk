//
//  AppOnboardRewardedVideoCustomEvent.m
//  Keymoji
//
//  Created by Adam Piechowicz on 5/3/17.
//  Copyright © 2017 Literati Labs. All rights reserved.
//

#import "AppOnboardRewardedVideoCustomEvent.h"
#import "AppOnboard.h"
#import "AppOnboardMoPubManager.h"
#import "MPLogging.h"
#import "MPRewardedVideo.h"

@interface AppOnboardRewardedVideoCustomEvent () <AppOnboardPresentationDelegate> {
    
}

@property (nonatomic, strong) NSString *zoneId;
@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic, assign) BOOL isReady;

@end

@implementation AppOnboardRewardedVideoCustomEvent

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"AppOnboardInterstitialCustomEvent request interstitial with %@", info);
    
    
    NSString *zoneId = [info objectForKey:kAppOnboardMoPubCustomEventInfoRequestedZoneId];
    if(zoneId && [zoneId isKindOfClass:[NSString class]]) {
        self.zoneId = zoneId;
    }
    else {
        MPLogError(@"Invalid zone id for App Onboard request: %@", zoneId);
        NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorInvalidEventConfigParameters userInfo:@{NSLocalizedDescriptionKey: @"invalid zone id"}];
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
    }
    
    NSString *adUnitId = [info objectForKey:kAppOnboardMoPubCustomEventInfoAdUnitId];
    if(adUnitId && [adUnitId isKindOfClass:[NSString class]]) {
        self.adUnitId = adUnitId;
    }
    else {
        MPLogError(@"Invalid ad unit id for App Onboard request: %@", adUnitId);
        NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorInvalidEventConfigParameters userInfo:@{NSLocalizedDescriptionKey: @"invalid ad unit id"}];
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
    }
    
#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
    AppOnboardMoPubManager *mopubManager = [AppOnboardMoPubManager sharedManager];
    
    if(![mopubManager isInitialized]) {
        // provide the app id and zone ids to init apponboard sdk
        NSArray *zoneIds = [info objectForKey:kAppOnboardMoPubCustomEventInfoAllZoneIds];
        if(zoneIds && [zoneIds isKindOfClass:[NSArray class]]) {
            BOOL valid = YES;
            for(NSString *zoneId in zoneIds) {
                if(![zoneId isKindOfClass:[NSString class]]) {
                    MPLogError(@"Invalid zone id in zone list for App Onboard request: %@", zoneIds);
                    valid = NO;
                }
            }
            if(!valid) {
                zoneIds = nil;
            }
        }
        else {
            MPLogError(@"Invalid zone ids for App Onboard request: %@", zoneIds);
            zoneIds = nil;
        }
        
        NSString *appId = [info objectForKey:kAppOnboardMoPubCustomEventInfoAppId];
        if(!appId || ![appId isKindOfClass:[NSString class]]) {
            MPLogError(@"Invalid app id for App Onboard request: %@", appId);
            appId = nil;
        }
        
        if(zoneIds && appId) {
            [mopubManager initWithAppId:appId zoneIds:zoneIds];
        }
        else {
            NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorInvalidEventConfigParameters userInfo:@{NSLocalizedDescriptionKey: @"invalid app id or zone ids"}];
            if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
                [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            }
        }
    }
#else
    [AppOnboardSDK setManagementDelegate:[AppOnboardMoPubManager sharedManager]];
#endif
    
    // check if we have a presentation already ready to go
    if([AppOnboardSDK shouldShowPresentationForZoneId:self.zoneId]) {
        self.isReady = YES;
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
            [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
        }
    }
    else {
        // register listeners for ready/fail notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentationReadyInZoneNotification:) name:kAppOnboardPresentationReadyInZoneIdNotification object:[AppOnboardMoPubManager sharedManager]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentationPreparationFailedNotification:) name:kAppOnboardPresentationPreparationFailedNotification object:[AppOnboardMoPubManager sharedManager]];
    }
}

-(void)presentationReadyInZoneNotification:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    NSString *zoneId = [userInfo objectForKey:kAppOnboardPresentationReadyInZoneIdNotificationZoneKey];
    if(!zoneId || ![zoneId isKindOfClass:[NSString class]]) {
        MPLogError(@"Invalid zone id became ready for App Onboard: %@. This is an internal App Onboard error, please report to adam@apponboard.com", zoneId);
        return;
    }
    
    if(![zoneId isEqualToString:self.zoneId]) {
        // another zone became ready. ignore, it's not our presentation.
        return;
    }
    
    self.isReady = YES;
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

-(void)presentationPreparationFailedNotification:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    NSError *error = [userInfo objectForKey:kAppOnboardPresentationPreparationFailedNotificationErrorKey];
    if(!error || ![error isKindOfClass:[NSError class]]) {
        MPLogError(@"Invalid error given for presentation preparation failure in App Onboard. This is an App Onboard error, please report to adam@apponboard.com");
        error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"unknown error"}];
    }
    
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

-(BOOL)hasAdAvailable
{
    return [AppOnboardSDK shouldShowPresentationForZoneId:self.zoneId];
}

-(void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    MPLogInfo(@"AppOnboardRewardedVideoCustomEvent presentRewardedVideoFromViewController with %@", viewController);
    if(self.isReady) {
        if([AppOnboardSDK shouldShowPresentationForZoneId:self.zoneId]) {
            if(![AppOnboardSDK showPresentationForZoneId:self.zoneId delegate:self]) {
                if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForCustomEvent:error:)]) {
                    NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorUnableToDisplayPresentation userInfo:@{NSLocalizedDescriptionKey: @"Unable to show presentation at this time"}];
                    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
                }
            }
        }
        else {
            // something changed and the conditions for display are not right; maybe we got frequency capped in the meantime or something
            if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
                NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorNoPresentationAvailable userInfo:@{NSLocalizedDescriptionKey: @"Unable to show presentation at this time"}];
                [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
            }
        }
    }
    else {
        // no ad is available
        if([self.delegate respondsToSelector:@selector(rewardedVideoDidFailToLoadAdForCustomEvent:error:)]) {
            NSError *error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorNoPresentationAvailable userInfo:@{NSLocalizedDescriptionKey: @"No presentation available at this time"}];
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        }
    }
    
}

-(void)appOnboardPresentationWillBegin
{
    if([self.delegate respondsToSelector:@selector(rewardedVideoWillAppearForCustomEvent:)]) {
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    }
    
    // App Onboard doesn't have a "did appear" callback, this is the closest place
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidAppearForCustomEvent:)]) {
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }
}

-(void)appOnboardPresentationDidRecordUserInteractionEvent
{
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidReceiveTapEventForCustomEvent:)]) {
        [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    }
}

-(void)appOnboardPresentationWillOpenAppStore
{
    if([self.delegate respondsToSelector:@selector(rewardedVideoWillLeaveApplicationForCustomEvent:)]) {
        [self.delegate rewardedVideoWillLeaveApplicationForCustomEvent:self];
    }
}

-(void)appOnboardPresentationWillComplete
{
    if([self.delegate respondsToSelector:@selector(rewardedVideoWillDisappearForCustomEvent:)]) {
        [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    }
}

-(void)appOnboardPresentationCompletedReachedEnd:(BOOL)reachedEnd visitedStore:(BOOL)visitedStore
{
    if([self.delegate respondsToSelector:@selector(rewardedVideoDidDisappearForCustomEvent:)]) {
        [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    }
    
    if(reachedEnd) {
        if([self.delegate respondsToSelector:@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:)]) {
            [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[MPRewardedVideo selectedRewardForAdUnitID:self.adUnitId]];
        }
    }
}

@end

