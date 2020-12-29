//
//  JJActionItem.swift
//
//  Copyright (c) 2017-Present Jochen Pfeiffer
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// The item view representing an action.
///
@objc @IBDesignable open class JJActionItem: UIControl {
    /// The action that is executen when the item is tapped.
    /// Default is `nil`.
    ///
    /// - Parameter item: The action item that has been tapped.
    ///
    @objc open var action: ((JJActionItem) -> Void)?

    /// Calls the action on the action item.
    ///
    @objc public func callAction() {
        action?(self)
    }

    /// The color of action item circle view.
    /// Default is `UIColor.white`.
    ///
    /// - SeeAlso: `circleView`
    ///
    @objc @IBInspectable public dynamic var buttonColor: UIColor {
        get {
            return circleView.color
        }
        set {
            circleView.color = newValue
        }
    }

    /// The color of action item circle view with highlighted state.
    /// Default is `nil`.
    ///
    /// - SeeAlso: `circleView`
    ///
    @objc @IBInspectable public dynamic var highlightedButtonColor: UIColor? {
        get {
            return circleView.highlightedColor
        }
        set {
            circleView.highlightedColor = newValue
        }
    }

    /// The image displayed by the item.
    /// Default is `nil`.
    ///
    /// - SeeAlso: `imageView`
    ///
    @objc @IBInspectable public dynamic var buttonImage: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    /// The tint color of the image view.
    /// By default the color of the floating action button is used.
    ///
    /// - Warning: Only template images are colored.
    ///
    /// - SeeAlso: `imageView`
    ///
    @objc @IBInspectable public dynamic var buttonImageColor: UIColor {
        get {
            return imageView.tintColor
        }
        set {
            imageView.tintColor = newValue
        }
    }

    /// The title label of the item. Can be configured as needed.
    /// Read only.
    ///
    @objc open fileprivate(set) lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.isUserInteractionEnabled = false
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: UIFont.systemFontSize)
        titleLabel.textColor = .white
        return titleLabel
    }()

    /// The image view of the item. Can be configured as needed.
    /// Read only.
    ///
    /// - SeeAlso: `buttonImage`
    /// - SeeAlso: `buttonImageColor`
    ///
    @objc open fileprivate(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    }()

    /// The background circle of the item. Can be configured as needed.
    /// Read only.
    ///
    /// - SeeAlso: `buttonColor`
    /// - SeeAlso: `highlightedButtonColor`
    ///
    @objc open fileprivate(set) lazy var circleView: JJCircleView = {
        let view = JJCircleView()
        view.color = .white
        view.isUserInteractionEnabled = false
        return view
    }()

    /// The position of the title label. Default is `.leading`.
    ///
    @objc public dynamic var titlePosition: JJActionItemTitlePosition = .leading {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    /// The position of the title label. Default is `-1`.
    /// When titleSpacing is negative default spacing is used:
    /// Default horizontal spacing is `12`.
    /// Default vertical spaicng is `4`.
    ///
    @objc public dynamic var titleSpacing: CGFloat = -1 {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    /// Returns an object initialized from data in a given unarchiver.
    ///
    /// - Parameter aDecoder: An unarchiver object.
    ///
    /// - Returns: `self`, initialized using the data in decoder.
    ///
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    fileprivate var dynamicConstraints: [NSLayoutConstraint] = []
}

// MARK: - UIView

extension JJActionItem {
    /// Tells the view that its superview changed.
    ///
    open override func didMoveToSuperview() {
        // reset tintAdjustmentMode
        imageView.tintColorDidChange()
    }

    /// Updates constraints for the view.
    ///
    open override func updateConstraints() {
        updateDynamicConstraints()
        super.updateConstraints()
    }
}

// MARK: - UIControl

extension JJActionItem {
    /// A Boolean value indicating whether the action item draws a highlight.
    ///
    open override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            circleView.isHighlighted = newValue
        }
        get {
            return super.isHighlighted
        }
    }
}

// MARK: - Private Methods

fileprivate extension JJActionItem {
    func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        addSubview(titleLabel)
        addSubview(circleView)
        circleView.addSubview(imageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false

        createStaticConstraints()
        updateDynamicConstraints()
    }

    func updateDynamicConstraints() {
        titleLabel.isHidden = (titlePosition == .hidden)
        NSLayoutConstraint.deactivate(dynamicConstraints)
        dynamicConstraints.removeAll()
        createDynamicConstraints()
        NSLayoutConstraint.activate(dynamicConstraints)
        setNeedsLayout()
    }

    func createStaticConstraints() {
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)

        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(900), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(900), for: .vertical)

        var constraints: [NSLayoutConstraint] = []
        var constraint: NSLayoutConstraint

        let imageSizeMuliplier = CGFloat(1 / sqrt(2))
        constraints.append(imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor))
        constraints.append(imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor))
        constraints.append(imageView.widthAnchor.constraint(lessThanOrEqualTo: circleView.widthAnchor, multiplier: imageSizeMuliplier))
        constraints.append(imageView.heightAnchor.constraint(lessThanOrEqualTo: circleView.heightAnchor, multiplier: imageSizeMuliplier))

        constraints.append(circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor))

        constraints.append(circleView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor))
        constraints.append(circleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor))
        constraints.append(circleView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor))
        constraints.append(circleView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor))

        constraint = circleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        constraint.priority = .defaultLow
        constraints.append(constraint)
        constraint = circleView.trailingAnchor.constraint(equalTo: trailingAnchor)
        constraint.priority = .defaultLow
        constraints.append(constraint)
        constraint = circleView.topAnchor.constraint(equalTo: topAnchor)
        constraint.priority = .defaultLow
        constraints.append(constraint)
        constraint = circleView.bottomAnchor.constraint(equalTo: bottomAnchor)
        constraint.priority = .defaultLow
        constraints.append(constraint)

        constraints.append(titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor))
        constraints.append(titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor))
        constraints.append(titleLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor))
        constraints.append(titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor))

        NSLayoutConstraint.activate(constraints)

        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        circleView.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        circleView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
    }

    func createDynamicConstraints() {
        let horizontalSpacing = titleSpacing(forAxis: .horizontal)
        let verticalSpacing = titleSpacing(forAxis: .vertical)

        switch titlePosition {
        case .leading:
            dynamicConstraints.append(circleView.trailingAnchor.constraint(equalTo: trailingAnchor))
            dynamicConstraints.append(circleView.centerYAnchor.constraint(equalTo: centerYAnchor))
            dynamicConstraints.append(titleLabel.trailingAnchor.constraint(equalTo: circleView.leadingAnchor, constant: -horizontalSpacing))
            dynamicConstraints.append(titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor))
        case .trailing:
            dynamicConstraints.append(circleView.leadingAnchor.constraint(equalTo: leadingAnchor))
            dynamicConstraints.append(circleView.centerYAnchor.constraint(equalTo: centerYAnchor))
            dynamicConstraints.append(titleLabel.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: horizontalSpacing))
            dynamicConstraints.append(titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor))
        case .left:
            dynamicConstraints.append(circleView.rightAnchor.constraint(equalTo: rightAnchor))
            dynamicConstraints.append(circleView.centerYAnchor.constraint(equalTo: centerYAnchor))
            dynamicConstraints.append(titleLabel.rightAnchor.constraint(equalTo: circleView.leftAnchor, constant: -horizontalSpacing))
            dynamicConstraints.append(titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor))
        case .right:
            dynamicConstraints.append(circleView.leftAnchor.constraint(equalTo: leftAnchor))
            dynamicConstraints.append(circleView.centerYAnchor.constraint(equalTo: centerYAnchor))
            dynamicConstraints.append(titleLabel.leftAnchor.constraint(equalTo: circleView.rightAnchor, constant: horizontalSpacing))
            dynamicConstraints.append(titleLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor))
        case .top:
            dynamicConstraints.append(circleView.bottomAnchor.constraint(equalTo: bottomAnchor))
            dynamicConstraints.append(circleView.centerXAnchor.constraint(equalTo: centerXAnchor))
            dynamicConstraints.append(titleLabel.bottomAnchor.constraint(equalTo: circleView.topAnchor, constant: -verticalSpacing))
            dynamicConstraints.append(titleLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor))
        case .bottom:
            dynamicConstraints.append(circleView.topAnchor.constraint(equalTo: topAnchor))
            dynamicConstraints.append(circleView.centerXAnchor.constraint(equalTo: centerXAnchor))
            dynamicConstraints.append(titleLabel.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: verticalSpacing))
            dynamicConstraints.append(titleLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor))
        case .hidden:
            dynamicConstraints.append(circleView.centerXAnchor.constraint(equalTo: centerXAnchor))
            dynamicConstraints.append(circleView.centerYAnchor.constraint(equalTo: centerYAnchor))
        }
    }

    func titleSpacing(forAxis axis: NSLayoutConstraint.Axis) -> CGFloat {
        guard let text = titleLabel.text else {
            return 0
        }

        if text.isEmpty {
            return 0
        }

        if titleSpacing > 0 {
            return titleSpacing
        }

        return axis == .horizontal ? CGFloat(12) : CGFloat(4)
    }
}
