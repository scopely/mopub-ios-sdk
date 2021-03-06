//
//  MPCollectionViewAdPlacerView.h
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import <UIKit/UIKit.h>
#import "MPNativeAdRendering.h"


@interface MPCollectionViewAdPlacerView : UIView <MPNativeAdRendering>

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *ctaLabel;
@property (strong, nonatomic) UIImageView *privacyInformationIconImageView;

@end
