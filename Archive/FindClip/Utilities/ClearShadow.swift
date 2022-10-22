//
//  ClearShadow.swift
//  FindAppClip1
//
//  Created by Zheng on 3/14/21.
//

import UIKit

/// from https://stackoverflow.com/a/54883530/14351818

@IBDesignable
class ClearShadow: UIView {
    let bottomOverflow: CGFloat = 400
    let cornerRadius: CGFloat = 16
    var maskingLayer: CAShapeLayer?
    
    @IBInspectable var opacity: Double = 0.3 {
        didSet {
            layer.shadowOpacity = Float(opacity)
        }
    }
    
    @IBInspectable var radius: Double = 20 {
        didSet {
            layer.shadowRadius = CGFloat(radius)
        }
    }
    
    @IBInspectable var offset: Double = 0 {
        didSet {
            layer.shadowOffset = CGSize(width: 0, height: offset)
        }
    }
    
    @IBInspectable var horizontalInset: Double = 0 {
        didSet {
            let path = CGMutablePath()
            var fullBounds = bounds
            fullBounds.size.height += bottomOverflow
            path.addRect(fullBounds)
            
            let innerBounds = bounds.inset(by: UIEdgeInsets(top: 0, left: CGFloat(horizontalInset), bottom: 0, right: CGFloat(horizontalInset)))
            path.addRoundedRect(in: innerBounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            maskingLayer?.path = path
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        common()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        common()
    }

    private func common() {
        backgroundColor = .clear
        clipsToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: offset)
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = CGFloat(radius)

        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.blue.cgColor
        
        let path = CGMutablePath()
        var fullBounds = bounds
        fullBounds.size.height += bottomOverflow
        path.addRect(fullBounds)
        
        let innerBounds = bounds.inset(by: UIEdgeInsets(top: 0, left: CGFloat(horizontalInset), bottom: 0, right: CGFloat(horizontalInset)))
        path.addRoundedRect(in: innerBounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        maskLayer.path = path
        
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.mask = maskLayer
        maskingLayer = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        
        let path = CGMutablePath()
        var fullBounds = bounds
        fullBounds.size.height += bottomOverflow
        path.addRect(fullBounds)
        
        let innerBounds = bounds.inset(by: UIEdgeInsets(top: 0, left: CGFloat(horizontalInset), bottom: 0, right: CGFloat(horizontalInset)))
        path.addRoundedRect(in: innerBounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        maskingLayer?.path = path
    }
}
