//
//  MPInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

@implementation MPInterstitialCustomEvent

@synthesize delegate;

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to load an interstitial here.
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Subclasses may override this method to return NO to perform impression and click tracking
    // manually.
    return YES;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    // The default implementation of this method does nothing. Subclasses must override this method
    // and implement code to display an interstitial here.
}


-(void)loadInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    //used for banners to actually load since they dont have precaching.
}

-(void)invalidate
{
    // API to allow us to detach the custom event from (shared instance) routers synchronously
    // See the chartboost interstitial custom event for an example use case.
}

-(void)customEventDidUnload __OSX_AVAILABLE_BUT_DEPRECATED(__MAC_NA,__MAC_NA,__IPHONE_3_0,__IPHONE_5_0);
{
    
}

@end
