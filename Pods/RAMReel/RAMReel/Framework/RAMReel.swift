//
//  RAMReel.swift
//  RAMReel
//
//  Created by Mikhail Stepkin on 4/21/15.
//  Copyright (c) 2015 Ramotion. All rights reserved.
//

import UIKit

// MARK: - String conversions

/**
 Renderable
 --
 
 Types that implement this protocol are expected to have string representation.
 This protocol is separated from Printable and it's description property on purpose.
 */
public protocol Renderable {
    /**
     Implement this method in order to be able to put data to textField field
     Simplest implementation may return just object description
     */
    func render() -> String
}

extension String: Renderable {
    /// String is trivially renderable: it renders to itself.
    public func render() -> String {
        return self
    }
}

/**
 Parsable
 --
 
 Types that implement this protocol are expected to be constructible from string
 */
public protocol Parsable {
    /**
     Implement this method in order to be able to construct your data from string
     
     - parameter string: String to parse.
     - returns: Value of type, implementing this protocol if successful, `nil` otherwise.
     */
    static func parse(_ string: String) -> Self?
}

extension String: Parsable {
    /**
     String is trivially parsable: it parses to itself.
     
     - parameter string: String to parse.
     - returns: `string` parameter value.
     */
    public static func parse(_ string: String) -> String? {
        return string
    }
}

// MARK: - Library root class

/**
 RAMReel
 --
 
 Reel class
 */
open class RAMReel
<
    CellClass: UICollectionViewCell,
    TextFieldClass: UITextField,
    DataSource: FlowDataSource
>
    where
    CellClass: ConfigurableCell,
    CellClass.DataType == DataSource.ResultType,
    DataSource.QueryType == String,
    DataSource.ResultType: Renderable,
    DataSource.ResultType: Parsable
{
    /// Container view
    public let view: UIView
    
    /// Gradient View
    let gradientView: GradientView
    
    // MARK: TextField

    let reactor: TextFieldReactor<DataSource, CollectionWrapperClass>
    let textField: TextFieldClass
    let returnTarget: TextFieldTarget
    private var untouchedTarget: TextFieldTarget?
    let gestureTarget: GestureTarget
    let dataFlow: DataFlow<DataSource, CollectionViewWrapper<CellClass.DataType, CellClass>>
    
    /// Delegate of text field, is used for extra control over text field.
    open var textFieldDelegate: UITextFieldDelegate? {
        set { textField.delegate = newValue }
        get { return textField.delegate }
    }
    
    /// Use this method when you want textField release input focus.
    open func resignFirstResponder() {
        textField.resignFirstResponder()
    }
    
    // MARK: CollectionView

    typealias CollectionWrapperClass = CollectionViewWrapper<DataSource.ResultType, CellClass>
    let wrapper: CollectionWrapperClass
    /// Collection view with data items.
    public let collectionView: UICollectionView
    
    // MARK: Data Source

    /// Data source of RAMReel
    public let dataSource: DataSource
    
    // MARK: Selected Item

    /**
     Use this property to get which item was selected.
     Value is nil, if data source output is empty.
     */
    open var selectedItem: DataSource.ResultType? {
        print("ohskbj")
        return textField.text.flatMap(DataSource.ResultType.parse)
    }
    
    // MARK: Hooks

    /**
     Type of selected item change callback hook
     */
    public typealias HookType = (DataSource.ResultType) -> Void
    /// This hooks that are called on selected item change
    open var hooks: [HookType] = []
    
    // MARK: Layout

    let layout: UICollectionViewLayout = RAMCollectionViewLayout()
    
    // MARK: Theme

    /// Visual appearance theme
    open var theme: Theme = RAMTheme.sharedTheme {
        didSet {
            guard theme.font != oldValue.font
                ||
                theme.listBackgroundColor != oldValue.listBackgroundColor
                ||
                theme.textColor != oldValue.textColor
            else {
                return
            }
            
            updateVisuals()
            updatePlaceholder(placeholder)
        }
    }
    
    fileprivate func updateVisuals() {
        view.tintColor = theme.textColor
        print("te9")
        textField.font = theme.font
        textField.textColor = theme.textColor
        (textField as UITextField).tintColor = theme.textColor
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        gradientView.listBackgroundColor = theme.listBackgroundColor
        
        view.layer.mask = gradientView.layer
        view.backgroundColor = UIColor.clear
        
        collectionView.backgroundColor = theme.listBackgroundColor
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        
        updatePlaceholder(placeholder)
        
        wrapper.theme = theme
        
        let visibleCells: [CellClass] = collectionView.visibleCells as! [CellClass]
        visibleCells.forEach { (cell: CellClass) in
            var cell = cell
            cell.theme = self.theme
        }
    }
    
    /// Placeholder in text field.
    open var placeholder: String = "" {
        willSet {
            updatePlaceholder(newValue)
            print("place")
        }
    }
    
    fileprivate func updatePlaceholder(_ placeholder: String) {
        print("te10")
        let themeFont = theme.font
        let size = textField.textRect(forBounds: textField.bounds).height * themeFont.pointSize / themeFont.lineHeight * 0.8
        let font = (size > 0) ? (UIFont(name: themeFont.fontName, size: size) ?? themeFont) : themeFont
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: theme.textColor.withAlphaComponent(0.5)
        ])
    }
    
    var bottomConstraints: [NSLayoutConstraint] = []
    let keyboardCallbackWrapper: NotificationCallbackWrapper
    let attemptToDodgeKeyboard: Bool
    
    // MARK: Initialization

    /**
     Creates new `RAMReel` instance.
    
     - parameters:
         - frame: Rect that Reel will occupy
         - dataSource: Object of type that implements FlowDataSource protocol
         - placeholder: Optional text field placeholder
         - hook: Optional initial value change hook
         - attemptToDodgeKeyboard: attempt to center the widget on the available screen area when the iOS
               keyboard appears (will cause issues if the widget isn't being used in full screen)
     */
    public init(frame: CGRect, dataSource: DataSource, placeholder: String = "", attemptToDodgeKeyboard: Bool, hook: HookType? = nil) {
        print("initi")
        view = UIView(frame: frame)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        self.dataSource = dataSource
        
        self.attemptToDodgeKeyboard = attemptToDodgeKeyboard
        
        if let h = hook {
            hooks.append(h)
        }
        
        // MARK: CollectionView

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        wrapper = CollectionViewWrapper(collectionView: collectionView, theme: theme)
        
        // MARK: TextField

        textField = TextFieldClass()
        textField.returnKeyType = UIReturnKeyType.done
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        self.placeholder = placeholder
        
        dataFlow = dataSource *> wrapper
        reactor = textField <&> dataFlow
        
        gradientView = GradientView(frame: view.bounds)
        gradientView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        gradientView.translatesAutoresizingMaskIntoConstraints = true
        view.insertSubview(gradientView, at: 0)
        
        views = [
            "collectionView": collectionView,
            "textField": textField
        ]
        
        keyboardCallbackWrapper = NotificationCallbackWrapper(name: UIResponder.keyboardWillChangeFrameNotification.rawValue)
        
        returnTarget = TextFieldTarget()
        gestureTarget = GestureTarget()
        
        let controlEvents = UIControl.Event.editingDidEndOnExit
        returnTarget.beTargetFor(textField, controlEvents: controlEvents) { [weak self] textField in
            guard let `self` = self else { return }
            if
                let text = textField.text,
                let item = DataSource.ResultType.parse(text)
            {
                for hook in self.hooks {
                    hook(item)
                }
                self.wrapper.data = []
            }
        }
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.tap) { [weak self] _, _ in
            if
                let `self` = self,
                let selectedItem = self.wrapper.selectedItem
            {
                self.textField.becomeFirstResponder()
                self.textField.text = nil
                self.textField.insertText(selectedItem.render())
                print("te6")
            }
        }
        
        gestureTarget.recognizeFor(collectionView, type: GestureTarget.GestureType.swipe) { _, _ in }
        
        weak var s = self
        
        untouchedTarget = TextFieldTarget(controlEvents: UIControl.Event.editingChanged, textField: textField, hook: { _ in s?.placeholder = "" })
        
        keyboardCallbackWrapper.callback = { [weak self] notification in
            guard let `self` = self else { return }
            
            if let userInfo = (notification as NSNotification).userInfo as! [String: AnyObject]?,
               let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey]?.cgRectValue,
               let animDuration: TimeInterval = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]?.doubleValue,
               let animCurveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey]?.uintValue
            {
                if attemptToDodgeKeyboard {
                    let animCurve = UIView.AnimationOptions(rawValue: UInt(animCurveRaw))
                    
                    for bottomConstraint in self.bottomConstraints {
                        bottomConstraint.constant = self.view.frame.height / 2
                    }
                    
                    UIView.animate(withDuration: animDuration,
                                   delay: 0.0,
                                   options: animCurve,
                                   animations: {
                                       self.gradientView.layer.frame.size.height = endFrame.origin.y
                                       self.textField.layoutIfNeeded()
                                       print("te4")
                                   }, completion: nil)
                }
            }
        }
        
        updateVisuals()
        addHConstraints()
        addVConstraints()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Call this method to update `RAMReel` visuals before showing it.
    open func prepareForViewing() {
        updateVisuals()
        updatePlaceholder(placeholder)
    }
    
    /// If you use `RAMReel` to enter a set of values from the list call this method before each input.
    open func prepareForReuse() {
        textField.text = ""
        dataFlow.transport("")
    }
    
    // MARK: Constraints

    fileprivate let views: [String: UIView]
    
    func addHConstraints() {
        // Horisontal constraints
        let collectionHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views)
        view.addConstraints(collectionHConstraints)
        
        let textFieldHConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[textField]-(20)-|", options: NSLayoutConstraint.FormatOptions.alignAllCenterX, metrics: nil, views: views)
        view.addConstraints(textFieldHConstraints)
    }
    
    func addVConstraints() {
        // Vertical constraints
        let collectionVConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(collectionVConstraints)
        
        if let bottomConstraint = collectionVConstraints.filter({ $0.firstAttribute == NSLayoutConstraint.Attribute.bottom }).first {
            bottomConstraints.append(bottomConstraint)
        }
        
        let textFieldVConstraints = [NSLayoutConstraint(item: textField, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: collectionView, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0)] + NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(>=44)]", options: NSLayoutConstraint.FormatOptions.alignAllCenterY, metrics: nil, views: views)
        view.addConstraints(textFieldVConstraints)
    }
}

// MARK: - Helpers

class NotificationCallbackWrapper: NSObject {
    @objc func callItBack(_ notification: Notification) {
        callback?(notification)
    }
    
    typealias NotificationToVoid = (Notification) -> Void
    var callback: NotificationToVoid?
    
    init(name: String, object: AnyObject? = nil) {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(NotificationCallbackWrapper.callItBack(_:)),
            name: NSNotification.Name(rawValue: name),
            object: object
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

final class GestureTarget: NSObject, UIGestureRecognizerDelegate {
    static let gestureSelector = #selector(GestureTarget.gesture(_:))
    
    override init() {
        super.init()
    }
    
    init(type: GestureType, view: UIView, hook: @escaping HookType) {
        super.init()
        
        recognizeFor(view, type: type, hook: hook)
        print("te2")
    }
    
    typealias HookType = (UIView, UIGestureRecognizer) -> Void
    
    enum GestureType {
        case tap
        case longPress
        case swipe
    }
    
    var hooks: [UIGestureRecognizer: (UIView, HookType)] = [:]
    func recognizeFor(_ view: UIView, type: GestureType, hook: @escaping HookType) {
        let gestureRecognizer: UIGestureRecognizer
        switch type {
        case .tap:
            gestureRecognizer = UITapGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .longPress:
            gestureRecognizer = UILongPressGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        case .swipe:
            gestureRecognizer = UISwipeGestureRecognizer(target: self, action: GestureTarget.gestureSelector)
        }
        
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        let item: (UIView, HookType) = (view, hook)
        hooks[gestureRecognizer] = item
        print("te")
    }
    
    deinit {
        for (recognizer, (view, _)) in hooks {
            view.removeGestureRecognizer(recognizer)
        }
    }
    
    @objc func gesture(_ gestureRecognizer: UIGestureRecognizer) {
        if let (textField, hook) = hooks[gestureRecognizer] {
            hook(textField, gestureRecognizer)
            print("te7")
        }
    }
    
    // Gesture recognizer delegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("te8")
        return true
    }
}
