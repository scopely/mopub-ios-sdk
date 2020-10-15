//
//  MPIdentityProvider.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPIdentityProvider.h"
#import "MPGlobal.h"
#import "MPConsentManager.h"
#import <AdSupport/AdSupport.h>

#define MOPUB_IDENTIFIER_DEFAULTS_KEY @"com.mopub.identifier"
#define MOPUB_IDENTIFIER_LAST_SET_TIME_KEY @"com.mopub.identifiertime"
#define MOPUB_DAY_IN_SECONDS 24 * 60 * 60
#define MOPUB_ALL_ZERO_UUID @"00000000-0000-0000-0000-000000000000"
NSString *const mopubPrefix = @"mopub:";

static BOOL gFrequencyCappingIdUsageEnabled = YES;

@interface MPIdentityProvider ()
@property (class, nonatomic, readonly) NSCalendar * iso8601Calendar;

+ (NSString *)mopubIdentifier:(BOOL)obfuscate;

@end

@implementation MPIdentityProvider

+ (NSCalendar *)iso8601Calendar {
    static dispatch_once_t onceToken;
    static NSCalendar * _iso8601Calendar;
    dispatch_once(&onceToken, ^{
        _iso8601Calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
        _iso8601Calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });

    return _iso8601Calendar;
}

+ (NSString *)identifier
{
    return [self _identifier:NO];
}

+ (NSString *)obfuscatedIdentifier
{
    return [self _identifier:YES];
}

+ (NSString *)unobfuscatedMoPubIdentifier {
    NSString *value = [self mopubIdentifier:NO];
    if ([value hasPrefix:mopubPrefix]) {
        value = [value substringFromIndex:[mopubPrefix length]];
    }
    return value;
}

+ (NSString *)_identifier:(BOOL)obfuscate
{
    if (MPIdentityProvider.advertisingTrackingEnabled && [MPConsentManager sharedManager].canCollectPersonalInfo) {
        return [self identifierFromASIdentifierManager:obfuscate];
    } else {
        return [self mopubIdentifier:obfuscate];
    }
}

+ (BOOL)advertisingTrackingEnabled
{
    if (@available(iOS 14.0, *)) {
        /*
         As of iOS 14, Apple does not provide an explicit means of checking if the IDFA is available.
         The IDFA may or may not be available with an ATT status of NotDetermined, depending on if
         Apple has decided to enforce ATT as opt-in as they plan to. Therefore, if the ATT status
         is NotDetermined, use the IDFA itself to work out the return value of this method.
         @c MPConsentManager depends on this method to detect DoNotTrack consent status. Given that,
         if this method were to use the @c ifa getter to grab the IDFA, which checks @c MPConsentManager
         to verify if IDFA is allowed to be collected, any GDPR status other than explicit_yes, combined
         with a "not_determined" ATT status, would result in @c MPConsentManager mistakenly locking into
         a DNT state. Therefore, check @c MPConsentManager's @c rawIfa value directly. Note that
         we are only checking if the IDFA is non-nil; IDFA is not collected here and should not ever
         be collected via any means besides the @c ifa getter below (minus special circumstances
         internal to @c MPConsentManager).
        */
        NSString *identifier = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString;
        return ![identifier isEqualToString:MOPUB_ALL_ZERO_UUID];
    }

    return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

+ (NSString *)identifierFromASIdentifierManager:(BOOL)obfuscate
{
    if (obfuscate) {
        return @"ifa:XXXX";
    }
    if (!MPIdentityProvider.advertisingTrackingEnabled) {
        return nil;
    }

    NSString *identifier = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
    return [NSString stringWithFormat:@"ifa:%@", [identifier uppercaseString]];
}

+ (NSString *)mopubIdentifier:(BOOL)obfuscate
{
    if (![self frequencyCappingIdUsageEnabled]) {
        return [NSString stringWithFormat:@"ifa:%@", MOPUB_ALL_ZERO_UUID];
    }

    if (obfuscate) {
        return @"mopub:XXXX";
    }

    // Compare the current timestamp to the timestamp of the last MoPub identifier generation.
    NSDate * now = [NSDate date];
    NSDate * lastSetDate = [[NSUserDefaults standardUserDefaults] objectForKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];

    // MoPub identifier has not been set before. Set the timestamp and let the identifer
    // be generated.
    if (lastSetDate == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    // Current day does not match the same day when the identifier was generated.
    // Invalidate the current identifier so it can be regenerated.
    else if (![MPIdentityProvider.iso8601Calendar isDate:now inSameDayAsDate:lastSetDate]) {
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:MOPUB_IDENTIFIER_LAST_SET_TIME_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
    }

    NSString * identifier = [[NSUserDefaults standardUserDefaults] objectForKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
    if (identifier == nil) {
        NSString *uuidStr = [[NSUUID UUID] UUIDString];

        identifier = [mopubPrefix stringByAppendingString:[uuidStr uppercaseString]];
        [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:MOPUB_IDENTIFIER_DEFAULTS_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return identifier;
}

+ (void)setFrequencyCappingIdUsageEnabled:(BOOL)frequencyCappingIdUsageEnabled
{
    gFrequencyCappingIdUsageEnabled = frequencyCappingIdUsageEnabled;
}

+ (BOOL)frequencyCappingIdUsageEnabled
{
    return gFrequencyCappingIdUsageEnabled;
}

@end
