//
//  MPGoogleAdMobBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "WBAdService+Internal.h"
#import <WithBuddiesAds/WithBuddiesAds.h>

#if (DEBUG || ADHOC)
#import "WBAdService+Debugging.h"
#endif

@interface MPInstanceProvider (AdMobBanners)

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame;
- (GADRequest *)buildGADBannerRequest;

@end

@implementation MPInstanceProvider (AdMobBanners)

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame
{
    return [[GADBannerView alloc] initWithFrame:frame];
}

- (GADRequest *)buildGADBannerRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGoogleAdMobBannerCustomEvent () <GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *adBannerView;

@end


@implementation MPGoogleAdMobBannerCustomEvent

- (id)init
{
    self = [super init];
    if (self)
    {
        self.adBannerView = [[MPInstanceProvider sharedProvider] buildGADBannerViewWithFrame:CGRectZero];
        self.adBannerView.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.adBannerView.delegate = nil;
}

-(NSString *)description
{
    return @"AdMob";
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    NSString *adUnitID = info[WBAdUnitID];
#if (DEBUG || ADHOC)
    
    if([[WBAdService sharedAdService] forcedAdNetwork] == WBAdNetworkAM)
    {
        adUnitID = [[WBAdService sharedAdService] bannerIdForAdId:WBAdIdAM];
    }

#endif
    
    self.adBannerView.adUnitID = adUnitID;
    
    CGRect frame = [self frameForCustomEventInfo:info];
    if(CGSizeEqualToSize(size, CGSizeZero) == NO)
    {
        frame.size = size;
    }
    self.adBannerView.frame = frame;
    self.adBannerView.rootViewController = [self.delegate viewControllerForPresentingModalView];

    GADRequest *request = [[MPInstanceProvider sharedProvider] buildGADBannerRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of device IDs that will receive test ads.
    // Running in the simulator will automatically show test ads.
    #pragma message "TEMPORARILY COMMENTING to build on Xcode 7.  Next ads SDK should bring this back; DONT RELEASE WITH THIS"
    request.testDevices = @[];/*[NSArray arrayWithObjects:
                           // more UDIDs here,
                           nil];*/

    request.requestAgent = @"MoPub";

    [self.adBannerView loadRequest:request];
}

- (CGRect)frameForCustomEventInfo:(NSDictionary *)info
{
    CGFloat width = [[info objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[info objectForKey:@"adHeight"] floatValue];

    if (width < GAD_SIZE_320x50.width && height < GAD_SIZE_320x50.height) {
        width = GAD_SIZE_320x50.width;
        height = GAD_SIZE_320x50.height;
    }
    return CGRectMake(0, 0, width, height);
}

-(void)removeFromSuperview
{
    [self.adBannerView removeFromSuperview];
}

#pragma mark -
#pragma mark GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    AdLogType(WBAdLogLevelInfo, WBAdTypeBanner, @"Google AdMob Banner did load");
    [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    AdLogType(WBAdLogLevelFatal, WBAdTypeBanner, @"Google AdMob Banner failed to load with error: %@", error.localizedDescription);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"Google AdMob Banner will present modal");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"Google AdMob Banner did dismiss modal");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    AdLogType(WBAdLogLevelDebug, WBAdTypeBanner, @"Google AdMob Banner will leave the application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
