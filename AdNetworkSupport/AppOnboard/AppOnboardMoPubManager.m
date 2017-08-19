//
//  AppOnboardMoPubManager.m
//  Keymoji
//
//  Created by Adam Piechowicz on 4/28/17.
//  Copyright © 2017 Literati Labs. All rights reserved.
//

#import "AppOnboardMoPubManager.h"
#import "MPLogging.h"

#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
#define kAppOnboardStoredAppIdKey @"kAppOnboardStoredAppIdKey"
#define kAppOnboardStoredZoneIdsKey @"kAppOnboardStoredZoneIdsKey"
#endif

@interface AppOnboardMoPubManager () {

}

#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
@property (nonatomic, assign) BOOL isInitialized;
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSArray<NSString *> *zoneIds;
#endif
 
@end

@implementation AppOnboardMoPubManager

#ifdef APPONBOARD_MOPUB_AUTOINIT_ON_LAUNCH
+(void)load
{
    MPLogInfo(@"AppOnboardMoPubManager autoload");
    NSString *appId = nil;
    NSArray *zoneIds = nil;
    NSString *recoveredAppId = [[NSUserDefaults standardUserDefaults] objectForKey:kAppOnboardStoredAppIdKey];
    if(recoveredAppId && [recoveredAppId isKindOfClass:[NSString class]]) {
        appId = recoveredAppId;
    }
    else if(recoveredAppId) {
        MPLogError(@"Invalid App Onboard stored app id: %@", recoveredAppId);
    }
    
    NSArray *recoveredZoneIds = [[NSUserDefaults standardUserDefaults] objectForKey:kAppOnboardStoredZoneIdsKey];
    if(recoveredZoneIds && [recoveredZoneIds isKindOfClass:[NSArray class]]) {
        BOOL valid = YES;
        for(NSString *recoveredZoneId in recoveredZoneIds) {
            if(![recoveredZoneId isKindOfClass:[NSString class]]) {
                MPLogError(@"Invalid App Onboard stored zone id: %@", recoveredZoneId);
                valid = NO;
                break;
            }
        }
        
        if(valid) {
            zoneIds = recoveredZoneIds;
        }
    }

    if(appId && zoneIds) {
        [[AppOnboardMoPubManager sharedManager] initWithAppId:appId zoneIds:zoneIds];
    }
}

-(void)initWithAppId:(NSString *)appId zoneIds:(NSArray<NSString *> *)zoneIds
{
    if(self.isInitialized) {
        //NSLog(@"App Onboard already init");
        return;
    }
    
    if(!appId || !zoneIds) {
        MPLogError(@"WARNING: attempted to set invalid appId (%@) or zoneIds (%@) for App Onboard", appId, zoneIds);
        return;
    }
    
    if(![appId isKindOfClass:[NSString class]]) {
        MPLogError(@"WARNING: attempted to set invalid appId (%@) for App Onboard", appId);
        return;
    }
    self.appId = appId;
    
    for(NSString *zoneId in zoneIds) {
        if(![zoneId isKindOfClass:[NSString class]]) {
            MPLogError(@"WARNING: zoneIds contains invalid element (%@) for App Onboard", zoneId);
            return;
        }
    }
    self.zoneIds = zoneIds;
    
    // store data for future launches, since MoPub otherwise won't initialize us until an ad request is made
    [[NSUserDefaults standardUserDefaults] setObject:self.appId forKey:kAppOnboardStoredAppIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.zoneIds forKey:kAppOnboardStoredZoneIdsKey];
    
    [AppOnboardSDK initWithAppId:self.appId zoneIds:self.zoneIds delegate:self];
    self.isInitialized = YES;
}
#endif

+ (AppOnboardMoPubManager *)sharedManager {
    static dispatch_once_t onceToken;
    static AppOnboardMoPubManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[AppOnboardMoPubManager alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}


-(void)appOnboardPresentationIsReadyInZone:(NSString *)zoneId
{
    if(!zoneId) {
        MPLogError(@"Invalid zoneId became ready for App Onboard: %@. This is an App Onboard internal error, please report to adam@apponboard.com", zoneId);
        return;
    }
    
    MPLogInfo(@"App Onboard presentation became ready in zone %@", zoneId);
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppOnboardPresentationReadyInZoneIdNotification object:self userInfo:@{kAppOnboardPresentationReadyInZoneIdNotificationZoneKey: zoneId}];
}

// App Onboard (v0.6.0) doesn't provide a mechanism to tie a presentation failure to a zone id,
// so we'll have to assume that any failure affects any pending presentation
-(void)appOnboardPresentation:(uint)presentationId failedWithError:(NSError *)error errorIsPermanent:(BOOL)permanent
{
    if(!error) {
        error = [NSError errorWithDomain:kAppOnboardMoPubErrorDomain code:kAppOnboardErrorUnknown userInfo:@{NSLocalizedDescriptionKey: @"unknown error"}];
    }
    MPLogError(@"app onboard presentation preparation failed with error: %@", error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppOnboardPresentationPreparationFailedNotification object:self userInfo:@{kAppOnboardPresentationPreparationFailedNotificationErrorKey: error}];
}

@end
