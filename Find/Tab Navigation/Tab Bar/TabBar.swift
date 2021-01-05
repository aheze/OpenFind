//
//  TabBar.swift
//  FindTabBar
//
//  Created by Zheng on 12/17/20.
//

import UIKit
import SnapKit

enum TabBarMode {
    case navigationControls /// navigate between view controllers
    case photosControls /// selection controls for Photos
    case listsControls /// selection controls for Lists
}
class TabBarView: PassthroughView {
    
    var animatingObjects = 0
    var gestureInterruptedButton = false /// when button animating, then swipe away
    
    var tabAnimator: UIViewPropertyAnimator?
    
    var hideRealShutter: ((Bool) -> Void)?
    var changedViewController: ((ViewControllerType) -> Void)?
    var checkIfAnimating: (() -> (Bool))?
    
    @IBOutlet var contentView: PassthroughView!
    @IBOutlet weak var containerView: PassthroughView!
    @IBOutlet weak var containerHeightC: NSLayoutConstraint!
    @IBOutlet weak var stackView: PassthroughStackView!
    
    /// reference view to add selecting buttons
    @IBOutlet weak var controlsReferenceView: ReceiveTouchView!
    
    @IBOutlet var photosControls: ReceiveTouchView!
    @IBOutlet weak var starButton: UIButton!
    @IBAction func starButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var cacheButton: UIButton!
    @IBAction func cacheButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var photosDeleteButton: UIButton!
    @IBAction func photosDeleteButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet var listsControls: ReceiveTouchView!
    @IBOutlet weak var listsSelectionLabel: UILabel!
    @IBOutlet weak var listsDeleteButton: UIButton!
    
    var listsDeletePressed: (() -> Void)?
    @IBAction func listsDeleteButtonPressed(_ sender: Any) {
        listsDeletePressed?()
    }
    
    
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var shadeView: UIView!
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurBackgroundView: UIView! /// extra color for more opaque look
    
    
    @IBOutlet weak var photosIcon: PhotosIcon!
    @IBOutlet weak var cameraIcon: CameraIcon!
    @IBOutlet weak var listsIcon: ListsIcon!
    
    var layouted = false
    var fillLayer: CAShapeLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TabBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let fillLayer = CAShapeLayer()
        self.fillLayer = fillLayer
        backgroundView.layer.mask = fillLayer
        if deviceHasNotch {
            containerHeightC.constant = 68
        } else {
            containerHeightC.constant = 50
        }
        
        topLineView.alpha = 0
        cameraIcon.alpha = 0
        shadeView.alpha = 1
        blurView.effect = nil
        blurBackgroundView.alpha = 0
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.transitionDuration)
        tabAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        
        photosIcon.pressed = { [weak self] in
            guard let self = self else { return }
            if let currentVC = ViewControllerState.currentVC {
                let (prep, block, completion) = self.getBlocks(from: currentVC, to: .photos)
                if let block = block {
                    if (self.checkIfAnimating ?? { false })() == false {
                        prep()
                        self.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                        self.makeLayerInactiveState(duration: Constants.transitionDuration)
                        self.animate(block: block, completion: completion)
                    }
                    self.changedViewController?(.photos)
                }
            }
        }
        cameraIcon.pressed = { [weak self] in
            guard let self = self else { return }
            if let currentVC = ViewControllerState.currentVC {
                let (prep, block, completion) = self.getBlocks(from: currentVC, to: .camera)
                if let block = block {
                    if (self.checkIfAnimating ?? { false })() == false {
                        prep()
                        self.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
                        self.makeLayerActiveState(duration: Constants.transitionDuration)
                        self.animate(block: block, completion: completion)
                    }
                    self.changedViewController?(.camera)
                }
            }
        }
        listsIcon.pressed = { [weak self] in
            guard let self = self else { return }
            if let currentVC = ViewControllerState.currentVC {
                let (prep, block, completion) = self.getBlocks(from: currentVC, to: .lists)
                if let block = block {
                    if (self.checkIfAnimating ?? { false })() == false {
                        prep()
                        self.cameraIcon.makeLayerInactiveState(duration: Constants.transitionDuration)
                        self.makeLayerInactiveState(duration: Constants.transitionDuration)
                        self.animate(block: block, completion: completion)
                    }
                    self.changedViewController?(.lists)
                }
            }
        }
        self.clipsToBounds = false
        
        controlsReferenceView.isUserInteractionEnabled = false
    }
    
    func getBlocks(from fromVC: UIViewController, to toVCType: ViewControllerType) -> (
        (() -> Void), (() -> Void)?, (() -> Void)
    ) {
        
        var prep: (() -> Void) = {}
        var block: (() -> Void)? = nil
        var completion: (() -> Void) = {}
        
        switch toVCType {
        case .photos:
            switch fromVC {
            case is PhotosNavController:
                print("nothing, in photos")
            case is CameraViewController:
                let makeInactive = self.cameraIcon.makeNormalState()
                let makeOtherInactive = self.listsIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)
                let makeActive = self.photosIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                    self.cameraIcon.alpha = 1
                }
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            case is ListsNavController:
                let makeInactive = self.listsIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)
                let makeOtherInactive = self.cameraIcon.makeNormalState()
                let makeActive = self.photosIcon.makeActiveState()
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            default:
                print("could not cast view controller")
            }
        case .camera:
            switch fromVC {
            case is PhotosNavController:
                print("currently photos, to camera")
                
                let makeInactive = self.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)
                let makeOtherInactive = self.listsIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)
                let makeActive = self.cameraIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                }
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
                completion = {
                    self.cameraIcon.alpha = 0
                    self.hideRealShutter?(false)
                }

            case is CameraViewController:
                print("currently camera")
            case is ListsNavController:
                let makeInactive = self.listsIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)
                let makeOtherInactive = self.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)
                let makeActive = self.cameraIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                }
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
                completion = {
                    self.cameraIcon.alpha = 0
                    self.hideRealShutter?(false)
                }
            default:
                print("could not cast view controller")
            }
        case .lists:
            switch fromVC {
            case is PhotosNavController:
                let makeInactive = self.photosIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)
                let makeOtherInactive = self.cameraIcon.makeNormalState()
                let makeActive = self.listsIcon.makeActiveState()
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            case is CameraViewController:
                let makeInactive = self.cameraIcon.makeNormalState()
                let makeOtherInactive = self.photosIcon.makeNormalState(details: Constants.detailIconColorLight, foreground: Constants.foregroundIconColorLight, background: Constants.backgroundIconColorLight)
                let makeActive = self.listsIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                    self.cameraIcon.alpha = 1
                }
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }

            case is ListsNavController:
                print("currently lists")
            default:
                print("could not cast view controller")
            }
        }

        return (prep, block, completion)
    }
    
    func animate(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {
        animatingObjects += 1
        tabAnimator?.stopAnimation(false)
        tabAnimator?.finishAnimation(at: .current)
        tabAnimator?.addAnimations(block)
        tabAnimator?.addCompletion({ _ in
            self.animatingObjects -= 1
            if self.animatingObjects == 0 && !self.gestureInterruptedButton {
                completion()
            }
        })
        tabAnimator?.startAnimation()
    }
    func showLineView(show: Bool) {
        if show {
            UIView.animate(withDuration: 0.6) {
                self.topLineView.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.6) {
                self.topLineView.alpha = 0
            }
        }
    }
    
    func makeLayerInactiveState(duration: CGFloat, hide: Bool = false) {
        if let fillLayer = fillLayer {
            if let currentValue = fillLayer.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.path)) {
                let currentPath = currentValue as! CGPath
                fillLayer.path = currentPath
                fillLayer.removeAllAnimations()
            }
            
            let newCurve = createCurve(with: 0, iPhoneX: deviceHasNotch)
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                if !hide && !(ViewControllerState.currentVC is CameraViewController) {
                    self.showLineView(show: true)
                }
            })
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = fillLayer.path
            animation.toValue = newCurve
            animation.duration = Double(duration)
            fillLayer.path = newCurve
            fillLayer.add(animation, forKey: "path")
            
            CATransaction.commit()
            
            if hide {
                UIView.animate(withDuration: 0.5) {
                    self.contentView.frame.origin.y = self.contentView.bounds.height
                }
            }
        }
    }
    func makeLayerActiveState(duration: CGFloat, show: Bool = false) {
        if let fillLayer = fillLayer {
            if let currentValue = fillLayer.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.path)) {
                let currentPath = currentValue as! CGPath
                fillLayer.path = currentPath
                fillLayer.removeAllAnimations()
            }
            
            self.showLineView(show: false)
            let newCurve = createCurve(with: 1, iPhoneX: deviceHasNotch)
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = fillLayer.path
            animation.toValue = newCurve
            animation.duration = Double(duration)
            
            fillLayer.path = newCurve
            fillLayer.add(animation, forKey: "path")
            
            if show {
                UIView.animate(withDuration: 0.6) {
                    self.contentView.frame.origin.y = 0
                }
            }
        }
    }
    func makePercentageOfActive(percentage: CGFloat) {
        showLineView(show: false)
        let curve = createCurve(with: percentage, iPhoneX: deviceHasNotch)
        fillLayer?.path = curve
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let spacingPercentage = 90 / Constants.designedWidth
        let actualSpacing = spacingPercentage * bounds.width
        stackView.spacing = actualSpacing
        
        let curvePath: CGPath
        if let _ = ViewControllerState.currentVC as? CameraViewController {
            cameraIcon.makeActiveState()()
            curvePath = createCurve(iPhoneX: deviceHasNotch)
        } else {
            curvePath = createCurve(with: 0, iPhoneX: deviceHasNotch)
        }
        
        if let fillLayer = fillLayer {
            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = fillLayer.path
            pathAnimation.toValue = curvePath
            
            if curvePath.boundingBox.width >= fillLayer.path?.boundingBox.width ?? 0 {
                pathAnimation.duration = 0.3
            } else {
                pathAnimation.duration = 0.7
            }
            
            pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)

            fillLayer.path = curvePath
            fillLayer.add(pathAnimation, forKey: "pathAnimation")
        }
        
        /// camera icon frame origin as related to tab bar content view
        let adjustedCameraIconOrigin = cameraIcon.frame.origin.y + stackView.frame.origin.y
        
        /// camera icon frame's bottom y coordinate inside the tab bar content view
        let adjustedCameraIconBottom = adjustedCameraIconOrigin + cameraIcon.frame.height
        
        /// height of the content view
        let contentViewHeight = contentView.frame.height
        
        /// distance from the camera bottom to the bottom of the screen
        let distanceFromCameraBottomToScreenBottom = contentViewHeight - adjustedCameraIconBottom
        
        let cameraIconNormalLength = cameraIcon.bounds.width /// 40
        
        /// y coordinate of normal camera icon (40x40) inside camera bounds  (92x92)
        let cameraIconNormalInset = (Constants.shutterBoundsLength - cameraIconNormalLength) / 2 /// (92 - 40) / 2 = 26
        
        /// distance from bottom of screen to top of camera icon
        let distanceFromTargetTopToScreenBottom = ConstantVars.shutterBottomDistance + Constants.shutterBoundsLength - cameraIconNormalInset
        
        /// distance from bottom of screen to **bottom** of target camera icon
        let distanceFromTargetBottomToScreenBottom = distanceFromTargetTopToScreenBottom - cameraIcon.bounds.width
        
        let difference = distanceFromTargetBottomToScreenBottom - distanceFromCameraBottomToScreenBottom
        
        cameraIcon.offsetNeeded = difference
        
        
    }
    
    func createCurve(with percentage: CGFloat = 1, iPhoneX: Bool = true) -> CGPath {
        let differenceInSize = UIScreen.main.fixedCoordinateSpace.bounds.width - Constants.designedWidth
        let offset = differenceInSize / 3
        
        let width = bounds.width
        let height = bounds.height
        
        let halfWidth = width / 2
        
        var verticalMiddle: CGFloat
        let topPointOffset: CGFloat
        let topPointControlOffset: CGFloat
        let middleControlPointOffset: CGFloat
        if iPhoneX {
            verticalMiddle = CGFloat(46) - offset
            topPointOffset = CGFloat(78.5) - offset
            topPointControlOffset = CGFloat(36.5)
            middleControlPointOffset = CGFloat(46.82)
        } else {
            verticalMiddle = CGFloat(27.5)
            topPointOffset = CGFloat(62.5)
            topPointControlOffset = CGFloat(25.5)
            middleControlPointOffset = CGFloat(33.82)
        }
        
        verticalMiddle *= percentage
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: 0))
        bezierPath.addCurve(to: CGPoint(x: halfWidth - topPointOffset, y: 0), controlPoint1: CGPoint(x: 10, y: 0), controlPoint2: CGPoint(x: (halfWidth - topPointOffset) - topPointControlOffset, y: 0))
        bezierPath.addCurve(to: CGPoint(x: halfWidth, y: verticalMiddle), controlPoint1: CGPoint(x: (halfWidth - topPointOffset) + topPointControlOffset, y: 0), controlPoint2: CGPoint(x: halfWidth - middleControlPointOffset, y: verticalMiddle))
        bezierPath.addCurve(to: CGPoint(x: halfWidth + topPointOffset, y: 0), controlPoint1: CGPoint(x: halfWidth + middleControlPointOffset, y: verticalMiddle), controlPoint2: CGPoint(x: (halfWidth + topPointOffset) - topPointControlOffset, y: 0))
        bezierPath.addCurve(to: CGPoint(x: width, y: 0), controlPoint1: CGPoint(x: (halfWidth + topPointOffset) + topPointControlOffset, y: 0), controlPoint2: CGPoint(x: width - 10, y: 0))
        bezierPath.addLine(to: CGPoint(x: width, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.close()
        
        return bezierPath.cgPath
    }
}
