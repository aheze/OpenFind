//
//  JJActionItemTitlePosition.swift
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

/// Action item title position.
///
@objc public enum JJActionItemTitlePosition: Int {
    /// Place the title at the leading edge of the circle view.
    ///
    case leading

    /// Place the title at the trailing edge of the circle view.
    ///
    case trailing

    /// Place the title at the left edge of the circle view.
    ///
    case left

    /// Place the title at the right edge of the circle view.
    ///
    case right

    /// Place the title at the top edge of the circle view.
    ///
    case top

    /// Place the title at the bottom edge of the circle view.
    ///
    case bottom

    /// Hide the title all together.
    ///
    case hidden
}
