//
//    LDGradientView.swift
//    LDGradientView
//
//    MIT License
//
//    Copyright (c) 2017 Lee Dowthwaite.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
import UIKit

@IBDesignable
class LDGradientView: UIView {

    @IBInspectable var topColor: UIColor = UIColor.red {
        didSet {
            setGradient()
        }
    }
    @IBInspectable var bottomColor: UIColor = UIColor.blue {
        didSet {
            setGradient()
        }
    }

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setGradient()
    }

    private func setGradient() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 0.5, y: 0)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 0.5, y: 1)
    }
    
    // ensure the gradient gets initialized when the view is created in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setGradient()
    }
}
