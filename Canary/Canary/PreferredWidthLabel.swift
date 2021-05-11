//
//  PreferredWidthLabel.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/// `UILabel` subclass for encapsulating autolayout logic related to the a label's `preferredMaxLayoutWidth`. This class is particularly useful in cases where the `preferredMaxLayoutWidth` is a dynamic value defined by the label's superview.
class PreferredWidthLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Once the label has been layed out, update constraints to determine a preferredMaxLayoutWidth.
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        guard let superview = superview else { return }
        
        // Determine the width of the label's superview to use as the maximum preferred width. It's not ideal that we're reaching up the view hierarchy, but necessary to figure out the maximum available width.
        let maxWidth = superview.bounds.width
        
        // Create a fitting size.
        let fittingSize = CGSize(width: maxWidth, height: UIView.layoutFittingExpandedSize.height)
        
        // Calculate the system layout size of the label given its maxWidth.
        let idealSize = systemLayoutSizeFitting(fittingSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .fittingSizeLevel)
        let idealWidth = idealSize.width

        // Set the preferred max layout width to the label's ideal width.
        if preferredMaxLayoutWidth != idealWidth {
            preferredMaxLayoutWidth = idealWidth
        }

        super.updateConstraints()
    }
}
