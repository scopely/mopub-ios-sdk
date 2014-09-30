//
//  FakeMPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTracker.h"

@interface FakeMPAnalyticsTracker : MPAnalyticsTracker

@property (nonatomic, strong) NSMutableArray *trackedImpressionConfigurations;
@property (nonatomic, strong) NSMutableArray *trackedClickConfigurations;

- (void)reset;

@end
