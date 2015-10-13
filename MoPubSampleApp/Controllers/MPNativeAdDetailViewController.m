//
//  MPNativeAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPNativeAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAd.h"
#import "MPAdPersistenceManager.h"
#import "MPNativeAdRequestTargeting.h"
#import "MPStaticNativeAdView.h"
#import "MPNativeAdDelegate.h"
#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"

NSString *const kNativeAdDefaultActionViewKey = @"kNativeAdDefaultActionButtonKey";

@interface MPNativeAdDetailViewController () <UITextFieldDelegate, MPNativeAdDelegate>

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPNativeAd *nativeAd;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;
@property (weak, nonatomic) IBOutlet UIButton *loadAdButton;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;

@end

@implementation MPNativeAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithNibName:@"MPNativeAdDetailViewController" bundle:nil];
    if (self) {
        self.info = info;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Native";
    self.IDLabel.text = self.info.ID;
    self.keywordsTextField.text = self.info.keywords;
    self.adViewContainer.accessibilityLabel = kNativeAdDefaultActionViewKey;

    [self loadAd:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Ad Configuration

- (IBAction)loadAd:(id)sender
{
    [self.keywordsTextField endEditing:YES];

    self.loadAdButton.enabled = NO;
    [self.spinner startAnimating];
    [self clearAd];

    // Create and configure a renderer configuration for native ads.
    MPStaticNativeAdRendererSettings *settings = [[MPStaticNativeAdRendererSettings alloc] init];
    settings.renderingViewClass = [MPStaticNativeAdView class];

    MPNativeAdRendererConfiguration *config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
    MPNativeAdRequest *adRequest1 = [MPNativeAdRequest requestWithAdUnitIdentifier:self.info.ID rendererConfigurations:@[config]];
    MPNativeAdRequestTargeting *targeting = [[MPNativeAdRequestTargeting alloc] init];

    targeting.keywords = self.keywordsTextField.text;
    adRequest1.targeting = targeting;
    self.info.keywords = adRequest1.targeting.keywords;
    // persist last used keywords if this is a saved ad
    if ([[MPAdPersistenceManager sharedManager] savedAdForID:self.info.ID] != nil) {
        [[MPAdPersistenceManager sharedManager] addSavedAd:self.info];
    }

    [adRequest1 startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        if (error) {
            NSLog(@"================> %@", error);
            [self configureAdLoadFail];
        } else {
            self.nativeAd = response;
            self.nativeAd.delegate = self;
            [self displayAd];
            NSLog(@"Received Native Ad");
        }
        [self.spinner stopAnimating];
    }];
}

- (void)clearAd
{
    [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.nativeAd = nil;
    self.failLabel.hidden = YES;
}

- (void)displayAd
{
    self.loadAdButton.enabled = YES;

    [[self.adViewContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *adView = [self.nativeAd retrieveAdViewWithError:nil];
    [self.adViewContainer addSubview:adView];
    adView.frame = self.adViewContainer.bounds;
}

- (void)configureAdLoadFail
{
    self.loadAdButton.enabled = YES;
    self.failLabel.hidden = NO;
}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];

    return YES;
}

#pragma mark - MPNativeAdDelegate

- (void)willPresentModalForNativeAd:(MPNativeAd *)nativeAd
{
    NSLog(@"Will present modal for native ad.");
}

- (void)didDismissModalForNativeAd:(MPNativeAd *)nativeAd
{
    NSLog(@"Did dismiss modal for native ad.");
}

- (void)willLeaveApplicationFromNativeAd:(MPNativeAd *)nativeAd
{
    NSLog(@"Will leave application from native ad.");
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

@end
