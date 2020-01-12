//
//  JJCircleView.swift
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

/// A colored circle with an highlighted state
///
@objc @IBDesignable public class JJCircleView: UIView {
    /// The color of the circle.
    ///
    @objc @IBInspectable public dynamic var color: UIColor = Styles.defaultButtonColor {
        didSet {
            updateHighlightedColorFallback()
            setNeedsDisplay()
        }
    }

    /// The color of the circle when highlighted. Default is `nil`.
    ///
    @objc @IBInspectable public dynamic var highlightedColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }

    /// A Boolean value indicating whether the circle view draws a highlight.
    /// Default is `false`.
    ///
    @objc public var isHighlighted = false {
        didSet {
            setNeedsDisplay()
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

    /// Draws the receiver’s image within the passed-in rectangle
    /// Overrides `draw(rect: CGRect)` from `UIView`.
    ///
    public override func draw(_: CGRect) {
        drawCircle(inRect: bounds)
    }

    fileprivate var highlightedColorFallback = Styles.defaultHighlightedButtonColor
}

// MARK: - Private Methods

fileprivate extension JJCircleView {
    func setup() {
        backgroundColor = .clear
    }

    func drawCircle(inRect rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        let diameter = min(rect.width, rect.height)
        var circleRect = CGRect()
        circleRect.size.width = diameter
        circleRect.size.height = diameter
        circleRect.origin.x = (rect.width - diameter) / 2
        circleRect.origin.y = (rect.height - diameter) / 2

        let circlePath = UIBezierPath(ovalIn: circleRect)
        currentColor.setFill()
        circlePath.fill()

        context.restoreGState()
    }

    var currentColor: UIColor {
        if !isHighlighted {
            return color
        }

        if let highlightedColor = highlightedColor {
            return highlightedColor
        }

        return highlightedColorFallback
    }

    func updateHighlightedColorFallback() {
        highlightedColorFallback = color.highlighted
    }
}
