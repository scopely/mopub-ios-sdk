//
//  ChartboostInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "ChartboostInterstitialDelegate.h"

@interface ChartboostInterstitialCustomEvent()

@end

@implementation ChartboostInterstitialCustomEvent

-(id)init
{
    self = [super init];
    if(self)
    {
        [ChartboostInterstitialDelegate sharedChartboostInterstitialDelegate].chartboostInterstitialCustomEvent = self;
    }
    return self;
}

-(void)invalidate
{
    [ChartboostInterstitialDelegate sharedChartboostInterstitialDelegate].chartboostInterstitialCustomEvent = nil;
}

#pragma mark - methods

-(NSString *)description
{
    return @"Chartboost";
}

-(void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    if([Chartboost hasInterstitial:CBLocationTurnComplete] == YES)
    {
        [[ChartboostInterstitialDelegate sharedChartboostInterstitialDelegate] didCacheInterstitial:CBLocationTurnComplete];
    }
    else
    {
        [Chartboost cacheInterstitial:CBLocationTurnComplete];
    }
}

-(void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [Chartboost showInterstitial:CBLocationTurnComplete];
}

@end
