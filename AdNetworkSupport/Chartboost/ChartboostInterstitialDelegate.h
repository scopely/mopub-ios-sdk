//
//  ChartboostInterstitialDelegate.h
//  WithBuddiesAds
//
//  Created by odyth on 9/11/14.
//  Copyright (c) 2014 Scopely. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chartboost.h"

@class ChartboostInterstitialCustomEvent;
@interface ChartboostInterstitialDelegate : NSObject <ChartboostDelegate>

@property (nonatomic, weak) ChartboostInterstitialCustomEvent *chartboostInterstitialCustomEvent;

+(instancetype)sharedChartboostInterstitialDelegate;
-(void)trackInstall;

@end
