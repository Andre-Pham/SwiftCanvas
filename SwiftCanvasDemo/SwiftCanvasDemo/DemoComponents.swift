//
//  DemoComponents.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 3/3/2024.
//

import UIKit

class LimeButton: LimeUIView {
    
    private let button = UIButton(type: .custom)
    private var onTap: (() -> Void)? = nil
    public var view: UIView {
        return self.button
    }
    public var color: UIColor? {
        return self.button.tintColor
    }
    private var newConfig: UIButton.Configuration {
        return UIButton.Configuration.filled()
    }
    
    override init() {
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 20.0
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 22,
            bottom: 10,
            trailing: 22
        )
        self.button.configuration = config
        self.button.addTarget(self, action: #selector(self.onTapCallback), for: .touchUpInside)
    }
    
    @discardableResult
    func setLabel(to label: String) -> Self {
        var config = self.button.configuration ?? self.newConfig
        config.title = label
        self.button.configuration = config
        return self
    }
    
    @discardableResult
    func setOnTap(_ callback: (() -> Void)?) -> Self {
        self.onTap = callback
        return self
    }
    
    @discardableResult
    func setColor(to color: UIColor) -> Self {
        self.button.tintColor = color
        return self
    }
    
    @discardableResult
    func setAccessibilityLabel(to label: String) -> Self {
        self.button.accessibilityLabel = label
        return self
    }
    
    @discardableResult
    func setFont(to font: UIFont, color: UIColor) -> Self {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributedString = NSAttributedString(string: self.button.configuration?.title ?? "", attributes: attributes)
        self.button.setAttributedTitle(attributedString, for: .normal)
        return self
    }
    
    @discardableResult
    func isDisabled(_ isDisabled: Bool) -> Self {
        self.button.isEnabled = !isDisabled
        return self
    }
    
    @objc private func onTapCallback() {
        self.onTap?()
    }
    
}

class LimeView: LimeUIView {
    
    public let view: UIView
    
    override init() {
        self.view = UIView()
        super.init()
        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    init(_ view: UIView) {
        self.view = view
    }
    
}

typealias LimeUIView = LimeUIViewAbstract & LimeUIViewProtocol

// MARK: - Abstract

class LimeUIViewAbstract {
    
    public let id = UUID()
    
    init() { }
    
}

// MARK: - Protocol

protocol LimeUIViewProtocol {
    
    var view: UIView { get }
    
}
extension LimeUIViewProtocol {
    
    // MARK: - Properties
    
    public var isHidden: Bool {
        return self.view.isHidden
    }
    
    public var frame: CGRect {
        return self.view.frame
    }
    
    public var opacity: Double {
        return Double(self.view.layer.opacity)
    }
    
    /// The existing size of the view. Subclasses override this method to return a custom value based on the desired layout of any subviews.
    /// For example, UITextView returns the view size of its text, and UIImageView returns the size of the image it is currently displaying.
    public var contentBasedSize: CGSize {
        let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        return self.view.sizeThatFits(maxSize)
    }
    
    public var bottomAnchor: NSLayoutYAxisAnchor {
        return self.view.bottomAnchor
    }
    
    public var topAnchor: NSLayoutYAxisAnchor {
        return self.view.topAnchor
    }
    
    public var leftAnchor: NSLayoutXAxisAnchor {
        return self.view.leftAnchor
    }
    
    public var rightAnchor: NSLayoutXAxisAnchor {
        return self.view.rightAnchor
    }
    
    public var widthConstraintConstant: Double {
        self.layoutIfNeeded()
        return self.frame.width
    }
    
    public var heightConstraintConstant: Double {
        self.layoutIfNeeded()
        return self.frame.height
    }
    
    public var superView: LimeView? {
        if let superView = self.view.superview {
            return LimeView(superView)
        }
        return nil
    }
    
    public var hasSuperView: Bool {
        return self.superView != nil
    }
    
    // MARK: - Views
    
    @discardableResult
    func addSubview(_ view: LimeUIView) -> Self {
        self.view.addSubview(view.view)
        return self
    }
    
    @discardableResult
    func addLayer(_ layer: CALayer) -> Self {
        self.view.layer.addSublayer(layer)
        return self
    }
    
    @discardableResult
    func clearSubviewsAndLayers() -> Self {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        return self
    }
    
    @discardableResult
    func removeFromSuperView() -> Self {
        self.view.removeFromSuperview()
        return self
    }
    
    @discardableResult
    func renderToUIImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        self.view.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: - Frame
    
    @discardableResult
    func setFrame(to rect: CGRect) -> Self {
        self.view.frame = rect
        return self
    }
    
    @discardableResult
    func layoutIfNeeded() -> Self {
        self.view.layoutIfNeeded()
        return self
    }
    
    @discardableResult
    func layoutIfNeededAnimated(withDuration: Double = 0.3) -> Self {
        UIView.animate(withDuration: withDuration, animations: {
            self.view.layoutIfNeeded()
        })
        return self
    }
    
    /// Adjusts a view's frame to be fully inside the screen's window bounds (assuming it's partially or fully off-screen)
    /// - Parameters:
    ///   - animationDuration: The animation duration for moving the view, or `nil` for no animation
    ///   - padding: The padding away from the screen's edges
    ///   - inset: The amount of inset for the screen's edges, e.g. 10 would treat the screen's width to be 20 less
    /// - Returns: An reference to the view's instance
    @discardableResult
    func reframeIntoWindow(animationDuration: Double? = nil, padding: Double = 0.0, inset: Double = 0.0) -> Self {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first else {
            print("Unable to find the key window.")
            return self
        }
        // Ensure the view's layout is up to date.
        self.view.superview?.layoutIfNeeded()
        // Convert the view's frame to the window's coordinate system to get its position relative to the screen.
        let viewFrameInWindow = self.view.convert(self.view.bounds, to: window)
        // Screen bounds considering the safe area.
        let safeAreaInsets = window.safeAreaInsets
        let screenBounds = window.bounds.inset(by: safeAreaInsets)
        var newFrame = self.view.frame
        // Check and adjust for the right edge.
        if isGreater(viewFrameInWindow.maxX, screenBounds.maxX - inset) {
            let offsetX = viewFrameInWindow.maxX - screenBounds.maxX
            newFrame.origin.x -= offsetX
            newFrame.origin.x -= padding
        }
        // Check and adjust for the bottom edge.
        if isGreater(viewFrameInWindow.maxY, screenBounds.maxY - inset) {
            let offsetY = viewFrameInWindow.maxY - screenBounds.maxY
            newFrame.origin.y -= offsetY
            newFrame.origin.y -= padding
        }
        // Check and adjust for the left edge.
        if isLess(viewFrameInWindow.minX, screenBounds.minX + inset) {
            let offsetX = screenBounds.minX - viewFrameInWindow.minX
            newFrame.origin.x += offsetX
            newFrame.origin.x += padding
        }
        // Check and adjust for the top edge.
        if isLess(viewFrameInWindow.minY, screenBounds.minY + inset) {
            let offsetY = screenBounds.minY - viewFrameInWindow.minY
            newFrame.origin.y += offsetY
            newFrame.origin.y += padding
        }
        if let animationDuration {
            UIView.animate(withDuration: animationDuration) {
                self.view.frame = newFrame
            }
        } else {
            self.view.frame = newFrame
        }
        return self
    }
    
    // MARK: - Constraints
    
    @discardableResult
    func matchWidthConstraint(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.widthAnchor : target.widthAnchor
        self.view.widthAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func matchHeightConstraint(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.heightAnchor : target.heightAnchor
        self.view.widthAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func setHeightConstraint(to height: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    func setWidthConstraint(to width: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    func setWidthConstraint(proportion: Double, useParentWidth: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let parentView = self.view.superview else {
            fatalError("No constraint target found")
        }
        self.view.widthAnchor.constraint(
            equalTo: useParentWidth ? parentView.widthAnchor : parentView.heightAnchor,
            multiplier: proportion
        ).isActive = true
        return self
    }
    
    @discardableResult
    func setHeightConstraint(proportion: Double, useParentHeight: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let parentView = self.view.superview else {
            fatalError("No constraint target found")
        }
        self.view.widthAnchor.constraint(
            equalTo: useParentHeight ? parentView.heightAnchor : parentView.widthAnchor,
            multiplier: proportion
        ).isActive = true
        return self
    }
    
    @discardableResult
    func setMaxHeightConstraint(to height: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.heightAnchor.constraint(lessThanOrEqualToConstant: height).isActive = true
        return self
    }
    
    @discardableResult
    func setMaxWidthConstraint(to width: Double) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        self.view.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        return self
    }
    
    @discardableResult
    func constrainLeft(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor
        if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            anchor = scrollView.contentLayoutGuide.leadingAnchor
        } else {
            anchor = respectSafeArea ? target.safeAreaLayoutGuide.leadingAnchor : target.leadingAnchor
        }
        self.view.leadingAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainRight(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutXAxisAnchor
        if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            anchor = scrollView.contentLayoutGuide.trailingAnchor
        } else {
            anchor = respectSafeArea ? target.safeAreaLayoutGuide.trailingAnchor : target.trailingAnchor
        }
        self.view.trailingAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainTop(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor
        if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            anchor = scrollView.contentLayoutGuide.topAnchor
        } else {
            anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        }
        self.view.topAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainBottom(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor: NSLayoutYAxisAnchor
        if toContentLayoutGuide, let scrollView = target as? UIScrollView {
            anchor = scrollView.contentLayoutGuide.bottomAnchor
        } else {
            anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        }
        self.view.bottomAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainHorizontal(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        self.constrainLeft(to: other, padding: padding, toContentLayoutGuide: toContentLayoutGuide)
        self.constrainRight(to: other, padding: padding, toContentLayoutGuide: toContentLayoutGuide)
        return self
    }
    
    @discardableResult
    func constrainVertical(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        self.constrainTop(to: other, padding: padding, respectSafeArea: respectSafeArea, toContentLayoutGuide: toContentLayoutGuide)
        self.constrainBottom(to: other, padding: padding, respectSafeArea: respectSafeArea, toContentLayoutGuide: toContentLayoutGuide)
        return self
    }
    
    @discardableResult
    func constrainAllSides(to other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true, toContentLayoutGuide: Bool = false) -> Self {
        self.constrainHorizontal(to: other, padding: padding, respectSafeArea: respectSafeArea, toContentLayoutGuide: toContentLayoutGuide)
        self.constrainVertical(to: other, padding: padding, respectSafeArea: respectSafeArea, toContentLayoutGuide: toContentLayoutGuide)
        return self
    }
    
    @discardableResult
    func constrainToUnderneath(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.bottomAnchor : target.bottomAnchor
        self.view.topAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToOnTop(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.topAnchor : target.topAnchor
        self.view.bottomAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToRightSide(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.rightAnchor : target.rightAnchor
        self.view.leftAnchor.constraint(equalTo: anchor, constant: padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainToLeftSide(of other: LimeUIView? = nil, padding: CGFloat = 0.0, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.leftAnchor : target.leftAnchor
        self.view.rightAnchor.constraint(equalTo: anchor, constant: -padding).isActive = true
        return self
    }
    
    @discardableResult
    func constrainCenterVertical(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerYAnchor : target.centerYAnchor
        self.view.centerYAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func constrainCenterHorizontal(to other: LimeUIView? = nil, respectSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other?.view ?? self.view.superview else {
            fatalError("No constraint target found")
        }
        let anchor = respectSafeArea ? target.safeAreaLayoutGuide.centerXAnchor : target.centerXAnchor
        self.view.centerXAnchor.constraint(equalTo: anchor).isActive = true
        return self
    }
    
    @discardableResult
    func constrainBetweenVertical(
        topView: LimeUIView? = nil,
        isBeneathTopView: Bool = true,
        bottomView: LimeUIView? = nil,
        isAboveBottomView: Bool = true,
        topPadding: Double = 0.0,
        bottomPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> Self {
        guard let topView = topView ?? self.superView else {
            fatalError("No top constraint target found")
        }
        guard let bottomView = bottomView ?? self.superView else {
            fatalError("No bottom constraint target found")
        }
        guard let superView = self.superView else {
            fatalError("No superview found")
        }
        let guide = LimeView()
        superView.addSubview(guide)
        if isBeneathTopView {
            guide.constrainToUnderneath(of: topView, padding: topPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainTop(to: topView, padding: topPadding, respectSafeArea: respectSafeArea)
        }
        if isAboveBottomView {
            guide.constrainToOnTop(of: bottomView, padding: bottomPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainBottom(to: bottomView, padding: topPadding, respectSafeArea: respectSafeArea)
        }
        self.constrainCenterVertical(to: guide)
        return self
    }
    
    @discardableResult
    func constrainBetweenHorizontal(
        leftView: LimeUIView? = nil,
        isBesideLeftView: Bool = true,
        rightView: LimeUIView? = nil,
        isBesideRightView: Bool = true,
        leftPadding: Double = 0.0,
        rightPadding: Double = 0.0,
        respectSafeArea: Bool = true
    ) -> Self {
        guard let leftView = leftView ?? self.superView else {
            fatalError("No top constraint target found")
        }
        guard let rightView = rightView ?? self.superView else {
            fatalError("No bottom constraint target found")
        }
        guard let superView = self.superView else {
            fatalError("No superview found")
        }
        let guide = LimeView()
        superView.addSubview(guide)
        if isBesideLeftView {
            guide.constrainToRightSide(of: leftView, padding: leftPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainLeft(to: leftView, padding: leftPadding, respectSafeArea: respectSafeArea)
        }
        if isBesideRightView {
            guide.constrainToLeftSide(of: rightView, padding: rightPadding, respectSafeArea: respectSafeArea)
        } else {
            guide.constrainRight(to: rightView, padding: rightPadding, respectSafeArea: respectSafeArea)
        }
        self.constrainCenterHorizontal(to: guide)
        return self
    }
    
    @discardableResult
    func constrainHorizontalByProportion(to other: LimeUIView? = nil, proportionFromLeft: Double, padding: CGFloat = 0.0, respectsSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superView else {
            fatalError("No constraint target found")
        }
        let guide = LimeView()
        target.addSubview(guide)
        guide
            .constrainLeft()
            .setWidthConstraint(proportion: proportionFromLeft)
        self.constrainToRightSide(of: guide, padding: padding, respectSafeArea: respectsSafeArea)
        return self
    }
    
    @discardableResult
    func constrainVerticalByProportion(to other: LimeUIView? = nil, proportionFromTop: Double, padding: CGFloat = 0.0, respectsSafeArea: Bool = true) -> Self {
        assert(!self.view.translatesAutoresizingMaskIntoConstraints, "Constraints requirement failed")
        guard let target = other ?? self.superView else {
            fatalError("No constraint target found")
        }
        let guide = LimeView()
        target.addSubview(guide)
        guide
            .constrainTop()
            .setHeightConstraint(proportion: proportionFromTop)
        self.constrainToUnderneath(of: guide, padding: padding, respectSafeArea: respectsSafeArea)
        return self
    }
    
    @discardableResult
    func setPadding(top: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil, right: CGFloat? = nil) -> Self {
        self.view.layoutMargins = UIEdgeInsets(
            top: top ?? self.view.layoutMargins.top,
            left: left ?? self.view.layoutMargins.left,
            bottom: bottom ?? self.view.layoutMargins.bottom,
            right: right ?? self.view.layoutMargins.right
        )
        return self
    }
    
    @discardableResult
    func setPaddingVertical(to padding: CGFloat) -> Self {
        return self.setPadding(top: padding, bottom: padding)
    }
    
    @discardableResult
    func setPaddingHorizontal(to padding: CGFloat) -> Self {
        return self.setPadding(left: padding, right: padding)
    }
    
    @discardableResult
    func setPaddingAllSides(to padding: CGFloat) -> Self {
        self.setPaddingVertical(to: padding)
        self.setPaddingHorizontal(to: padding)
        return self
    }
    
    @discardableResult
    func removeWidthConstraint() -> Self {
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == self.view {
                // Remove any width constraints
                self.view.removeConstraint(constraint)
            }
        }
        return self
    }
    
    @discardableResult
    func removeHeightConstraint() -> Self {
        for constraint in self.view.constraints {
            if constraint.firstAttribute == .height && constraint.firstItem as? UIView == self.view {
                // Remove any height constraints
                self.view.removeConstraint(constraint)
            }
        }
        return self
    }
    
    // MARK: - Background
    
    @discardableResult
    func setBackgroundColor(to color: UIColor) -> Self {
        self.view.backgroundColor = color
        return self
    }
    
    @discardableResult
    func setCornerRadius(to radius: Double) -> Self {
        self.view.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    func addBorder(width: CGFloat = 1.0, color: UIColor = UIColor.red) -> Self {
        self.view.layer.borderWidth = width
        self.view.layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func addSidedBorder(
        width: CGFloat = 1.0,
        color: UIColor = UIColor.red,
        padding: Double = 0.0,
        lengthPadding: Double = 0.0,
        left: Bool = false,
        right: Bool = false,
        top: Bool = false,
        bottom: Bool = false
    ) -> Self {
        if left {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainVertical(padding: lengthPadding)
                .constrainToRightSide(padding: padding)
                .setWidthConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if right {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainVertical(padding: lengthPadding)
                .constrainToLeftSide(padding: padding)
                .setWidthConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if top {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainHorizontal(padding: lengthPadding)
                .constrainToOnTop(padding: padding)
                .setHeightConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        if bottom {
            let borderView = LimeView()
            self.addSubview(borderView)
            borderView
                .constrainHorizontal(padding: lengthPadding)
                .constrainToUnderneath(padding: padding)
                .setHeightConstraint(to: width)
                .setBackgroundColor(to: color)
        }
        return self
    }
    
    @discardableResult
    func addShadow(
        color: UIColor = .black,
        opacity: Float = 0.15,
        offset: CGSize = CGSize(width: 0, height: 2),
        radius: CGFloat = 3
    ) -> Self {
        self.view.layer.shadowColor = color.cgColor
        self.view.layer.shadowOpacity = opacity
        self.view.layer.shadowOffset = offset
        self.view.layer.shadowRadius = radius
        return self
    }
    
    @discardableResult
    func clearShadow() -> Self {
        self.view.layer.shadowColor = nil
        self.view.layer.shadowOpacity = 0.0
        self.view.layer.shadowOffset = CGSize()
        self.view.layer.shadowRadius = 0.0
        return self
    }
    
    // MARK: - Visibility
    
    @discardableResult
    func setHidden(to isHidden: Bool) -> Self {
        self.view.isHidden = isHidden
        return self
    }
    
    @discardableResult
    func setOpacity(to opacity: Double) -> Self {
        self.view.alpha = opacity
        return self
    }
    
    @discardableResult
    func setDisabledOpacity() -> Self {
        self.view.alpha = 0.4
        return self
    }
    
    @discardableResult
    func setInteractions(enabled: Bool) -> Self {
        self.view.isUserInteractionEnabled = enabled
        return self
    }
    
    // MARK: - Animations
    
    @discardableResult
    func animateOpacityInteraction() -> Self {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.view.alpha = 0.25
        }) { _ in
            UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
                self.view.alpha = 1.0
            }, completion: nil)
        }
        return self
    }
    
    @discardableResult
    func animatePressedOpacity() -> Self {
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.view.alpha = 0.25
        }, completion: nil)
        return self
    }
    
    @discardableResult
    func animateReleaseOpacity() -> Self {
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            self.view.alpha = 1.0
        }, completion: nil)
        return self
    }
    
    @discardableResult
    func animateEntrance(duration: Double = 0.2, onCompletion: @escaping () -> Void = {}) -> Self {
        self.setOpacity(to: 0.0)
        self.view.transform = CGAffineTransform(translationX: 0, y: -10)
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setOpacity(to: 1.0)
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }) { _ in
            onCompletion()
        }
        return self
    }
    
    @discardableResult
    func animateExit(duration: Double = 0.2, onCompletion: @escaping () -> Void) -> Self {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setOpacity(to: 0.0)
            self.view.transform = CGAffineTransform(translationX: 0, y: -10)
        }) { _ in
            onCompletion()
        }
        return self
    }
    
    @discardableResult
    func animateOpacity(to opacity: Double, duration: Double = 0.2, onCompletion: @escaping () -> Void = {}) -> Self {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.setOpacity(to: opacity)
        }) { _ in
            onCompletion()
        }
        return self
    }
    
    // MARK: - Transformations
    
    @discardableResult
    func setTransformation(to transformation: CGAffineTransform) -> Self {
        self.view.transform = transformation
        return self
    }
    
}
