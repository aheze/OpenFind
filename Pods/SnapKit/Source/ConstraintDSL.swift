//
//  SnapKit
//
//  Copyright (c) 2011-Present SnapKit Team - https://github.com/SnapKit
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

#if os(iOS) || os(tvOS)
import UIKit
#else
import AppKit
#endif

public protocol ConstraintDSL {
    var target: AnyObject? { get }
    
    func setLabel(_ value: String?)
    func label() -> String?
}

public extension ConstraintDSL {
    func setLabel(_ value: String?) {
        objc_setAssociatedObject(target as Any, &labelKey, value, .OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    func label() -> String? {
        return objc_getAssociatedObject(target as Any, &labelKey) as? String
    }
}

private var labelKey: UInt8 = 0

public protocol ConstraintBasicAttributesDSL: ConstraintDSL {}

public extension ConstraintBasicAttributesDSL {
    // MARK: Basics
    
    var left: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.left)
    }
    
    var top: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.top)
    }
    
    var right: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.right)
    }
    
    var bottom: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.bottom)
    }
    
    var leading: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.leading)
    }
    
    var trailing: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.trailing)
    }
    
    var width: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.width)
    }
    
    var height: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.height)
    }
    
    var centerX: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.centerX)
    }
    
    var centerY: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.centerY)
    }
    
    var edges: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.edges)
    }
    
    var directionalEdges: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.directionalEdges)
    }

    var size: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.size)
    }
    
    var center: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.center)
    }
}

public protocol ConstraintAttributesDSL: ConstraintBasicAttributesDSL {}

public extension ConstraintAttributesDSL {
    // MARK: Baselines
    
    @available(*, deprecated, message: "Use .lastBaseline instead")
    var baseline: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.lastBaseline)
    }
    
    @available(iOS 8.0, OSX 10.11, *)
    var lastBaseline: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.lastBaseline)
    }
    
    @available(iOS 8.0, OSX 10.11, *)
    var firstBaseline: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.firstBaseline)
    }
    
    // MARK: Margins
    
    @available(iOS 8.0, *)
    var leftMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.leftMargin)
    }
    
    @available(iOS 8.0, *)
    var topMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.topMargin)
    }
    
    @available(iOS 8.0, *)
    var rightMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.rightMargin)
    }
    
    @available(iOS 8.0, *)
    var bottomMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.bottomMargin)
    }
    
    @available(iOS 8.0, *)
    var leadingMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.leadingMargin)
    }
    
    @available(iOS 8.0, *)
    var trailingMargin: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.trailingMargin)
    }
    
    @available(iOS 8.0, *)
    var centerXWithinMargins: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.centerXWithinMargins)
    }
    
    @available(iOS 8.0, *)
    var centerYWithinMargins: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.centerYWithinMargins)
    }
    
    @available(iOS 8.0, *)
    var margins: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.margins)
    }
    
    @available(iOS 8.0, *)
    var directionalMargins: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.directionalMargins)
    }

    @available(iOS 8.0, *)
    var centerWithinMargins: ConstraintItem {
        return ConstraintItem(target: target, attributes: ConstraintAttributes.centerWithinMargins)
    }
}
