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

public extension ConstraintView {
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_left: ConstraintItem { return snp.left }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_top: ConstraintItem { return snp.top }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_right: ConstraintItem { return snp.right }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_bottom: ConstraintItem { return snp.bottom }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_leading: ConstraintItem { return snp.leading }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_trailing: ConstraintItem { return snp.trailing }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_width: ConstraintItem { return snp.width }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_height: ConstraintItem { return snp.height }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_centerX: ConstraintItem { return snp.centerX }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_centerY: ConstraintItem { return snp.centerY }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_baseline: ConstraintItem { return snp.baseline }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, OSX 10.11, *)
    var snp_lastBaseline: ConstraintItem { return snp.lastBaseline }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, OSX 10.11, *)
    var snp_firstBaseline: ConstraintItem { return snp.firstBaseline }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_leftMargin: ConstraintItem { return snp.leftMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_topMargin: ConstraintItem { return snp.topMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_rightMargin: ConstraintItem { return snp.rightMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_bottomMargin: ConstraintItem { return snp.bottomMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_leadingMargin: ConstraintItem { return snp.leadingMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_trailingMargin: ConstraintItem { return snp.trailingMargin }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerXWithinMargins: ConstraintItem { return snp.centerXWithinMargins }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerYWithinMargins: ConstraintItem { return snp.centerYWithinMargins }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_edges: ConstraintItem { return snp.edges }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_size: ConstraintItem { return snp.size }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    var snp_center: ConstraintItem { return snp.center }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_margins: ConstraintItem { return snp.margins }
    
    @available(iOS, deprecated, message: "Use newer snp.* syntax.")
    @available(iOS 8.0, *)
    var snp_centerWithinMargins: ConstraintItem { return snp.centerWithinMargins }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        return snp.prepareConstraints(closure)
    }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        snp.makeConstraints(closure)
    }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        snp.remakeConstraints(closure)
    }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        snp.updateConstraints(closure)
    }
    
    @available(*, deprecated, message: "Use newer snp.* syntax.")
    func snp_removeConstraints() {
        snp.removeConstraints()
    }
    
    var snp: ConstraintViewDSL {
        return ConstraintViewDSL(view: self)
    }
}
