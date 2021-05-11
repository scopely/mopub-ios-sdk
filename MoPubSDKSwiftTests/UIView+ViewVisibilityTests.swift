//
//  UIView+ViewVisibilityTests.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import XCTest
@testable import MoPubSDK

class UIViewVisibilityTests: XCTestCase {

    var window = UIWindow()
    var superview = UIView()
    var view = UIView()
    
    override func setUp() {
        let defaultFrame = CGRect(x: 0, y: 0, width: Constants.defaultFrameSize, height: Constants.defaultFrameSize)
        
        window = UIWindow(frame: defaultFrame)
        // The window is hidden by default.
        window.isHidden = false
        
        superview = UIView(frame: defaultFrame)
        window.addSubview(superview)
        
        view = UIView(frame: defaultFrame)
        superview.addSubview(view)
    }
    
    // Happy Path
    func testPixelsTrackingMode() {
        let pixels = Constants.defaultFrameSize * Constants.defaultFrameSize
        XCTAssertTrue(view.isVisible(for: .pixels(1)))
        XCTAssertTrue(view.isVisible(for: .pixels(pixels)))
    }

    func testPercentageTrackingMode() {
        // The view is 100% visible by default.
        XCTAssertTrue(view.isVisible(for: .percentage(0.01)))
        XCTAssertTrue(view.isVisible(for: .percentage(1.0)))
    }
    
    // Partial Overlap
    func testViewWithPartialOverlapPixelTrackingMode() {
        // Make this view have 4 pixels visible, it should be visible
        // if testing against 4 pixels, but not 5 pixels.
        view.frame.origin = CGPoint(x: Constants.defaultFrameSize - 2, y: Constants.defaultFrameSize - 2)
        XCTAssertTrue(view.isVisible(for: .pixels(4)))
        XCTAssertFalse(view.isVisible(for: .pixels(5)))
    }
    
    func testViewWithPartialOverlapPercentageTrackingMode() {
        // Move the frame down so it only intersects the window at 50%.
        view.frame.origin = CGPoint(x: 0, y: Constants.defaultFrameSize / 2)
        XCTAssertTrue(view.isVisible(for: .percentage(0.49)))
        XCTAssertFalse(view.isVisible(for: .percentage(0.51)))
    }
    
    func testFractionalPixelOverlap() {
        view.frame.origin = CGPoint(x: Constants.defaultFrameSize - 0.5, y: Constants.defaultFrameSize - 0.5)
        XCTAssertTrue(view.isVisible(for: .pixels(0)))
        XCTAssertFalse(view.isVisible(for: .pixels(1)))
    }
    
    // Clipped/Moved Views
    func testSuperviewClipsView() {
        // Even though the view is clipped by its superview, the view is
        // still 100% within the window.
        superview.frame.size = CGSize(width: Constants.defaultFrameSize, height: Constants.defaultFrameSize / 2)
        XCTAssertTrue(view.isVisible)
        XCTAssertTrue(view.isVisible(for: .percentage(1.0)))
    }

    func testViewDoesNotIntersectWindow() {
        view.frame.origin = CGPoint(x: Constants.defaultFrameSize, y: Constants.defaultFrameSize)
        XCTAssertFalse(view.isVisible)
    }
    
    func testSuperviewDoesNotIntersectWindow() {
        superview.frame.origin = CGPoint(x: Constants.defaultFrameSize, y: Constants.defaultFrameSize)
        XCTAssertFalse(view.isVisible)
    }
    
    func testSuperviewDoesNotIntersectWindowButViewDoes() {
        // Even though the view is not within the bounds of the superview,
        // the view is still 100% within the bounds of the window.
        superview.frame.origin = CGPoint(x: Constants.defaultFrameSize, y: Constants.defaultFrameSize)
        view.frame.origin = CGPoint(x: -Constants.defaultFrameSize, y: -Constants.defaultFrameSize)
        XCTAssertTrue(view.isVisible)
        XCTAssertTrue(view.isVisible(for: .percentage(1.0)))
    }
    
    func testWindowNotAtOrigin() {
        // Even if the window is not at the origin, the view should still
        // be contained 100% within the window.
        window.frame.origin = CGPoint(x: Constants.defaultFrameSize * 2, y: Constants.defaultFrameSize * 2)
        XCTAssertTrue(view.isVisible)
        XCTAssertTrue(view.isVisible(for: .percentage(1.0)))
    }
    
    // Views with zero area
    func testViewWithNoArea() {
        // The view technically intersects, but should have no visible pixels.
        view.frame = .zero
        XCTAssertTrue(view.isVisible)
        XCTAssertFalse(view.isVisible(for: .pixels(1)))
    }
    
    func testSuperviewWithNoArea() {
        // Even though the view is clipped by its superview, the view is
        // still 100% within the window.
        superview.frame = .zero
        XCTAssertTrue(view.isVisible)
        XCTAssertTrue(view.isVisible(for: .percentage(1.0)))
    }
    
    func testWindowWithNoArea() {
        // The view technically intersects, but should have no visible pixels.
        window.frame = .zero
        XCTAssertTrue(view.isVisible)
        XCTAssertFalse(view.isVisible(for: .pixels(1)))
    }
    
    // Hidden Views
    func testHiddenView() {
        view.isHidden = true
        XCTAssertFalse(view.isVisible)
    }
    
    func testViewWithHiddenSuperview() {
        superview.isHidden = true
        XCTAssertFalse(view.isVisible)
    }
    
    // Missing Views
    func testViewWithoutSuperview() {
        view.removeFromSuperview()
        XCTAssertFalse(view.isVisible)
    }
    
    func testViewWithoutWindow() {
        superview.removeFromSuperview()
        XCTAssertFalse(view.isVisible)
    }
    
    // Out of range input
    func testPercentageLessThanZero() {
        // -1 will clamp to 0, so the view should be visible.
        let result = view.isVisible(for: .percentage(-1))
        XCTAssertTrue(result)
    }
    
    func testPercentageGreaterThanOne() {
        // 2 will clamp to 1.
        let result = view.isVisible(for: .percentage(2))
        XCTAssertTrue(result)
    }
    
    func testPixelsLessThanZero() {
        // -1 pixels will clamp to 0 pixels, so the view should be visible.
        let result = view.isVisible(for: .pixels(-1))
        XCTAssertTrue(result)
    }
    
    func testPixelsGreaterThanNumberOfPixelsInView() {
        // If we pass in more pixels than are in the view, it is not visible.
        let pixels = Constants.defaultFrameSize * Constants.defaultFrameSize + 1
        let result = view.isVisible(for: .pixels(pixels))
        XCTAssertFalse(result)
    }
}

// MARK: - Helpers
private extension UIViewVisibilityTests {
    struct Constants {
        static let defaultFrameSize: CGFloat = 64
    }
}
