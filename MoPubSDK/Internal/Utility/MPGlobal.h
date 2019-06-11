//
//  MPGlobal.h
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifndef MP_ANIMATED
#define MP_ANIMATED YES
#endif

UIInterfaceOrientation MPInterfaceOrientation(void);
UIWindow *MPKeyWindow(void);
CGFloat MPStatusBarHeight(void);
CGRect MPApplicationFrame(BOOL includeSafeAreaInsets);
CGRect MPScreenBounds(void);
CGSize MPScreenResolution(void);
CGFloat MPDeviceScaleFactor(void);
NSDictionary *MPDictionaryFromQueryString(NSString *query);
NSString *MPSHA1Digest(NSString *string);
BOOL MPViewIsVisible(UIView *view);
BOOL MPViewIntersectsParentWindowWithPercent(UIView *view, CGFloat percentVisible);
NSString *MPResourcePathForResource(NSString *resourceName);
NSArray *MPConvertStringArrayToURLArray(NSArray *strArray);
////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * Availability constants.
 */

#define MP_IOS_7_0  70000
#define MP_IOS_8_0  80000
#define MP_IOS_9_0  90000

////////////////////////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSUInteger, MPInterstitialCloseButtonStyle) {
    MPInterstitialCloseButtonStyleAlwaysVisible,
    MPInterstitialCloseButtonStyleAlwaysHidden,
    MPInterstitialCloseButtonStyleAdControlled,
};

typedef NS_ENUM(NSUInteger, MPInterstitialOrientationType) {
    MPInterstitialOrientationTypePortrait,
    MPInterstitialOrientationTypeLandscape,
    MPInterstitialOrientationTypeAll,
};

UIInterfaceOrientationMask MPInterstitialOrientationTypeToUIInterfaceOrientationMask(MPInterstitialOrientationType type);

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIDevice (MPAdditions)

- (NSString *)mp_hardwareDeviceName;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface UIApplication (MPAdditions)

// Correct way to hide/show the status bar on pre-ios 7.
- (void)mp_preIOS7setApplicationStatusBarHidden:(BOOL)hidden;
- (BOOL)mp_supportsOrientationMask:(UIInterfaceOrientationMask)orientationMask;
- (BOOL)mp_doesOrientation:(UIInterfaceOrientation)orientation matchOrientationMask:(UIInterfaceOrientationMask)orientationMask;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
// Optional Class Forward Def Protocols
////////////////////////////////////////////////////////////////////////////////////////////////////

@class MPAdConfiguration, CLLocation;

@protocol MPAdAlertManagerProtocol <NSObject>

@property (nonatomic, strong) MPAdConfiguration *adConfiguration;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, weak) UIView *targetAdView;
@property (nonatomic, weak) id delegate;

- (void)beginMonitoringAlerts;
- (void)endMonitoringAlerts;
- (void)processAdAlertOnce;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
// Small alert wrapper class to handle telephone protocol prompting
////////////////////////////////////////////////////////////////////////////////////////////////////

@class MPTelephoneConfirmationController;

typedef void (^MPTelephoneConfirmationControllerClickHandler)(NSURL *targetTelephoneURL, BOOL confirmed);

@interface MPTelephoneConfirmationController : NSObject <UIAlertViewDelegate>

- (id)initWithURL:(NSURL *)url clickHandler:(MPTelephoneConfirmationControllerClickHandler)clickHandler;
- (void)show;

@end
