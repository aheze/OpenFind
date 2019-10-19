//
//  JJFloatingActionButtonDelegate.swift
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

/// Floating action button delegate protocol
///
@objc public protocol JJFloatingActionButtonDelegate {
    /// Is called before opening animation. Button state is .opening.
    ///
    @objc optional func floatingActionButtonWillOpen(_ button: JJFloatingActionButton)

    /// Is called after opening animation. Button state is .opened.
    ///
    @objc optional func floatingActionButtonDidOpen(_ button: JJFloatingActionButton)

    /// Is called before closing animation. Button state is .closing.
    ///
    @objc optional func floatingActionButtonWillClose(_ button: JJFloatingActionButton)

    /// Is called after closing animation. Button state is .closed.
    ///
    @objc optional func floatingActionButtonDidClose(_ button: JJFloatingActionButton)
}
