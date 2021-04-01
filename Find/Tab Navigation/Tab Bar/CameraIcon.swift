//
//  CameraIcon.swift
//  FindTabBar
//
//  Created by Zheng on 12/17/20.
//

import UIKit

class CameraIcon: UIView {
    
    var isActiveCameraIcon = false /// is popped out
    
    let inactiveFillColor = Constants.backgroundIconColorLight
    
    /// configurable
    var inactiveRimColor = Constants.detailIconColorLight
    var activeRimColor = UIColor.white
    
    var isActualButton = false /// if it is actual icon in Camera VC
    var pressed: (() -> Void)?
    
    var offsetNeeded = CGFloat(0) /// offset needed to push shutter up
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var containerView: UIView! /// contains rim and fill
    @IBOutlet weak var rimView: UIView!
    @IBOutlet weak var fillView: UIView!
    var shapeFillLayer: CAShapeLayer?
    
    @IBOutlet weak var touchButton: UIButton!
    
    @IBAction func touchDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.contentView.alpha = 0.5
            if self.isActualButton {
                self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            }
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
            if self.isActualButton {
                self.transform = CGAffineTransform.identity
            }
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
        Bundle.main.loadNibNamed("CameraIcon", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let fillLayer = CAShapeLayer()
        fillLayer.position = CGPoint(x: fillView.bounds.width / 2, y: fillView.bounds.width / 2)
        shapeFillLayer = fillLayer
        fillView.layer.mask = fillLayer
        
        let circlePath = createRoundedCircle(circumference: fillView.bounds.width, cornerRadius: fillView.bounds.width / 2)
        fillLayer.path = circlePath
        
        rimView.layer.borderWidth = 2
        rimView.layer.borderColor = Constants.detailIconColorLight.cgColor
        
        updateStyle()
    }
    
    func updateStyle() {
        print("Updaing. \(UserDefaults.standard.integer(forKey: "shutterStyle"))")
        switch UserDefaults.standard.integer(forKey: "shutterStyle") {
        case 2:
            print("DAK STYLE")
            inactiveRimColor = Constants.detailIconColorLight
            activeRimColor = UIColor(named: "50Black")!
            
            fillView.transform = CGAffineTransform.identity
            rimView.layer.borderColor = (isActiveCameraIcon || isActualButton) ? activeRimColor.cgColor : inactiveRimColor.cgColor
        case 3:
            print("SOLID  STYLE")
            inactiveRimColor = UIColor.clear
            activeRimColor = UIColor.clear
            
            fillView.transform = CGAffineTransform(scaleX: 1.36, y: 1.36)
            rimView.layer.borderColor = (isActiveCameraIcon || isActualButton) ? activeRimColor.cgColor : inactiveRimColor.cgColor
        default:
            print("Class  STYLE")
            inactiveRimColor = Constants.detailIconColorLight
            activeRimColor = UIColor.white
            
            fillView.transform = CGAffineTransform.identity
            rimView.layer.borderColor = (isActiveCameraIcon || isActualButton) ? activeRimColor.cgColor : inactiveRimColor.cgColor
        }
        
        print("Active rim color is \(activeRimColor)")
    }
    
    /// For dark mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        print("Did change...")
        rimView.layer.borderColor = isActiveCameraIcon ? activeRimColor.cgColor : inactiveRimColor.cgColor
        
//        if ViewControllerState.currentVC is CameraViewController {
//            rimView.layer.borderColor = Constants.detailIconColorDark.cgColor
//        } else {
//            if traitCollection.userInterfaceStyle == .dark {
//                rimView.layer.borderColor = Constants.detailIconColorLight.cgColor
//            } else {
//                rimView.layer.borderColor = Constants.detailIconColorLight.cgColor
//            }
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rimView.layer.cornerRadius = rimView.frame.width / 2
        updateStyle()
    }
    
    func makeNormalState() -> (() -> Void) {
        let block = { [weak self] in
            guard let self = self else { return }
            
            self.contentView.transform = CGAffineTransform.identity
            self.contentView.center.y = self.contentView.bounds.height / 2 /// default
            self.fillView.backgroundColor = self.inactiveFillColor
        }
        return block
    }
    
    func makeActiveState() -> (() -> Void) {
        let block = { [weak self] in
            guard let self = self else { return }
            self.contentView.center.y = self.contentView.bounds.height / 2 - self.offsetNeeded

            let scale = Constants.shutterBoundsLength / self.contentView.bounds.width
            self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.fillView.backgroundColor = UIColor(named: "50Blue")
        }
        return block
    }
    func makeLayerInactiveState(duration: CGFloat) {
        isActiveCameraIcon = false
        if let currentValue = rimView.layer.presentation()?.value(forKeyPath: #keyPath(CALayer.borderColor)) {
            let currentColor = currentValue as! CGColor
            rimView.layer.borderColor = currentColor
            rimView.layer.removeAllAnimations()
        }
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = rimView.layer.borderColor
        animation.toValue = inactiveRimColor.cgColor
        animation.duration = Double(duration)
        rimView.layer.borderColor = inactiveRimColor.cgColor
        rimView.layer.add(animation, forKey: "borderColor")
        
    }
    func makeLayerActiveState(duration: CGFloat) {
        isActiveCameraIcon = true
        if let currentValue = rimView.layer.presentation()?.value(forKeyPath: #keyPath(CALayer.borderColor)) {
            let currentColor = currentValue as! CGColor
            rimView.layer.borderColor = currentColor
            rimView.layer.removeAllAnimations()
        }
        let animation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fromValue = rimView.layer.borderColor
        animation.toValue = activeRimColor.cgColor
        animation.duration = Double(duration)
        rimView.layer.borderColor = activeRimColor.cgColor
        rimView.layer.add(animation, forKey: "borderColor")
    }
    func makePercentageOfActive(percentage: CGFloat) {
        contentView.center.y = (self.contentView.bounds.height / 2) - (self.offsetNeeded * percentage)
        let scale = 1 + ((Constants.shutterBoundsLength / self.contentView.bounds.width - 1) * percentage)
        contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        self.fillView.backgroundColor = [inactiveFillColor, UIColor(named: "50Blue")!].intermediate(percentage: percentage)
        self.rimView.layer.borderColor = [inactiveRimColor, activeRimColor].intermediate(percentage: percentage).cgColor
    }
    func toggle(on: Bool) {
        if on {
            let trianglePath = createRoundedTriangle(circumference: fillView.bounds.width)
            
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeFillLayer?.path
            pathAnimation.toValue = trianglePath
            
            shapeFillLayer?.path = trianglePath
            pathAnimation.duration = 0.2
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            
            shapeFillLayer?.add(pathAnimation, forKey: "pathAnimation")
        } else {
            let circlePath = createRoundedCircle(circumference: fillView.bounds.width, cornerRadius: fillView.bounds.width / 2)
            
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = shapeFillLayer?.path
            pathAnimation.toValue = circlePath
            
            shapeFillLayer?.path = circlePath
            pathAnimation.duration = 0.2
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            
            shapeFillLayer?.add(pathAnimation, forKey: "pathAnimation")
        }
    }
    
    func createRoundedTriangle(circumference: CGFloat) -> CGPath {
        let cornerRadius = circumference / 10
        
        let width = circumference / 2
        let xLeft = width / 30
        let yOffset = sqrt(3) * (width / 2)
        
        let point1 = CGPoint(x: (-width / 2) - xLeft, y: -yOffset)
        let point2 = CGPoint(x: width - xLeft, y: 0)
        let point3 = CGPoint(x: (-width / 2) - xLeft, y: yOffset)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: (-width / 2) - xLeft, y: 0))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
    
    func createRoundedCircle(circumference: CGFloat, cornerRadius: CGFloat) -> CGPath {
        let yOffset = sqrt(3) * (circumference / 2)
        
        let point1 = CGPoint(x: -circumference / 2, y: -yOffset)
        let point2 = CGPoint(x: circumference, y: 0)
        let point3 = CGPoint(x: -circumference / 2, y: yOffset)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -circumference / 2, y: 0))
        
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
}
