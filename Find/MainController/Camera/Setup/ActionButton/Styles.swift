//
//  Styles.swift
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

internal struct Styles {}

// MARK: - Colors

internal extension Styles {
    static var defaultButtonColor: UIColor {
        return UIColor(hue: 0.31, saturation: 0.37, brightness: 0.76, alpha: 1.00)
    }

    static var defaultHighlightedButtonColor: UIColor {
        return UIColor(hue: 0.31, saturation: 0.37, brightness: 0.66, alpha: 1.00)
    }

    static var defaultButtonImageColor: UIColor {
        return .white
    }

    static var defaultShadowColor: UIColor {
        return .black
    }

    static var defaultOverlayColor: UIColor {
        return UIColor(white: 0, alpha: 0.5)
    }
}

// MARK: - Images

internal extension Styles {
    static var plusImage: UIImage? {
        return drawImage(name: "plus", size: CGSize(width: 24, height: 24)) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: 22.5, y: 11))
            bezierPath.addLine(to: CGPoint(x: 13, y: 11))
            bezierPath.addLine(to: CGPoint(x: 13, y: 1.5))
            bezierPath.addCurve(to: CGPoint(x: 12.5, y: 1),
                                controlPoint1: CGPoint(x: 13, y: 1.22),
                                controlPoint2: CGPoint(x: 12.78, y: 1))
            bezierPath.addLine(to: CGPoint(x: 11.5, y: 1))
            bezierPath.addCurve(to: CGPoint(x: 11, y: 1.5),
                                controlPoint1: CGPoint(x: 11.22, y: 1),
                                controlPoint2: CGPoint(x: 11, y: 1.22))
            bezierPath.addLine(to: CGPoint(x: 11, y: 11))
            bezierPath.addLine(to: CGPoint(x: 1.5, y: 11))
            bezierPath.addCurve(to: CGPoint(x: 1, y: 11.5),
                                controlPoint1: CGPoint(x: 1.22, y: 11),
                                controlPoint2: CGPoint(x: 1, y: 11.22))
            bezierPath.addLine(to: CGPoint(x: 1, y: 12.5))
            bezierPath.addCurve(to: CGPoint(x: 1.5, y: 13),
                                controlPoint1: CGPoint(x: 1, y: 12.78),
                                controlPoint2: CGPoint(x: 1.22, y: 13))
            bezierPath.addLine(to: CGPoint(x: 11, y: 13))
            bezierPath.addLine(to: CGPoint(x: 11, y: 22.5))
            bezierPath.addCurve(to: CGPoint(x: 11.5, y: 23),
                                controlPoint1: CGPoint(x: 11, y: 22.78),
                                controlPoint2: CGPoint(x: 11.22, y: 23))
            bezierPath.addLine(to: CGPoint(x: 12.5, y: 23))
            bezierPath.addCurve(to: CGPoint(x: 13, y: 22.5),
                                controlPoint1: CGPoint(x: 12.78, y: 23),
                                controlPoint2: CGPoint(x: 13, y: 22.78))
            bezierPath.addLine(to: CGPoint(x: 13, y: 13))
            bezierPath.addLine(to: CGPoint(x: 22.5, y: 13))
            bezierPath.addCurve(to: CGPoint(x: 23, y: 12.5),
                                controlPoint1: CGPoint(x: 22.78, y: 13),
                                controlPoint2: CGPoint(x: 23, y: 12.78))
            bezierPath.addLine(to: CGPoint(x: 23, y: 11.5))
            bezierPath.addCurve(to: CGPoint(x: 22.5, y: 11),
                                controlPoint1: CGPoint(x: 23, y: 11.22),
                                controlPoint2: CGPoint(x: 22.78, y: 11))
            bezierPath.close()
            return bezierPath
        }
    }
}

// MARK: - Helper

fileprivate extension Styles {
    static var cache = NSCache<NSString, UIImage>()

    static func drawImage(name: NSString,
                          size: CGSize,
                          fillColor: UIColor = UIColor(red: 0.267, green: 0.267, blue: 0.267, alpha: 1.000),
                          path: (() -> UIBezierPath)) -> UIImage? {
        var image = cache.object(forKey: name)
        if image == nil {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            draw(path(), fillColor: fillColor)
            image = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysTemplate)
            UIGraphicsEndImageContext()
            if let image = image {
                cache.setObject(image, forKey: name)
            }
        }
        return image
    }

    static func draw(_ path: UIBezierPath, fillColor: UIColor) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        fillColor.setFill()
        path.fill()
        context?.restoreGState()
    }
}
