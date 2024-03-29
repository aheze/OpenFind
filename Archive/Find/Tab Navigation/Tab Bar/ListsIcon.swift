//
//  ListsIcon.swift
//  FindTabBar
//
//  Created by Zheng on 12/18/20.
//

import UIKit

class ListsIcon: UIView {
    var pressed: (() -> Void)?
    
    let originalForegroundX = CGFloat(10)
    let originalForegroundY = CGFloat(3)
    let activeForegroundX = CGFloat(12)
    let activeForegroundY = CGFloat(3)
    
    let originalBackgroundX = CGFloat(6)
    let originalBackgroundY = CGFloat(6)
    let activeBackgroundX = CGFloat(4)
    let activeBackgroundY = CGFloat(6)
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var foregroundView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var detailsView: UIView!
    
    @IBOutlet var touchButton: UIButton!
    
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
        Bundle.main.loadNibNamed("ListsIcon", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let listsIconBezier = makeListsIconBezier()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = listsIconBezier
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
            self.backgroundView.transform = CGAffineTransform.identity
            self.foregroundView.frame = CGRect(x: 10, y: 3, width: 24, height: 30)
            self.backgroundView.frame = CGRect(x: 6, y: 6, width: 24, height: 30)
            
            self.detailsView.backgroundColor = details
            self.foregroundView.backgroundColor = foreground
            self.backgroundView.backgroundColor = background
        }
        return block
    }
    
    func makeActiveState() -> (() -> Void) {
        let block = { [weak self] in
            guard let self = self else { return }
            
            self.foregroundView.transform = CGAffineTransform.identity
            self.backgroundView.transform = CGAffineTransform.identity
            self.foregroundView.frame = CGRect(x: 12, y: 3, width: 24, height: 30)
            self.backgroundView.frame = CGRect(x: 4, y: 6, width: 24, height: 30)
            self.foregroundView.transform = CGAffineTransform(rotationAngle: 15.degreesToRadians)
            self.backgroundView.transform = CGAffineTransform(rotationAngle: -15.degreesToRadians)
            
            self.foregroundView.backgroundColor = UIColor(named: "TabIconListsMain")
            self.backgroundView.backgroundColor = UIColor(named: "TabIconListsSecondary")
            self.detailsView.backgroundColor = UIColor.white
        }
        return block
    }
    
    func makePercentageOfActive(percentage: CGFloat, originalDetails: UIColor, originalForeground: UIColor, originalBackground: UIColor) {
        let foregroundX = originalForegroundX + ((activeForegroundX - originalForegroundX) * percentage)
        let foregroundY = originalForegroundY + ((activeForegroundY - originalForegroundY) * percentage)
        let backgroundX = originalBackgroundX + ((activeBackgroundX - originalBackgroundX) * percentage)
        let backgroundY = originalBackgroundY + ((activeBackgroundY - originalBackgroundY) * percentage)
        
        foregroundView.transform = CGAffineTransform.identity
        backgroundView.transform = CGAffineTransform.identity
        foregroundView.frame = CGRect(x: foregroundX, y: foregroundY, width: 24, height: 30)
        backgroundView.frame = CGRect(x: backgroundX, y: backgroundY, width: 24, height: 30)
        foregroundView.transform = CGAffineTransform(rotationAngle: (15.degreesToRadians) * percentage)
        backgroundView.transform = CGAffineTransform(rotationAngle: (-15.degreesToRadians) * percentage)
        
        detailsView.backgroundColor = [originalDetails, UIColor.white].intermediate(percentage: percentage)
        foregroundView.backgroundColor = [originalForeground, UIColor(named: "TabIconListsMain")!].intermediate(percentage: percentage)
        backgroundView.backgroundColor = [originalBackground, UIColor(named: "TabIconListsSecondary")!].intermediate(percentage: percentage)
    }
    
    func makePercentageOfDark(percentage: CGFloat) {
        detailsView.backgroundColor = [FindConstants.detailIconColorLight, FindConstants.detailIconColorDark].intermediate(percentage: percentage)
        foregroundView.backgroundColor = [FindConstants.foregroundIconColorLight, FindConstants.foregroundIconColorDark].intermediate(percentage: percentage)
        backgroundView.backgroundColor = [FindConstants.backgroundIconColorLight, FindConstants.backgroundIconColorDark].intermediate(percentage: percentage)
    }
    
    func makeListsIconBezier() -> CGPath {
        //// Rectangle 2 Drawing
        let bezierPath = UIBezierPath(roundedRect: CGRect(x: 6, y: 5.8, width: 12.8, height: 1.6), cornerRadius: 0.8)
        
        //// Rectangle 3 Drawing
        bezierPath.append(UIBezierPath(roundedRect: CGRect(x: 6, y: 10.6, width: 12.8, height: 1.6), cornerRadius: 0.8))

        //// Rectangle 4 Drawing
        bezierPath.append(UIBezierPath(roundedRect: CGRect(x: 6, y: 16.2, width: 7.2, height: 1.6), cornerRadius: 0.8))
        
        return bezierPath.cgPath
    }
}
