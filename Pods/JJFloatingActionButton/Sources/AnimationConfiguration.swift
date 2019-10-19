//
//  AnimationConfiguration.swift
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

import Foundation

// MARK: - JJAnimationSettings

/// General animation configuration settings
///
@objc public class JJAnimationSettings: NSObject {
    /// Duration of the animation.
    /// Default is `0.3`
    ///
    @objc public var duration: TimeInterval = 0.3

    /// Damping ratio of the animation.
    /// Default is `0.55`
    ///
    /// - Remark: Not used for transitions.
    ///
    @objc public var dampingRatio: CGFloat = 0.55

    /// Initial velocity of the animation.
    /// Default is `0.3`
    ///
    /// - Remark: Not used for transitions.
    ///
    @objc public var initialVelocity: CGFloat = 0.3

    /// Delay in between two item animations.
    /// Default is `0.1`
    ///
    /// - Remark: Only used for item animations.
    ///
    @objc public var interItemDelay: TimeInterval = 0.1

    /// Initializes and returns a newly allocated animation settings object with specified parameters.
    ///
    /// - Parameter duration: Duration of the animation. Default is `0.3`.
    /// - Parameter dampingRatio: Damping ratio of the animation. Default is `0.55`
    /// - Parameter initialVelocity: Initial velocity of the animation. Default is `0.3`
    /// - Parameter interItemDelay: Delay in between two item animations. Default is `0.1`
    ///
    /// - Returns: An initialized animation settings object.
    ///
    @objc public convenience init(duration: TimeInterval = 0.3,
                                  dampingRatio: CGFloat = 0.55,
                                  initialVelocity: CGFloat = 0.3,
                                  interItemDelay: TimeInterval = 0.1) {
        self.init()
        self.duration = duration
        self.dampingRatio = dampingRatio
        self.initialVelocity = initialVelocity
        self.interItemDelay = interItemDelay
    }
}

// MARK: - JJButtonAnimationConfiguration

/// Button animation configuration
///
@objc public class JJButtonAnimationConfiguration: NSObject {
    /// Initializes and returns a newly allocated button animation configuration object with the specified style.
    ///
    /// - Parameter style: The animation style.
    ///
    /// - Returns: An initialized button animation configuration object.
    ///
    @objc public init(withStyle style: JJButtonAnimationStyle) {
        self.style = style
    }

    /// Button animation style
    ///
    @objc public enum JJButtonAnimationStyle: Int {
        /// Rotate button image to given angle.
        ///
        case rotation

        /// Transition to given image.
        ///
        case transition
    }

    /// Button animation style
    /// Possible values:
    ///   - `.rotation`
    ///   - `.transition`
    ///
    @objc public let style: JJButtonAnimationStyle

    /// The angle in radian the button will rotate to when opening.
    ///
    /// - Remark: Is ignored for style `.rotation`
    ///
    @objc public var angle: CGFloat = 0

    /// The image button will transition to when opening.
    ///
    /// - Remark: Is ignored for style `.transition`
    ///
    @objc public var image: UIImage?

    /// Animation settings for opening animation.
    /// Default values are:
    ///   - `duration = 0.3`
    ///   - `dampingRatio = 0.55`
    ///   - `initialVelocity = 0.3`
    ///
    @objc public lazy var opening = JJAnimationSettings(duration: 0.3, dampingRatio: 0.55, initialVelocity: 0.3)

    /// Animation settings for closing animation.
    /// Default values are:
    ///   - `duration = 0.3`
    ///   - `dampingRatio = 0.6`
    ///   - `initialVelocity = 0.8`
    ///
    @objc public lazy var closing = JJAnimationSettings(duration: 0.3, dampingRatio: 0.6, initialVelocity: 0.8)
}

@objc public extension JJButtonAnimationConfiguration {
    /// Returns a button animation configuration that rotates the button image by given angle.
    ///
    /// - Parameter angle: The angle in radian the button will rotate to when opening.
    ///
    /// - Returns: A button animation configuration object.
    ///
    @objc static func rotation(toAngle angle: CGFloat = -.pi / 4) -> JJButtonAnimationConfiguration {
        let configuration = JJButtonAnimationConfiguration(withStyle: .rotation)
        configuration.angle = angle
        return configuration
    }

    /// Returns a button animation configuration that transitions to a given image.
    ///
    /// - Parameter image: The image button will transition to when opening.
    ///
    /// - Returns: A button animation configuration object.
    ///
    @objc static func transition(toImage image: UIImage) -> JJButtonAnimationConfiguration {
        let configuration = JJButtonAnimationConfiguration(withStyle: .transition)
        configuration.image = image
        return configuration
    }
}

// MARK: - JJItemAnimationConfiguration

/// Item animation configuration
///
@objc public class JJItemAnimationConfiguration: NSObject {
    /// Animation settings for opening animation.
    /// Default values are:
    ///   - `duration = 0.3`
    ///   - `dampingRatio = 0.55`
    ///   - `initialVelocity = 0.3`
    ///   - `interItemDelay = 0.1`
    ///
    @objc public lazy var opening = JJAnimationSettings(duration: 0.3, dampingRatio: 0.55, initialVelocity: 0.3, interItemDelay: 0.1)

    /// Animation settings for closing animation.
    /// Default values are:
    ///   - `duration = 0.3`
    ///   - `dampingRatio = 0.6`
    ///   - `initialVelocity = 0.8`
    ///   - `interItemDelay = 0.1`
    ///
    @objc public lazy var closing = JJAnimationSettings(duration: 0.15, dampingRatio: 0.6, initialVelocity: 0.8, interItemDelay: 0.1)

    /// Defines the layout of the acton items when opened.
    /// Default is a layout in a vertical line with 12 points inter item spacing
    ///
    @objc public var itemLayout: JJItemLayout = .verticalLine()

    /// Configures the items before opening. The change from open to closed state is animated.
    /// Default is a scale by factor `0.4` and `item.alpha = 0`.
    ///
    @objc public var closedState: JJItemPreparation = .scale()

    /// Configures the items for open state. The change from open to closed state is animated.
    /// Default is `item.transform = .identity` and `item.alpha = 1`.
    ///
    @objc public var openState: JJItemPreparation = .identity()
}

@objc public extension JJItemAnimationConfiguration {
    /// Returns an item animation configuration with
    ///   - `itemLayout = .verticalLine()`
    ///   - `closedState = .scale()`
    ///
    /// - Parameter interItemSpacing: The distance between two adjacent items.
    ///
    /// - Returns: An item animation configuration object.
    ///
    @objc static func popUp(withInterItemSpacing interItemSpacing: CGFloat = 12) -> JJItemAnimationConfiguration {
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = .verticalLine(withInterItemSpacing: interItemSpacing)
        configuration.closedState = .scale()
        return configuration
    }

    /// Returns an item animation configuration with
    ///   - `itemLayout = .verticalLine()`
    ///   - `closedState = .horizontalOffset()`
    ///
    /// - Parameter interItemSpacing: The distance between two adjacent items.
    ///
    /// - Returns: An item animation configuration object.
    ///
    @objc static func slideIn(withInterItemSpacing interItemSpacing: CGFloat = 12) -> JJItemAnimationConfiguration {
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = .verticalLine(withInterItemSpacing: interItemSpacing)
        configuration.closedState = .horizontalOffset()
        return configuration
    }

    /// Returns an item animation configuration with
    ///   - `itemLayout = .circular()`
    ///   - `closedState = .scale()`
    ///
    /// - Parameter radius: The distance between the center of an item and the center of the button itself.
    ///
    /// - Returns: An item animation configuration object.
    ///
    @objc static func circularPopUp(withRadius radius: CGFloat = 100) -> JJItemAnimationConfiguration {
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = .circular(withRadius: radius)
        configuration.closedState = .scale()
        configuration.opening.interItemDelay = 0.05
        configuration.closing.interItemDelay = 0.05
        return configuration
    }

    /// Returns an item animation configuration with
    ///   - `itemLayout = .circular()`
    ///   - `closedState = .circularOffset()`
    ///
    /// - Parameter radius: The distance between the center of an item and the center of the button itself.
    ///
    /// - Returns: An item animation configuration object.
    ///
    @objc static func circularSlideIn(withRadius radius: CGFloat = 100) -> JJItemAnimationConfiguration {
        let configuration = JJItemAnimationConfiguration()
        configuration.itemLayout = .circular(withRadius: radius)
        configuration.closedState = .circularOffset(distance: radius * 0.75)
        return configuration
    }
}

// MARK: - JJItemLayout

/// Item layout
///
@objc public class JJItemLayout: NSObject {
    /// A closure that defines the layout of given action items relative to an action button.
    ///
    @objc public var layout: (_ items: [JJActionItem], _ actionButton: JJFloatingActionButton) -> Void

    /// Initializes and returns a newly allocated item layout object with given layout closure.
    ///
    /// - Parameter layout: A closure that defines the the layout of given action items relative to an action button.
    ///
    /// - Returns: An initialized item layout object.
    ///
    @objc public init(layout: @escaping (_ items: [JJActionItem], _ actionButton: JJFloatingActionButton) -> Void) {
        self.layout = layout
    }

    /// Returns an item layout object that places the items in a vertical line with given inter item spacing.
    ///
    /// - Parameter interItemSpacing: The distance between two adjacent items.
    ///
    /// - Returns: An item layout object.
    ///
    @objc static func verticalLine(withInterItemSpacing interItemSpacing: CGFloat = 12) -> JJItemLayout {
        return JJItemLayout { items, actionButton in
            var previousItem: JJActionItem?
            for item in items {
                let previousView = previousItem ?? actionButton
                item.bottomAnchor.constraint(equalTo: previousView.topAnchor, constant: -interItemSpacing).isActive = true
                item.circleView.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor).isActive = true
                previousItem = item
            }
        }
    }

    /// Returns an item layout object that places the items in a circle around the action button with given radius.
    ///
    /// - Parameter radius: The distance between the center of an item and the center of the button itself.
    ///
    /// - Returns: An item layout object.
    ///
    @objc static func circular(withRadius radius: CGFloat = 100) -> JJItemLayout {
        return JJItemLayout { items, actionButton in
            let numberOfItems = items.count
            var index: Int = 0
            for item in items {
                let angle = JJItemAnimationConfiguration.angleForItem(at: index, numberOfItems: numberOfItems, actionButton: actionButton)
                let horizontalDistance = radius * cos(angle)
                let verticalDistance = radius * sin(angle)

                item.circleView.centerXAnchor.constraint(equalTo: actionButton.centerXAnchor, constant: horizontalDistance).isActive = true
                item.circleView.centerYAnchor.constraint(equalTo: actionButton.centerYAnchor, constant: verticalDistance).isActive = true

                index += 1
            }
        }
    }
}

// MARK: - JJItemPreparation

/// Item preparation
///
@objc public class JJItemPreparation: NSObject {
    /// A closure that prepares a given action item for animation.
    ///
    @objc public var prepare: (_ item: JJActionItem, _ index: Int, _ numberOfItems: Int, _ actionButton: JJFloatingActionButton) -> Void

    /// Initializes and returns a newly allocated item preparation object with given prepare closure.
    ///
    /// - Parameter layout: A closure that defines the the layout of given action items relative to an action button.
    ///
    /// - Returns: An initialized item layout object.
    ///
    @objc public init(prepare: @escaping (_ item: JJActionItem,
                                          _ index: Int,
                                          _ numberOfItems: Int,
                                          _ actionButton: JJFloatingActionButton) -> Void) {
        self.prepare = prepare
    }

    /// Returns an item preparation object that
    ///   - sets `item.alpha` to `1` and
    ///   - `item.transform` to `identitiy`.
    ///
    /// - Returns: An item preparation object.
    ///
    @objc static func identity() -> JJItemPreparation {
        return JJItemPreparation { item, _, _, _ in
            item.transform = .identity
            item.alpha = 1
        }
    }

    /// Returns an item preparation object that
    ///   - sets `item.alpha` to `0` and
    ///   - scales the item by given ratio.
    ///
    /// - Parameter ratio: The factor by which the item is scaled
    ///
    /// - Returns: An item preparation object.
    ///
    @objc static func scale(by ratio: CGFloat = 0.4) -> JJItemPreparation {
        return JJItemPreparation { item, _, _, _ in
            item.scale(by: ratio)
            item.alpha = 0
        }
    }

    /// Returns an item preparation object that
    ///   - sets `item.alpha` to `0`,
    ///   - offsets the item by given values and
    ///   - scales the item by given ratio.
    ///
    /// - Parameter translationX: The value in points by which the item is offsetted horizontally
    /// - Parameter translationY: The value in points by which the item is offsetted vertically
    /// - Parameter scale: The factor by which the item is scaled
    ///
    /// - Returns: An item preparation object.
    ///
    @objc static func offset(translationX: CGFloat, translationY: CGFloat, scale: CGFloat = 0.4) -> JJItemPreparation {
        return JJItemPreparation { item, _, _, _ in
            item.scale(by: scale, translationX: translationX, translationY: translationY)
            item.alpha = 0
        }
    }

    /// Returns an item preparation object that
    ///   - sets `item.alpha` to `0`,
    ///   - offsets the item horizontally by given values.
    ///
    /// - Parameter distance: The value in points by which the item is offsetted horizontally
    ///                       towards the closest vertical edge of the screen.
    /// - Parameter scale: The factor by which the item is scaled
    ///
    /// - Remark: The item is offseted towards the closest vertical edge of the screen.
    ///
    /// - Returns: An item preparation object.
    ///
    @objc static func horizontalOffset(distance: CGFloat = 50, scale: CGFloat = 0.4) -> JJItemPreparation {
        return JJItemPreparation { item, _, _, actionButton in
            let translationX = actionButton.isOnLeftSideOfScreen ? -distance : distance
            item.scale(by: scale, translationX: translationX)
            item.alpha = 0
        }
    }

    /// Returns an item preparation object that
    ///   - sets `item.alpha` to `0`,
    ///   - offsets the item horizontally by given values.
    ///
    /// - Parameter distance: The value in points by which the item is offsetted
    ///                       towards the action button.
    /// - Parameter scale: The factor by which the item is scaled
    ///
    /// - Remark: The item is offseted towards the action button.
    ///
    /// - Returns: An item preparation object.
    ///
    @objc static func circularOffset(distance: CGFloat = 50, scale: CGFloat = 0.4) -> JJItemPreparation {
        return JJItemPreparation { item, index, numberOfItems, actionButton in
            let itemAngle = JJItemAnimationConfiguration.angleForItem(at: index,
                                                                      numberOfItems: numberOfItems,
                                                                      actionButton: actionButton)
            let transitionAngle = itemAngle + CGFloat.pi
            let translationX = distance * cos(transitionAngle)
            let translationY = distance * sin(transitionAngle)
            item.scale(by: scale, translationX: translationX, translationY: translationY)
            item.alpha = 0
        }
    }
}

// MARK: - Helper

internal extension JJItemAnimationConfiguration {
    static func angleForItem(at index: Int, numberOfItems: Int, actionButton: JJFloatingActionButton) -> CGFloat {
        precondition(numberOfItems > 0)
        precondition(index >= 0)
        precondition(index < numberOfItems)

        let startAngle: CGFloat = actionButton.isOnLeftSideOfScreen ? 2 * .pi : .pi
        let endAngle: CGFloat = 1.5 * .pi

        switch (numberOfItems, index) {
        case (1, _):
            return (startAngle + endAngle) / 2
        case (2, 0):
            return startAngle + 0.1 * (endAngle - startAngle)
        case (2, 1):
            return endAngle - 0.1 * (endAngle - startAngle)
        default:
            return startAngle + CGFloat(index) * (endAngle - startAngle) / (CGFloat(numberOfItems) - 1)
        }
    }
}

fileprivate extension JJActionItem {
    func scale(by factor: CGFloat, translationX: CGFloat = 0, translationY: CGFloat = 0) {
        let scale = scaleTransformation(factor: factor)
        let translation = CGAffineTransform(translationX: translationX, y: translationY)
        transform = scale.concatenating(translation)
    }
}

fileprivate extension JJActionItem {
    func scaleTransformation(factor: CGFloat) -> CGAffineTransform {
        let scale = CGAffineTransform(scaleX: factor, y: factor)

        let center = circleView.center
        let circleCenterScaled = point(center, transformed: scale)
        let translationX = center.x - circleCenterScaled.x
        let translationY = center.y - circleCenterScaled.y
        let translation = CGAffineTransform(translationX: translationX, y: translationY)
        return scale.concatenating(translation)
    }

    func point(_ point: CGPoint, transformed transform: CGAffineTransform) -> CGPoint {
        let anchorPoint = CGPoint(x: bounds.width * layer.anchorPoint.x, y: bounds.height * layer.anchorPoint.y)
        let relativePoint = CGPoint(x: point.x - anchorPoint.x, y: point.y - anchorPoint.y)
        let transformedPoint = relativePoint.applying(transform)
        let result = CGPoint(x: anchorPoint.x + transformedPoint.x, y: anchorPoint.y + transformedPoint.y)
        return result
    }
}

internal extension UIView {
    var isOnLeftSideOfScreen: Bool {
        return isOnLeftSide(ofView: UIApplication.shared.keyWindow)
    }

    func isOnLeftSide(ofView superview: UIView?) -> Bool {
        guard let superview = superview else {
            return false
        }
        let point = convert(center, to: superview)
        return point.x < superview.bounds.size.width / 2
    }
}
