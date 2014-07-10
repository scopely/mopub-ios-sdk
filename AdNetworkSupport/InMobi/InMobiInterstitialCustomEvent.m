//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub, Inc. All rights reserved.
//

#import "InMobiInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"
#import "WBAdService+Internal.h"
#import "InMobi+InitializeSdk.h"

@interface MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;

@end

@implementation MPInstanceProvider (InMobiInterstitials)

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId {
    IMInterstitial *inMobiInterstitial = [[[IMInterstitial alloc] initWithAppId:appId] autorelease];
    inMobiInterstitial.delegate = delegate;
    return inMobiInterstitial;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


@interface InMobiInterstitialCustomEvent ()

@property (nonatomic, retain) IMInterstitial *inMobiInterstitial;

@end

@implementation InMobiInterstitialCustomEvent

@synthesize inMobiInterstitial = _inMobiInterstitial;

-(id)init
{
    self = [super init];
    if(self)
    {
        [InMobi inititializeSdk];
    }
    return self;
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.inMobiInterstitial = [[MPInstanceProvider sharedProvider] buildIMInterstitialWithDelegate:self appId:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdIM]];
    self.inMobiInterstitial.additionaParameters = @{ @"tp" : @"c_mopub",
                                                     @"tp-ver"   : MP_SDK_VERSION };
    if (self.delegate.location) {
        [InMobi setLocationWithLatitude:self.delegate.location.coordinate.latitude
                               longitude:self.delegate.location.coordinate.longitude
                                accuracy:self.delegate.location.horizontalAccuracy];
    }
    [self.inMobiInterstitial loadInterstitial];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.inMobiInterstitial presentInterstitialAnimated:YES];
}

- (void)dealloc
{
    [self.inMobiInterstitial setDelegate:nil];
    self.inMobiInterstitial = nil;
    [super dealloc];
}

-(NSString *)description
{
    return @"InMobi";
}

#pragma mark - IMAdInterstitialDelegate


- (void)interstitialDidReceiveAd:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitial:(IMInterstitial *)ad didFailToReceiveAdWithError:(IMError *)error {

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialWillPresentScreen:(IMInterstitial *)ad {

    [self.delegate interstitialCustomEventWillAppear:self];

    // InMobi doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitial:(IMInterstitial *)ad didFailToPresentScreenWithError:(IMError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillDismissScreen:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(IMInterstitial *)ad {
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void) interstitialDidInteract:(IMInterstitial *)ad withParams:(NSDictionary *)dictionary {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
