//
//  InMobi+InitializeSdk.m
//  WithBuddiesAds
//
//  Created by odyth on 9/30/13.
//  Copyright (c) 2013 Scopely. All rights reserved.
//

#import "InMobi+InitializeSdk.h"
#import "WBAdService+Internal.h"

@implementation InMobi (InitializeSdk)

+(void)inititializeSdk
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [InMobi initialize:[[WBAdService sharedAdService] fullpageIdForAdId:WBAdIdIMPublisherAppId]];
        [InMobi setLogLevel:IMLogLevelNone];
#if (DEBUG || INTERNAL)
        [InMobi setLogLevel:IMLogLevelVerbose];
#endif
    });
}

@end
