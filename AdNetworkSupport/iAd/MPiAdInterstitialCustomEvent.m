//
//  MPiAdInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <WithBuddiesAds/WithBuddiesAds.h>
#import "MPiAdInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"

@interface WBiAdViewController : UIViewController

@end

@implementation WBiAdViewController

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    return self;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPiAdInterstitialCustomEvent ()

@property (nonatomic, strong) ADInterstitialAd *iAdInterstitial;
@property (nonatomic, strong) WBiAdViewController *adViewController;

@end

@implementation MPiAdInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)
    {
        NSError *error = [NSError errorWithDomain:WBAdSDKDomain code:0 userInfo:@{
                                                                                  NSLocalizedDescriptionKey : @"iAd is only available on iOS 7+",
                                                                                  NSLocalizedFailureReasonErrorKey : @"Os not supported"
                                                                                  }];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.iAdInterstitial = [[ADInterstitialAd alloc] init];
    self.iAdInterstitial.delegate = self;
}

- (void)dealloc
{
    self.iAdInterstitial.delegate = nil;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)controller {
    // ADInterstitialAd throws an exception if we don't check the loaded flag prior to presenting.
    if (self.iAdInterstitial.loaded)
    {
        [self.delegate interstitialCustomEventWillAppear:self];
        self.adViewController = [[WBiAdViewController alloc] init];
        [controller presentViewController:self.adViewController animated:YES completion:^{
            [self.delegate interstitialCustomEventDidAppear:self];
        }];
        [self.iAdInterstitial presentInView:self.adViewController.view];
        
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat scale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 1 : 1.5;
        closeButton.frame = CGRectMake(0, 0, 40 * scale, 40 * scale);
        
        UIView *fill = [[UIView alloc] initWithFrame:CGRectMake(11 * scale, 11 * scale, 18 * scale, 18 * scale)];
        fill.userInteractionEnabled = NO;
        fill.layer.cornerRadius = CGRectGetWidth(fill.frame)/2;
        fill.backgroundColor = [UIColor whiteColor];
        [closeButton addSubview:fill];
        
        UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(10 * scale, 10 * scale, 20 * scale, 20 * scale)];
        circle.userInteractionEnabled = NO;
        circle.layer.cornerRadius = CGRectGetWidth(circle.frame)/2;
        circle.layer.borderColor = [UIColor darkGrayColor].CGColor;
        circle.layer.borderWidth = 2 * scale;
        
        UILabel *x = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20 * scale, 20 * scale)];
        x.text = @"X";
        x.font = [UIFont boldSystemFontOfSize:12 * scale];
        x.textAlignment = NSTextAlignmentCenter;
        x.textColor = [UIColor darkGrayColor];
        [circle addSubview:x];
        
        [closeButton addSubview:circle];
        
        [self.adViewController.view addSubview:closeButton];
    }
    else
    {
        CoreLogType(WBLogLevelError, WBAdTypeInterstitial, @"Failed to show iAd interstitial: a previously loaded iAd interstitial now claims not to be ready.");
    }
}

-(NSString *)description
{
    return @"iAd";
}

- (void)interstitialAdDismissed
{
    if (self.adViewController)
    {
        [self.delegate interstitialCustomEventWillDisappear:self];
        [self.adViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self.delegate interstitialCustomEventDidDisappear:self];
        }];
    }
}

-(IBAction)close:(id)sender
{
    [self interstitialAdDismissed];
}

#pragma mark - <ADInterstitialAdDelegate>

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    [self.delegate interstitialCustomEvent:self didLoadAd:self.iAdInterstitial];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    [self interstitialAdDismissed];
    if(self.adViewController == nil)
    {
        // ADInterstitialAd can't be shown again after it has unloaded, so notify the controller.
        [self.delegate interstitialCustomEventDidExpire:self];
    }
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd
                   willLeaveApplication:(BOOL)willLeave {
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    return YES; // YES allows the action to execute (NO would instead cancel the action).
}

- (void)interstitialAdActionDidFinish:(ADInterstitialAd *)interstitialAd
{
    [self interstitialAdDismissed];
}

@end
