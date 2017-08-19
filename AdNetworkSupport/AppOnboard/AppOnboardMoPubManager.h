//
//  AppOnboardMoPubManager.h
//  Keymoji
//
//  Created by Adam Piechowicz on 4/28/17.
//  Copyright © 2017 Literati Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppOnboard.h"


// Uncomment this to use automatic init instead of the usual integration process
// not currently recommended!
#define APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH

// keys for the MoPub json that gets passed to custom events
#define kAppOnboardMoPubCustomEventInfoAllZoneIds @"zoneIds"
#define kAppOnboardMoPubCustomEventInfoRequestedZoneId @"requestedZoneId"
#define kAppOnboardMoPubCustomEventInfoAppId @"appId"
#define kAppOnboardMoPubCustomEventInfoAdUnitId @"adUnitId"

// error codes
#define kAppOnboardMoPubErrorDomain @"com.apponboard.sdk.mopub"
#define kAppOnboardErrorDownloadingPresentation -2000
#define kAppOnboardErrorNoPresentationAvailable -2001
#define kAppOnboardErrorUnableToDisplayPresentation -2002
#define kAppOnboardErrorUnknown -2003
#define kAppOnboardErrorInvalidEventConfigParameters -2004

// notifications for internal status updates
#define kAppOnboardPresentationReadyInZoneIdNotification @"kAppOnboardPresentationReadyInZoneIdNotification"
#define kAppOnboardPresentationReadyInZoneIdNotificationZoneKey @"kAppOnboardPresentationReadyInZoneIdNotificationZoneKey"

#define kAppOnboardPresentationPreparationFailedNotification @"kAppOnboardPresentationPreparationFailedNotification"
#define kAppOnboardPresentationPreparationFailedNotificationErrorKey @"kAppOnboardPresentationPreparationFailedNotificationErrorKey"

@interface AppOnboardMoPubManager : NSObject <AppOnboardDelegate> 

+(instancetype)sharedManager;

#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
-(void)initWithAppId:(NSString *)appId zoneIds:(NSArray<NSString *> *)zoneIds;

@property (nonatomic, assign, readonly) BOOL isInitialized;
@property (nonatomic, strong, readonly) NSString *appId;
@property (nonatomic, strong, readonly) NSArray<NSString *> *zoneIds;
#endif

@end
