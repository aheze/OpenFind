//
//  JJFloatingActionButton+Animation.swift
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

@objc public extension JJFloatingActionButton {
    /// Open the floating action button and show all action items.
    ///
    /// - Parameter animated: When true, button will be opened with an animation. Default is `true`.
    /// - Parameter completion: Will be handled upon completion. Default is `nil`.
    ///
    /// - Remark: Hidden items and items that have user interaction disabled are omitted.
    ///
    /// - SeeAlso: `buttonAnimationConfiguration`
    /// - SeeAlso: `itemAnimationConfiguration`
    ///
    func open(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let superview = superview, buttonState == .closed, !enabledItems.isEmpty, !isSingleActionButton else {
            return
        }

        buttonState = .opening
        delegate?.floatingActionButtonWillOpen?(self)

        storeAnimationState()

        superview.bringSubviewToFront(self)
        addOverlayView(to: superview)
        addItems(to: superview)
        itemContainerView.setNeedsLayout()
        itemContainerView.layoutIfNeeded()

        let animationGroup = DispatchGroup()

        showOverlay(animated: animated, group: animationGroup)
        openButton(withConfiguration: currentButtonAnimationConfiguration!,
                   animated: animated,
                   group: animationGroup)
        openItems(animated: animated, group: animationGroup)

        let groupCompletion: () -> Void = {
            self.buttonState = .open
            self.delegate?.floatingActionButtonDidOpen?(self)
            completion?()
        }
        if animated {
            animationGroup.notify(queue: .main, execute: groupCompletion)
        } else {
            groupCompletion()
        }
    }

    /// Close the floating action button and hide all action items.
    ///
    /// - Parameter animated: When true, button will be close with an animation. Default is `true`.
    /// - Parameter completion: Will be handled upon completion. Default is `nil`.
    ///
    /// - SeeAlso: `buttonAnimationConfiguration`
    /// - SeeAlso: `itemAnimationConfiguration`
    ///
    func close(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard buttonState == .open else {
            return
        }
        buttonState = .closing
        delegate?.floatingActionButtonWillClose?(self)
        overlayView.isEnabled = false

        let animationGroup = DispatchGroup()

        hideOverlay(animated: animated, group: animationGroup)
        closeButton(withConfiguration: currentButtonAnimationConfiguration!,
                    animated: animated,
                    group: animationGroup)
        closeItems(animated: animated, group: animationGroup)

        let groupCompletion: () -> Void = {
            self.openItems.forEach { item in
                item.removeFromSuperview()
            }
            self.resetAnimationState()
            self.itemContainerView.removeFromSuperview()
            self.buttonState = .closed
            self.delegate?.floatingActionButtonDidClose?(self)
            completion?()
        }
        if animated {
            animationGroup.notify(queue: .main, execute: groupCompletion)
        } else {
            groupCompletion()
        }
    }
}

// MARK: - Animation State

fileprivate extension JJFloatingActionButton {
    func storeAnimationState() {
        openItems = enabledItems
        currentItemAnimationConfiguration = itemAnimationConfiguration
        currentButtonAnimationConfiguration = buttonAnimationConfiguration
    }

    func resetAnimationState() {
        openItems.removeAll()
        currentButtonAnimationConfiguration = nil
        currentItemAnimationConfiguration = nil
    }
}

// MARK: - Overlay Animation

fileprivate extension JJFloatingActionButton {
    func addOverlayView(to superview: UIView) {
        overlayView.isEnabled = true
        superview.insertSubview(overlayView, belowSubview: self)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        overlayView.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }

    func showOverlay(animated: Bool, group: DispatchGroup) {
        let buttonAnimation: () -> Void = {
            self.overlayView.alpha = 1
        }
        UIView.animate(duration: 0.3,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0.3,
                       animations: buttonAnimation,
                       group: group,
                       animated: animated)
    }

    func hideOverlay(animated: Bool, group: DispatchGroup) {
        let animations: () -> Void = {
            self.overlayView.alpha = 0
        }
        let completion: (Bool) -> Void = { _ in
            self.overlayView.removeFromSuperview()
        }
        UIView.animate(duration: 0.3,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0.8,
                       animations: animations,
                       completion: completion,
                       group: group,
                       animated: animated)
    }
}

// MARK: - Button Animation

fileprivate extension JJFloatingActionButton {
    func openButton(withConfiguration configuration: JJButtonAnimationConfiguration,
                    animated: Bool,
                    group: DispatchGroup) {
        switch configuration.style {
        case .rotation:
            rotateButton(toAngle: configuration.angle,
                         settings: configuration.opening,
                         group: group,
                         animated: animated)
        case .transition:
            transistion(toImage: configuration.image,
                        settings: configuration.opening,
                        animated: animated,
                        group: group)
        }
    }

    func closeButton(withConfiguration configuration: JJButtonAnimationConfiguration,
                     animated: Bool,
                     group: DispatchGroup) {
        switch configuration.style {
        case .rotation:
            rotateButton(toAngle: 0,
                         settings: configuration.closing,
                         group: group,
                         animated: animated)
        case .transition:
            transistion(toImage: currentButtonImage,
                        settings: configuration.closing,
                        animated: animated,
                        group: group)
        }
    }

    func rotateButton(toAngle angle: CGFloat,
                      settings: JJAnimationSettings,
                      group: DispatchGroup,
                      animated: Bool) {
        let animation: () -> Void = {
            self.circleView.transform = CGAffineTransform(rotationAngle: angle)
        }

        UIView.animate(duration: settings.duration,
                       usingSpringWithDamping: settings.dampingRatio,
                       initialSpringVelocity: settings.initialVelocity,
                       animations: animation,
                       group: group,
                       animated: animated)
    }

    func transistion(toImage image: UIImage?,
                     settings: JJAnimationSettings,
                     animated: Bool,
                     group: DispatchGroup) {
        let transition: () -> Void = {
            self.imageView.image = image
        }
        UIView.transition(with: imageView,
                          duration: settings.duration,
                          animations: transition,
                          group: group,
                          animated: animated)
    }
}

// MARK: - Items Animation

fileprivate extension JJFloatingActionButton {
    func addItems(to superview: UIView) {
        precondition(currentItemAnimationConfiguration != nil)
        let configuration = currentItemAnimationConfiguration!

        superview.insertSubview(itemContainerView, belowSubview: self)

        openItems.forEach { item in
            item.alpha = 0
            item.transform = .identity
            itemContainerView.addSubview(item)

            item.translatesAutoresizingMaskIntoConstraints = false

            item.circleView.heightAnchor.constraint(equalTo: circleView.heightAnchor,
                                                    multiplier: itemSizeRatio).isActive = true

            item.topAnchor.constraint(greaterThanOrEqualTo: itemContainerView.topAnchor).isActive = true
            item.leadingAnchor.constraint(greaterThanOrEqualTo: itemContainerView.leadingAnchor).isActive = true
            item.trailingAnchor.constraint(lessThanOrEqualTo: itemContainerView.trailingAnchor).isActive = true
            item.bottomAnchor.constraint(lessThanOrEqualTo: itemContainerView.bottomAnchor).isActive = true
        }

        configuration.itemLayout.layout(openItems, self)
    }

    func openItems(animated: Bool, group: DispatchGroup) {
        precondition(currentItemAnimationConfiguration != nil)
        let configuration = currentItemAnimationConfiguration!

        let numberOfItems = openItems.count
        var delay: TimeInterval = 0.0
        var index = 0
        for item in openItems {
            configuration.closedState.prepare(item, index, numberOfItems, self)
            let animation: () -> Void = {
                configuration.openState.prepare(item, index, numberOfItems, self)
            }
            UIView.animate(duration: configuration.opening.duration,
                           delay: delay,
                           usingSpringWithDamping: configuration.opening.dampingRatio,
                           initialSpringVelocity: configuration.opening.initialVelocity,
                           animations: animation,
                           group: group,
                           animated: animated)

            delay += configuration.opening.interItemDelay
            index += 1
        }
    }

    func closeItems(animated: Bool, group: DispatchGroup) {
        precondition(currentItemAnimationConfiguration != nil)
        let configuration = currentItemAnimationConfiguration!

        let numberOfItems = openItems.count
        var delay: TimeInterval = 0.0
        var index = numberOfItems - 1
        for item in openItems.reversed() {
            let animation: () -> Void = {
                configuration.closedState.prepare(item, index, numberOfItems, self)
            }
            UIView.animate(duration: configuration.closing.duration,
                           delay: delay,
                           usingSpringWithDamping: configuration.closing.dampingRatio,
                           initialSpringVelocity: configuration.closing.initialVelocity,
                           animations: animation,
                           group: group,
                           animated: animated)

            delay += configuration.closing.interItemDelay
            index -= 1
        }
    }
}
