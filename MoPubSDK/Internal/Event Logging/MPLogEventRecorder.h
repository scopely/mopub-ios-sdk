//
//  MPLogEventRecorder.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const MPLogEventNotifName = @"MPLogEvent";
@class MPLogEvent;

void MPAddLogEvent(MPLogEvent *event);

@interface MPLogEventRecorder : NSObject

- (void)addEvent:(MPLogEvent *)event;

@end