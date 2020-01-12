//
//  JJFloatingActionButton.swift
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

/// A floating action button.
///
///   ````
///   let actionButton = JJFloatingActionButton()
///
///   actionButton.addItem(title: "item 1", image: image1) { item in
///       // do something
///   }
///
///   actionButton.addItem(title: "item 2", image: image2) { item in
///       // do something
///   }
///
///   view.addSubview(actionButton)
///   ````
///
@objc @IBDesignable public class JJFloatingActionButton: UIControl {
    /// The delegate object for the floating action button.
    ///
    @objc public weak var delegate: JJFloatingActionButtonDelegate?

    /// The list of action items.
    /// Default is `[]`.
    ///
    /// - SeeAlso: `enabledItems`
    ///
    @objc public var items: [JJActionItem] = [] {
        didSet {
            items.forEach { item in
                setupItem(item)
            }
            configureButtonImage()
        }
    }

    /// The background color of the floating action button.
    /// Default is `UIColor(hue: 0.31, saturation: 0.37, brightness: 0.76, alpha: 1.00)`.
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

    /// The background color of the floating action button with highlighted state.
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

    /// The image displayed on the button by default.
    /// When only one `JJActionItem` is added and `handleSingleActionDirectly` is enabled,
    /// the image from the item is shown istead.
    /// When set to `nil` an image of a plus sign is used.
    /// Default is `nil`.
    ///
    /// - SeeAlso: `imageView`
    ///
    @objc @IBInspectable public dynamic var buttonImage: UIImage? {
        didSet {
            configureButtonImage()
        }
    }

    /// The tint color of the image view.
    /// Default is `UIColor.white`.
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

    /// The default diameter of the floating action button.
    /// This is ignored if the size is defined by autolayout.
    /// Default is `56`.
    ///
    @objc @IBInspectable public dynamic var buttonDiameter: CGFloat = 56 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    /// The size of an action item in relation to the floating action button.
    /// Default is `0.75`.
    ///
    @objc @IBInspectable public dynamic var itemSizeRatio: CGFloat = 0.75

    /// The opening style of the floating action button itself.
    /// Default is `JJButtonAnimationConfiguration.rotation()`
    ///
    /// - SeeAlso: `JJButtonAnimationConfiguration`
    /// - SeeAlso: `itemAnimationConfiguration`
    ///
    public var buttonAnimationConfiguration: JJButtonAnimationConfiguration = .rotation()

    /// The opening style of the action items.
    /// Default is `JJItemAnimationConfiguration.popUp()`
    ///
    /// - SeeAlso: `JJItemAnimationConfiguration`
    /// - SeeAlso: `buttonAnimationConfiguration`
    ///
    public var itemAnimationConfiguration: JJItemAnimationConfiguration = .popUp()

    /// When enabled and only one action item is added, the floating action button will not open,
    /// but the action from the action item will be executed direclty when the button is tapped.
    /// Also the image of the floating action button will be replaced with the one from the action item.
    ///
    /// Default is `true`.
    ///
    @objc @IBInspectable public var handleSingleActionDirectly: Bool = true {
        didSet {
            configureButtonImage()
        }
    }

    /// The current state of the floating action button.
    /// Possible values are
    ///   - `.opening`
    ///   - `.open`
    ///   - `.closing`
    ///   - `.closed`
    ///
    @objc public internal(set) var buttonState: JJFloatingActionButtonState = .closed

    /// The round background view of the floating action button.
    /// Read only.
    ///
    /// - SeeAlso: `buttonColor`
    /// - SeeAlso: `highlightedButtonColor`
    ///
    @objc public fileprivate(set) lazy var circleView: JJCircleView = {
        let view = JJCircleView()
        view.isUserInteractionEnabled = false
        view.color = Styles.defaultButtonColor
        return view
    }()

    /// The image view of the floating action button.
    /// Read only.
    ///
    /// - Warning: Setting the image of the `imageView` directly will not work.
    ///            Use `buttonImage` instead.
    ///
    /// - SeeAlso: `buttonImage`
    /// - SeeAlso: `buttonImageColor`
    ///
    @objc public fileprivate(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.backgroundColor = .clear
        imageView.tintColor = Styles.defaultButtonImageColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The overlay view.
    /// Default background color is `UIColor(white: 0, alpha: 0.5)`.
    /// Read only.
    ///
    @objc public fileprivate(set) lazy var overlayView: UIControl = {
        let control = UIControl()
        control.isUserInteractionEnabled = true
        control.backgroundColor = Styles.defaultOverlayColor
        control.addTarget(self, action: #selector(overlayViewWasTapped), for: .touchUpInside)
        control.isEnabled = false
        control.alpha = 0
        return control
    }()

    /// Initializes and returns a newly allocated floating action button object with the specified frame rectangle.
    ///
    /// - Parameter frame: The frame rectangle for the floating action button, measured in points.
    ///                    The origin of the frame is relative to the superview in which you plan to add it.
    ///                    This method uses the frame rectangle to set the center and bounds properties accordingly.
    ///
    /// - Returns: An initialized floating action button object.
    ///
    /// - SeeAlso: init?(coder: NSCoder)
    ///
    public override init(frame: CGRect) {
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

    /// Initializes and returns a newly allocated floating action button object with the specified image and action.
    ///
    /// - Parameter image: The image of the action item. Default is `nil`.
    /// - Parameter action: The action handler of the action item. Default is `nil`.
    ///
    /// - Returns: An initialized floating action button object.
    ///
    /// - SeeAlso: init(frame: CGRect)
    ///
    @objc public convenience init(image: UIImage, action: ((JJActionItem) -> Void)? = nil) {
        self.init()
        addItem(title: nil, image: image, action: action)
    }

    internal lazy var itemContainerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    internal var currentButtonAnimationConfiguration: JJButtonAnimationConfiguration?
    internal var currentItemAnimationConfiguration: JJItemAnimationConfiguration?
    internal var openItems: [JJActionItem] = []

    fileprivate var defaultItemConfiguration: ((JJActionItem) -> Void)?
}

// MARK: - Public Methods

@objc public extension JJFloatingActionButton {
    /// Add an action item with title, image and action to the list of items.
    /// The item will be pre configured with the default values.
    ///
    /// - Parameter title: The title of the action item. Default is `nil`.
    /// - Parameter image: The image of the action item. Default is `nil`.
    /// - Parameter action: The action handler of the action item. Default is `nil`.
    ///
    /// - Returns: The item that was added. This can be configured after it has been added.
    ///
    @discardableResult func addItem(title: String? = nil,
                                    image: UIImage? = nil,
                                    action: ((JJActionItem) -> Void)? = nil) -> JJActionItem {
        let item = JJActionItem()
        item.titleLabel.text = title
        item.imageView.image = image
        item.action = action

        addItem(item)

        return item
    }

    /// Add an action item to the list of items.
    /// The item will be updated with the default configuration values.
    ///
    /// - Parameter item: The action item.
    ///
    /// - Returns: The item that was add. Its configuration can be changed after it has been added.
    ///
    func addItem(_ item: JJActionItem) {
        items.append(item)
        setupItem(item)
        configureButtonImage()
    }

    /// Calls the given closure on each item that is or was added to the floating action button.
    /// Default is `nil`.
    ///
    ///   ````
    ///   let actionButton = JJFloatingActionButton()
    ///
    ///   actionButton.configureDefaultItem { item in
    ///       item.imageView.contentMode = .scaleAspectFill
    ///
    ///       item.titleLabel.font = .systemFont(ofSize: 14)
    ///
    ///       item.layer.shadowColor = UIColor.black.cgColor
    ///       item.layer.shadowOpacity = 0.3
    ///       item.layer.shadowOffset = CGSize(width: 1, height: 1)
    ///       item.layer.shadowRadius = 0
    ///   }
    ///   ````
    ///
    /// - Parameter body: A closure that takes an action item as a parameter.
    ///
    func configureDefaultItem(_ body: ((JJActionItem) -> Void)?) {
        defaultItemConfiguration = body
        items.forEach { item in
            defaultItemConfiguration?(item)
        }
    }

    /// All items that will be shown when floating action button ist opened.
    /// This excludes hidden items and items that have user interaction disabled.
    ///
    var enabledItems: [JJActionItem] {
        return items.filter { item -> Bool in
            !item.isHidden && item.isUserInteractionEnabled
        }
    }
}

// MARK: - UIControl

extension JJFloatingActionButton {
    /// A Boolean value indicating whether the action button draws a highlight.
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

// MARK: - UIView

extension JJFloatingActionButton {
    /// The natural size for the floating action button.
    ///
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: buttonDiameter, height: buttonDiameter)
    }
}

// MARK: - Setup

fileprivate extension JJFloatingActionButton {
    func setup() {
        backgroundColor = .clear
        clipsToBounds = false
        isUserInteractionEnabled = true
        addTarget(self, action: #selector(buttonWasTapped), for: .touchUpInside)

        layer.shadowColor = Styles.defaultShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2

        addSubview(circleView)
        circleView.addSubview(imageView)

        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        circleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        circleView.widthAnchor.constraint(equalTo: circleView.heightAnchor).isActive = true
        circleView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor).isActive = true
        circleView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor).isActive = true
        let widthConstraint = circleView.widthAnchor.constraint(equalTo: widthAnchor)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        let heightConstraint = circleView.heightAnchor.constraint(equalTo: heightAnchor)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        let imageSizeMuliplier = CGFloat(1 / sqrt(2))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(lessThanOrEqualTo: circleView.widthAnchor, multiplier: imageSizeMuliplier).isActive = true
        imageView.heightAnchor.constraint(lessThanOrEqualTo: circleView.heightAnchor, multiplier: imageSizeMuliplier).isActive = true

        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
        circleView.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        circleView.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)

        configureButtonImage()
    }

    func configureButtonImage() {
        imageView.image = currentButtonImage
    }

    func setupItem(_ item: JJActionItem) {
        item.imageView.tintColor = buttonColor

        item.layer.shadowColor = layer.shadowColor
        item.layer.shadowOpacity = layer.shadowOpacity
        item.layer.shadowOffset = layer.shadowOffset
        item.layer.shadowRadius = layer.shadowRadius

        item.addTarget(self, action: #selector(itemWasTapped(sender:)), for: .touchUpInside)

        defaultItemConfiguration?(item)
    }
}

// MARK: - Helper

internal extension JJFloatingActionButton {
    var currentButtonImage: UIImage? {
        if isSingleActionButton, let image = enabledItems.first?.imageView.image {
            return image
        }

        if buttonImage == nil {
            buttonImage = Styles.plusImage
        }

        return buttonImage
    }

    var isSingleActionButton: Bool {
        return handleSingleActionDirectly && enabledItems.count == 1
    }
}

// MARK: - Actions

fileprivate extension JJFloatingActionButton {
    @objc func buttonWasTapped() {
        switch buttonState {
        case .open:
            close()

        case .closed:
            handleSingleActionOrOpen()

        default:
            break
        }
    }

    @objc func itemWasTapped(sender: JJActionItem) {
        close()
        sender.callAction()
    }

    @objc func overlayViewWasTapped() {
        close()
    }

    func handleSingleActionOrOpen() {
        guard !enabledItems.isEmpty else {
            return
        }

        if isSingleActionButton {
            let item = enabledItems.first
            item?.callAction()
        } else {
            open()
        }
    }
}
