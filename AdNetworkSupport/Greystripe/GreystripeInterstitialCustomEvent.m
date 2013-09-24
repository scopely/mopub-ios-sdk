//
//  GreystripeInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "GreystripeInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "GSSDKInfo.h"
#import "MPConstants.h"
#import "WBSettingService.h"

@interface MPInstanceProvider (GreystripeInterstitials)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;

@end

@implementation MPInstanceProvider (GreystripeInterstitials)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [[[GSFullscreenAd alloc] initWithDelegate:delegate GUID:GUID] autorelease];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

// This is a sample Greystripe GUID. You will need to replace it with your Greystripe GUID.

@interface GreystripeInterstitialCustomEvent ()

@property (nonatomic, retain) GSFullscreenAd *greystripeFullscreenAd;

@end

@implementation GreystripeInterstitialCustomEvent

@synthesize greystripeFullscreenAd = _greystripeFullscreenAd;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *greyStripeAppId = [WBSettingService keyForAdProvider:WBAdProviderGreyStripeAppId];
    self.greystripeFullscreenAd = [[MPInstanceProvider sharedProvider] buildGSFullscreenAdWithDelegate:self GUID:greyStripeAppId];

    if (self.delegate.location) {
        [GSSDKInfo updateLocation:self.delegate.location];
    }

    [self.greystripeFullscreenAd fetch];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([self.greystripeFullscreenAd isAdReady]) {
        [self.greystripeFullscreenAd displayFromViewController:rootViewController];
    } else {
        CoreLogType(WBLogLevelError, WBLogTypeAdFullPage, @"Failed to show Greystripe interstitial: a previously loaded Greystripe interstitial now claims not to be ready.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)dealloc
{
    [self.greystripeFullscreenAd setDelegate:nil];
    self.greystripeFullscreenAd = nil;
    [super dealloc];
}

-(NSString *)description
{
    return @"GreyStripe";
}

#pragma mark - GSAdDelegate

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    [self.delegate interstitialCustomEvent:self didLoadAd:a_ad];
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error
{
    NSError *error = [NSError errorWithDomain:MP_DOMAIN
                                         code:a_error
                                     userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"GSAdError: %d", a_error] }];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)greystripeAdClickedThrough:(id<GSAd>)a_ad
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)greystripeWillPresentModalViewController
{
    [self.delegate interstitialCustomEventWillAppear:self];

    // Greystripe doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)greystripeWillDismissModalViewController
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)greystripeDidDismissModalViewController
{
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
