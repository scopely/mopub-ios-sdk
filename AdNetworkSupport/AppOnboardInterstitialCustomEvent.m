//
//  AppOnboardInterstitialCustomEvent.m
//  AppOnboard
//
//  Created by Adam Piechowicz on 4/28/17.
//  Copyright © 2017 App Onboard, Inc. All rights reserved.
//

#import "AppOnboardInterstitialCustomEvent.h"
#import <AppOnboard/AppOnboard.h>
#import "AppOnboardMoPubManager.h"
#import "MPLogging.h"
#import "MPError.h"

@interface AppOnboardInterstitialCustomEvent () <AppOnboardPresentationDelegate> {
    
}

@property (nonatomic, strong) NSString *zoneId;
@property (nonatomic, assign) BOOL isReady;

@end

@implementation AppOnboardInterstitialCustomEvent

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"AppOnboardInterstitialCustomEvent request interstitial with %@", info);


    NSString *zoneId = [info objectForKey:kAppOnboardMoPubCustomEventInfoRequestedZoneId];
    if(zoneId && [zoneId isKindOfClass:[NSString class]]) {
        self.zoneId = zoneId;
    }
    else {
        MPLogError(@"Invalid zone id for App Onboard request: %@", zoneId);
        NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdapterInvalid userInfo:@{NSLocalizedDescriptionKey: @"invalid zone id"}];
        if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
        return;
    }
    
    BOOL doingInit = NO;
#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
    AppOnboardMoPubManager *mopubManager = [AppOnboardMoPubManager sharedManager];
    
    if(![mopubManager isInitialized]) {
        doingInit = YES;
        
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
            NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdapterInvalid userInfo:@{NSLocalizedDescriptionKey: @"invalid app id or zone ids"}];
            if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
                [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            }
            return;
        }
    }
#else
    [AppOnboardSDK setManagementDelegate:[AppOnboardMoPubManager sharedManager]];
#endif
    
    // if we are initialized, check if we want to show a presentation
    if(!doingInit && [AppOnboardSDK nextPresentationIdToShowInZoneId:self.zoneId] == nil) {
        if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
            NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdapterHasNoInventory userInfo:@{NSLocalizedDescriptionKey: @"No fill"}];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
        return;
    }

    // check if we have a presentation already ready to go
    if([AppOnboardSDK shouldShowPresentationForZoneId:self.zoneId]) {
        self.isReady = YES;
        if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
            [self.delegate interstitialCustomEvent:self didLoadAd:self.zoneId];
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
    if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:zoneId];
    }
}

-(void)presentationPreparationFailedNotification:(NSNotification *)notif
{
    NSDictionary *userInfo = [notif userInfo];
    NSError *error = [userInfo objectForKey:kAppOnboardPresentationPreparationFailedNotificationErrorKey];
    if(!error || ![error isKindOfClass:[NSError class]]) {
        MPLogError(@"Invalid error given for presentation preparation failure in App Onboard. This is an App Onboard error, please report to adam@apponboard.com");
        error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"unknown error"}];
    }
    
    if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

-(void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    MPLogInfo(@"AppOnboardInterstitialCustomEvent showInterstitialFromRootViewController with %@", rootViewController);
    if(self.isReady) {
        if([AppOnboardSDK shouldShowPresentationForZoneId:self.zoneId]) {
            if(![AppOnboardSDK showPresentationForZoneId:self.zoneId delegate:self]) {
                if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
                    NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdUnitWarmingUp userInfo:@{NSLocalizedDescriptionKey: @"Unable to show presentation at this time"}];
                    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
                }
            }
        }
        else {
            // something changed and the conditions for display are not right; maybe we got frequency capped in the meantime or something
            if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
                NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdapterHasNoInventory userInfo:@{NSLocalizedDescriptionKey: @"Unable to show presentation at this time"}];
                [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
            }
        }
    }
    else {
        // no ad is available
        if([self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
            NSError *error = [NSError errorWithDomain:kMOPUBErrorDomain code:MOPUBErrorAdapterHasNoInventory userInfo:@{NSLocalizedDescriptionKey: @"No presentation available at this time"}];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        }
    }
    
}

-(void)appOnboardPresentationWillBegin
{
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
        [self.delegate interstitialCustomEventWillAppear:self];
    }
    
    // App Onboard doesn't have a "did appear" callback, this is the closest place
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

-(void)appOnboardPresentationDidRecordUserInteractionEvent
{
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
}

-(void)appOnboardPresentationWillOpenAppStore
{
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventWillLeaveApplication:)]) {
        [self.delegate interstitialCustomEventWillLeaveApplication:self];
    }
}

-(void)appOnboardPresentationWillComplete
{
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
}

-(void)appOnboardPresentationCompletedReachedEnd:(BOOL)reachedEnd visitedStore:(BOOL)visitedStore
{
    if([self.delegate respondsToSelector:@selector(interstitialCustomEventDidDisappear:)]) {
        [self.delegate interstitialCustomEventDidDisappear:self];
    }
}

@end
