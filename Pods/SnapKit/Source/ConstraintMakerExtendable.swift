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

public class ConstraintMakerExtendable: ConstraintMakerRelatable {
    public var left: ConstraintMakerExtendable {
        description.attributes += .left
        return self
    }
    
    public var top: ConstraintMakerExtendable {
        description.attributes += .top
        return self
    }
    
    public var bottom: ConstraintMakerExtendable {
        description.attributes += .bottom
        return self
    }
    
    public var right: ConstraintMakerExtendable {
        description.attributes += .right
        return self
    }
    
    public var leading: ConstraintMakerExtendable {
        description.attributes += .leading
        return self
    }
    
    public var trailing: ConstraintMakerExtendable {
        description.attributes += .trailing
        return self
    }
    
    public var width: ConstraintMakerExtendable {
        description.attributes += .width
        return self
    }
    
    public var height: ConstraintMakerExtendable {
        description.attributes += .height
        return self
    }
    
    public var centerX: ConstraintMakerExtendable {
        description.attributes += .centerX
        return self
    }
    
    public var centerY: ConstraintMakerExtendable {
        description.attributes += .centerY
        return self
    }
    
    @available(*, deprecated, message: "Use lastBaseline instead")
    public var baseline: ConstraintMakerExtendable {
        description.attributes += .lastBaseline
        return self
    }
    
    public var lastBaseline: ConstraintMakerExtendable {
        description.attributes += .lastBaseline
        return self
    }
    
    @available(iOS 8.0, OSX 10.11, *)
    public var firstBaseline: ConstraintMakerExtendable {
        description.attributes += .firstBaseline
        return self
    }
    
    @available(iOS 8.0, *)
    public var leftMargin: ConstraintMakerExtendable {
        description.attributes += .leftMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var rightMargin: ConstraintMakerExtendable {
        description.attributes += .rightMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var topMargin: ConstraintMakerExtendable {
        description.attributes += .topMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var bottomMargin: ConstraintMakerExtendable {
        description.attributes += .bottomMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var leadingMargin: ConstraintMakerExtendable {
        description.attributes += .leadingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var trailingMargin: ConstraintMakerExtendable {
        description.attributes += .trailingMargin
        return self
    }
    
    @available(iOS 8.0, *)
    public var centerXWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerXWithinMargins
        return self
    }
    
    @available(iOS 8.0, *)
    public var centerYWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerYWithinMargins
        return self
    }
    
    public var edges: ConstraintMakerExtendable {
        description.attributes += .edges
        return self
    }

    public var directionalEdges: ConstraintMakerExtendable {
        description.attributes += .directionalEdges
        return self
    }

    public var size: ConstraintMakerExtendable {
        description.attributes += .size
        return self
    }
    
    @available(iOS 8.0, *)
    public var margins: ConstraintMakerExtendable {
        description.attributes += .margins
        return self
    }
    
    @available(iOS 8.0, *)
    public var directionalMargins: ConstraintMakerExtendable {
        description.attributes += .directionalMargins
        return self
    }

    @available(iOS 8.0, *)
    public var centerWithinMargins: ConstraintMakerExtendable {
        description.attributes += .centerWithinMargins
        return self
    }
}
