//
//  PhotosIcon.swift
//  FindTabBar
//
//  Created by Zheng on 12/18/20.
//

import UIKit

class PhotosIcon: UIView {
    
    var pressed: (() -> Void)?
    
    var newDetailsColor = FindConstants.detailIconColorDark
    var newBackgroundColor = FindConstants.backgroundIconColorDark
    
    let originalForegroundX = CGFloat(5)
    let originalForegroundY = CGFloat(10)
    let activeForegroundX = CGFloat(3)
    let activeForegroundY = CGFloat(6)
    
    let originalBackgroundX = CGFloat(8)
    let originalBackgroundY = CGFloat(6)
    let originalBackgroundWidth = CGFloat(24)
    let originalBackgroundHeight = CGFloat(17)
    let activeBackgroundX = CGFloat(11)
    let activeBackgroundY = CGFloat(13)
    let activeBackgroundWidth = CGFloat(27)
    let activeBackgroundHeight = CGFloat(22)
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var foregroundView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var detailsView: UIView!
    
    @IBOutlet weak var touchButton: UIButton!
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0.5
        })
    }
    @IBAction func touchUpInside(_ sender: Any) {
        pressed?()
        resetAlpha()
    }
    @IBAction func touchUpCancel(_ sender: Any) {
        resetAlpha()
    }
    
    func resetAlpha() {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 1
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PhotosIcon", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let photoIconBezier = makePhotosIconBezier()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = photoIconBezier
        detailsView.layer.mask = shapeLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        foregroundView.layer.cornerRadius = 5
        backgroundView.layer.cornerRadius = 4.8
    }
    
    func makeNormalState(details: UIColor, foreground: UIColor, background: UIColor) -> (() -> Void) {
        let block = { [weak self] in
            guard let self = self else { return }
            self.foregroundView.transform = CGAffineTransform.identity
            self.foregroundView.frame = CGRect(x: self.originalForegroundX, y: self.originalForegroundY, width: 30, height: 24)
            self.backgroundView.frame = CGRect(x: self.originalBackgroundX, y: self.originalBackgroundY, width: self.originalBackgroundWidth, height: self.originalBackgroundHeight)
            
            self.detailsView.backgroundColor = details
            self.foregroundView.backgroundColor = foreground
            self.backgroundView.backgroundColor = background
        }
        return block
    }
    
    /// offset if is icon in camera vc
    func makeActiveState(offset: Bool = false) -> (() -> Void) {
        let block = { [weak self] in
            guard let self = self else { return }
            
            var extraOffset = CGFloat(0)
            if offset {
                extraOffset = -1
            }
            
            self.foregroundView.transform = CGAffineTransform.identity
            self.foregroundView.frame = CGRect(x: 3 + extraOffset, y: 6, width: 30, height: 24)
            self.backgroundView.frame = CGRect(x: 11 + extraOffset, y: 13, width: 27, height: 22)
            self.foregroundView.transform = CGAffineTransform(rotationAngle: -15.degreesToRadians)
            
            self.foregroundView.backgroundColor = UIColor(named: "TabIconPhotosMain")
            self.backgroundView.backgroundColor = UIColor(named: "TabIconPhotosSecondary")
            self.detailsView.backgroundColor = UIColor.white
        }
        return block
    }
    func makePercentageOfActive(percentage: CGFloat, originalDetails: UIColor, originalForeground: UIColor, originalBackground: UIColor) {
        
        let foregroundX = self.originalForegroundX + ((self.activeForegroundX - self.originalForegroundX) * percentage)
        let foregroundY = self.originalForegroundY + ((self.activeForegroundY - self.originalForegroundY) * percentage)
        let backgroundX = self.originalBackgroundX + ((self.activeBackgroundX - self.originalBackgroundX) * percentage)
        let backgroundY = self.originalBackgroundY + ((self.activeBackgroundY - self.originalBackgroundY) * percentage)
        let backgroundWidth = self.originalBackgroundWidth + ((self.activeBackgroundWidth - self.originalBackgroundWidth) * percentage)
        let backgroundHeight = self.originalBackgroundHeight + ((self.activeBackgroundHeight - self.originalBackgroundHeight) * percentage)
        
        self.foregroundView.transform = CGAffineTransform.identity
        
        self.foregroundView.frame = CGRect(x: foregroundX, y: foregroundY, width: 30, height: 24)
        self.backgroundView.frame = CGRect(x: backgroundX, y: backgroundY, width: backgroundWidth, height: backgroundHeight)
        self.foregroundView.transform = CGAffineTransform(rotationAngle: (-15.degreesToRadians) * percentage)
        
        self.detailsView.backgroundColor = [originalDetails, UIColor.white].intermediate(percentage: percentage)
        self.foregroundView.backgroundColor = [originalForeground, UIColor(named: "TabIconPhotosMain")!].intermediate(percentage: percentage)
        self.backgroundView.backgroundColor = [originalBackground, UIColor(named: "TabIconPhotosSecondary")!].intermediate(percentage: percentage)
    }
    
    func makePercentageOfDark(percentage: CGFloat) {
        self.detailsView.backgroundColor = [FindConstants.detailIconColorLight, FindConstants.detailIconColorDark].intermediate(percentage: percentage)
        self.foregroundView.backgroundColor = [FindConstants.foregroundIconColorLight, FindConstants.foregroundIconColorDark].intermediate(percentage: percentage)
        self.backgroundView.backgroundColor = [FindConstants.backgroundIconColorLight, FindConstants.backgroundIconColorDark].intermediate(percentage: percentage)
    }
    
    func makePhotosIconBezier() -> CGPath {

        //// Oval Drawing
        let bezierPath = UIBezierPath(ovalIn: CGRect(x: 8.6, y: 7.6, width: 4.8, height: 4.8))

        //// Bezier 2 Drawing
        bezierPath.move(to: CGPoint(x: 23.87, y: 20.4))
        bezierPath.addLine(to: CGPoint(x: 6.14, y: 20.4))
        bezierPath.addCurve(to: CGPoint(x: 4.6, y: 18.9), controlPoint1: CGPoint(x: 5.18, y: 20.4), controlPoint2: CGPoint(x: 4.6, y: 19.84))
        bezierPath.addLine(to: CGPoint(x: 4.6, y: 18.08))
        bezierPath.addLine(to: CGPoint(x: 7.58, y: 15.57))
        bezierPath.addCurve(to: CGPoint(x: 9, y: 14.98), controlPoint1: CGPoint(x: 8.04, y: 15.18), controlPoint2: CGPoint(x: 8.5, y: 14.98))
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: 15.58), controlPoint1: CGPoint(x: 9.51, y: 14.98), controlPoint2: CGPoint(x: 10.03, y: 15.19))
        bezierPath.addLine(to: CGPoint(x: 12.49, y: 17.33))
        bezierPath.addLine(to: CGPoint(x: 17.49, y: 13.04))
        bezierPath.addCurve(to: CGPoint(x: 19.15, y: 12.4), controlPoint1: CGPoint(x: 17.99, y: 12.6), controlPoint2: CGPoint(x: 18.56, y: 12.4))
        bezierPath.addCurve(to: CGPoint(x: 20.81, y: 13.06), controlPoint1: CGPoint(x: 19.72, y: 12.4), controlPoint2: CGPoint(x: 20.32, y: 12.61))
        bezierPath.addLine(to: CGPoint(x: 25.4, y: 17.17))
        bezierPath.addLine(to: CGPoint(x: 25.4, y: 18.91))
        bezierPath.addCurve(to: CGPoint(x: 23.87, y: 20.4), controlPoint1: CGPoint(x: 25.4, y: 19.84), controlPoint2: CGPoint(x: 24.8, y: 20.4))
        bezierPath.close()
        
        return bezierPath.cgPath

    }
}

