//
//  MPMillennialInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMillennialInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "WBAdService+Internal.h"

#import <MillennialMedia/MMInterstitial.h>

@interface MPMillennialInterstitialRouter : NSObject

@property (nonatomic, retain) NSMutableDictionary *events;
- (MPMillennialInterstitialCustomEvent *)eventForApid:(NSString *)apid;
- (void)registerEvent:(MPMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid;
- (void)unregisterEvent:(MPMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid;

@end

@interface MPInstanceProvider (MillennialInterstitials)

- (MPMillennialInterstitialRouter *)sharedMillennialInterstitialRouter;
- (id)MMInterstitial;

@end

@implementation MPInstanceProvider (MillennialInterstitials)

- (MPMillennialInterstitialRouter *)sharedMillennialInterstitialRouter
{
    return [self singletonForClass:[MPMillennialInterstitialRouter class]
                          provider:^id{
                              return [[[MPMillennialInterstitialRouter alloc] init] autorelease];
                          }];
}

- (id)MMInterstitial
{
    return [MMInterstitial class];
}

@end

@implementation MPMillennialInterstitialRouter

- (id)init
{
    self = [super init];
    if (self) {
        self.events = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.events = nil;
    [super dealloc];
}

- (MPMillennialInterstitialCustomEvent *)eventForApid:(NSString *)apid
{
    return [self.events objectForKey:apid];
}

- (void)registerEvent:(MPMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid
{
    [self.events setObject:event forKey:apid];
}

- (void)unregisterEvent:(MPMillennialInterstitialCustomEvent *)event forApid:(NSString *)apid
{
    if ([self.events objectForKey:apid] == event) {
        [self.events removeObjectForKey:apid];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMillennialInterstitialCustomEvent ()

@property (nonatomic, copy) NSString *apid;
@property (nonatomic, assign) BOOL didDisplay;
@property (nonatomic, assign) BOOL didTrackClick;
@property (nonatomic, assign) int modalCount;

@end

@implementation MPMillennialInterstitialCustomEvent

@synthesize apid = _apid;
@synthesize didDisplay = _didDisplay;

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWasTapped:) name:MillennialMediaAdWasTapped object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWillAppear:) name:MillennialMediaAdModalWillAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adDidAppear:) name:MillennialMediaAdModalDidAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adWillDismiss:) name:MillennialMediaAdModalWillDismiss object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adDidDismiss:) name:MillennialMediaAdModalDidDismiss object:nil];
    }
    return self;
}

-(NSString *)description
{
    return @"Millennial";
}

- (void)dealloc
{
    [self invalidate];
    self.apid = nil;
    [super dealloc];
}

- (MPMillennialInterstitialRouter *)router
{
    return [[MPInstanceProvider sharedProvider] sharedMillennialInterstitialRouter];
}

- (void)invalidate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.router unregisterEvent:self forApid:self.apid];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.apid = [[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdM];

    if (!self.apid || [self.router eventForApid:self.apid]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }

    MMRequest *request = [MMRequest requestWithLocation:self.delegate.location];
    [request setValue:@"mopubsdk" forKey:@"vendor"];

    [self.router registerEvent:self forApid:self.apid];

    [[[MPInstanceProvider sharedProvider] MMInterstitial] fetchWithRequest:request apid:self.apid onCompletion:^(BOOL success, NSError *error) {
        if ([self.router eventForApid:self.apid] != self) {
            return;
        }
        // Check for success isn't sufficient, because Millennial returns an error with domain "com.millennialmedia.error.alreadyCached" when there is already a pre-cached ad
        if (success || [[[MPInstanceProvider sharedProvider] MMInterstitial] isAdAvailableForApid:self.apid]) {
            [self.delegate interstitialCustomEvent:self didLoadAd:nil];
        } else {
            [self invalidate];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        }
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if (!self.didDisplay) {
        if (![[[MPInstanceProvider sharedProvider] MMInterstitial] isAdAvailableForApid:self.apid]) {
            [self invalidate];
            [self.delegate interstitialCustomEventDidExpire:self];
            return;
        }

        [[[MPInstanceProvider sharedProvider] MMInterstitial] displayForApid:self.apid fromViewController:rootViewController withOrientation:0 onCompletion:^(BOOL success, NSError *error) {
            if ([self.router eventForApid:self.apid] != self || self.didDisplay) {
                return;
            }

            if (success) {
                self.didDisplay = YES;
                [self.delegate trackImpression];
            } else {
                [self invalidate];
                [self.delegate interstitialCustomEventDidExpire:self];
            }
        }];
    }
}

- (BOOL)notificationIsRelevant:(NSNotification *)notification
{
    return [self.router eventForApid:self.apid] == self &&
    [[notification.userInfo objectForKey:MillennialMediaAdTypeKey] isEqual:MillennialMediaAdTypeInterstitial] &&
    [[notification.userInfo objectForKey:MillennialMediaAPIDKey] isEqual:self.apid];
}

- (void)adWasTapped:(NSNotification *)notification
{
    // XXX: Tap notifications do not include an APID object in the userInfo dictionary.
    if ([[notification.userInfo objectForKey:MillennialMediaAdTypeKey] isEqual:MillennialMediaAdTypeInterstitial] &&
        self.modalCount == 1) {
        if (!self.didTrackClick) {
            [self.delegate trackClick];
            self.didTrackClick = YES;
            [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
        }
    }
}

- (void)adWillAppear:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification] && self.modalCount == 0) {
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

- (void)adDidAppear:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification]) {
        self.modalCount += 1;
        if (self.modalCount == 1) {
            [self.delegate interstitialCustomEventDidAppear:self];
        }
    }
}

- (void)adWillDismiss:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification] && self.modalCount == 1) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
}

- (void)adDidDismiss:(NSNotification *)notification
{
    if ([self notificationIsRelevant:notification]) {
        self.modalCount -= 1;
        if (self.modalCount == 0) {
            [self invalidate];
            [self.delegate interstitialCustomEventDidExpire:self];
            [self.delegate interstitialCustomEventDidDisappear:self];
        }
    }
}

@end
