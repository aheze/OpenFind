//
//  TabBar.swift
//  FindTabBar
//
//  Created by Zheng on 12/17/20.
//

import SnapKit
import UIKit

class TabBarView: UIView {
    var shutterIgnoreFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if bounds.contains(point) {
            if ViewControllerState.currentVC is CameraViewController {
                return !shutterIgnoreFrame.contains(point)
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    var animatingObjects = 0
    var gestureInterruptedButton = false /// when button animating, then swipe away
    
    var tabAnimator: UIViewPropertyAnimator?
    
    var hideRealShutter: ((Bool) -> Void)?
    var changedViewController: ((ViewControllerType) -> Void)?
    var checkIfAnimating: (() -> (Bool))?
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerHeightC: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!
    
    /// reference view to add selecting buttons
    @IBOutlet var controlsReferenceView: UIView!
    
    // MARK: Selection in Photos

    var numberOfSelectedPhotos = 0
    var photoSelectionControlPressed: ((PhotoSlideAction) -> Void)?
    @IBOutlet var photosControls: UIView!
    
    var shouldStarSelectedPhotos = true
    @IBOutlet var starButton: CustomButton!
    @IBAction func starButtonPressed(_ sender: Any) {
        photoSelectionControlPressed?(.star)
    }
    
    var shouldCacheSelectedPhotos = true
    @IBOutlet var cacheButton: CustomButton!
    @IBAction func cacheButtonPressed(_ sender: Any) {
        photoSelectionControlPressed?(.cache)
    }
    
    @IBOutlet var photosDeleteButton: CustomButton!
    @IBAction func photosDeleteButtonPressed(_ sender: Any) {
        photoSelectionControlPressed?(.delete)
    }
    
    // MARK: Selection in Lists

    @IBOutlet var listsControls: UIView!
    @IBOutlet var listsSelectionLabel: UILabel!
    @IBOutlet var listsDeleteButton: CustomButton!
    
    var listsDeletePressed: (() -> Void)?
    @IBAction func listsDeleteButtonPressed(_ sender: Any) {
        listsDeletePressed?()
    }
    
    // MARK: Photo Slide controls

    @IBOutlet var photoSlideControls: UIView!
    @IBOutlet var slideShareButton: CustomButton!
    @IBAction func slideSharePressed(_ sender: Any) {
        photoSlideControlPressed?(.share)
    }

    @IBOutlet var slideStarButton: CustomButton!
    @IBAction func slideStarPressed(_ sender: Any) {
        photoSlideControlPressed?(.star)
    }
   
    @IBOutlet var slideCacheButton: CustomButton!
    @IBAction func slideCachePressed(_ sender: Any) {
        photoSlideControlPressed?(.cache)
    }
    
    @IBOutlet var slideDeleteButton: CustomButton!
    @IBAction func slideDeletePressed(_ sender: Any) {
        photoSlideControlPressed?(.delete)
    }
    
    @IBOutlet var slideInfoButton: CustomButton!
    @IBAction func slideInfoPressed(_ sender: Any) {
        photoSlideControlPressed?(.info)
    }
    
    var photoSlideControlPressed: ((PhotoSlideAction) -> Void)?
    
    @IBOutlet var topLineView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet var shadeView: UIView!
    
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var blurBackgroundView: UIView! /// extra color for more opaque look
    
    @IBOutlet var photosIcon: PhotosIcon!
    @IBOutlet var cameraIcon: CameraIcon!
    @IBOutlet var listsIcon: ListsIcon!
    
    @IBOutlet var photosContainerView: UIView!
    @IBOutlet var photosButton: CustomButton!
    @IBAction func photosButtonPressed(_ sender: Any) {
        if let currentVC = ViewControllerState.currentVC {
            let (prep, block, completion) = getBlocks(from: currentVC, to: .photos)
            if let block = block {
                if (checkIfAnimating ?? { false })() == false {
                    prep()
                    cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    animate(block: block, completion: completion)
                }
                changedViewController?(.photos)
            }
        }
    }
    
    @IBOutlet var cameraContainerView: UIView!
    @IBOutlet var cameraButton: CustomButton!
    @IBAction func cameraButtonPressed(_ sender: Any) {
        if let currentVC = ViewControllerState.currentVC {
            let (prep, block, completion) = getBlocks(from: currentVC, to: .camera)
            if let block = block {
                if (checkIfAnimating ?? { false })() == false {
                    prep()
                    cameraIcon.makeLayerActiveState(duration: FindConstants.transitionDuration)
                    makeLayerActiveState(duration: FindConstants.transitionDuration)
                    animate(block: block, completion: completion)
                }
                changedViewController?(.camera)
            }
        }
    }
    
    @IBOutlet var listsContainerView: UIView!
    @IBOutlet var listsButton: CustomButton!
    @IBAction func listsButtonPressed(_ sender: Any) {
        if let currentVC = ViewControllerState.currentVC {
            let (prep, block, completion) = getBlocks(from: currentVC, to: .lists)
            if let block = block {
                if (checkIfAnimating ?? { false })() == false {
                    prep()
                    cameraIcon.makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    makeLayerInactiveState(duration: FindConstants.transitionDuration)
                    animate(block: block, completion: completion)
                }
                changedViewController?(.lists)
            }
        }
    }
    
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
        contentView.frame = bounds
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
        cameraContainerView.alpha = 0
        shadeView.alpha = 1
        blurView.effect = nil
        blurBackgroundView.alpha = 0
        
        let timingParameters = UISpringTimingParameters(damping: 1, response: FindConstants.transitionDuration)
        tabAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        
        photosButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.photosIcon.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.photosIcon.alpha = 1
                })
            }
        }
        
        cameraButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.cameraIcon.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.cameraIcon.alpha = 1
                })
            }
        }
        
        listsButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.listsIcon.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.listsIcon.alpha = 1
                })
            }
        }
        
        clipsToBounds = false
        
        controlsReferenceView.isUserInteractionEnabled = false
        
        dimPhotoSlideControls(dim: true, isPhotosControls: true)
        
        setupAccessibility()
    }
    
    func getBlocks(from fromVC: UIViewController, to toVCType: ViewControllerType) -> (
        () -> Void, (() -> Void)?, () -> Void
    ) {
        var prep: (() -> Void) = {}
        var block: (() -> Void)?
        var completion: (() -> Void) = {}
        
        switch toVCType {
        case .photos:
            switch fromVC {
            case is PhotosWrapperController:
                break
            case is CameraViewController:
                let makeInactive = cameraIcon.makeNormalState()
                let makeOtherInactive = listsIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)
                let makeActive = photosIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                    self.cameraContainerView.alpha = 1
                }
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            case is ListsNavController:
                let makeInactive = listsIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)
                let makeOtherInactive = cameraIcon.makeNormalState()
                let makeActive = photosIcon.makeActiveState()
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            default:
                break
            }
        case .camera:
            switch fromVC {
            case is PhotosWrapperController:

                let makeInactive = photosIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)
                let makeOtherInactive = listsIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)
                let makeActive = cameraIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                }
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
                completion = {
                    self.cameraContainerView.alpha = 0
                    self.hideRealShutter?(false)
                }

            case is CameraViewController:
                break
            case is ListsNavController:
                let makeInactive = listsIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)
                let makeOtherInactive = photosIcon.makeNormalState(details: FindConstants.detailIconColorDark, foreground: FindConstants.foregroundIconColorDark, background: FindConstants.backgroundIconColorDark)
                let makeActive = cameraIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                }
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
                completion = {
                    self.cameraContainerView.alpha = 0
                    self.hideRealShutter?(false)
                }
            default:
                break
            }
        case .lists:
            switch fromVC {
            case is PhotosWrapperController:
                let makeInactive = photosIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)
                let makeOtherInactive = cameraIcon.makeNormalState()
                let makeActive = listsIcon.makeActiveState()
                
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }
            case is CameraViewController:
                let makeInactive = cameraIcon.makeNormalState()
                let makeOtherInactive = photosIcon.makeNormalState(details: FindConstants.detailIconColorLight, foreground: FindConstants.foregroundIconColorLight, background: FindConstants.backgroundIconColorLight)
                let makeActive = listsIcon.makeActiveState()
                
                prep = {
                    self.hideRealShutter?(true)
                    self.cameraContainerView.alpha = 1
                }
                block = {
                    makeInactive()
                    makeOtherInactive()
                    makeActive()
                }

            case is ListsNavController:
                break
            default:
                break
            }
        }

        return (prep, block, completion)
    }
    
    func animate(block: @escaping (() -> Void), completion: @escaping (() -> Void)) {
        animatingObjects += 1
        tabAnimator?.stopAnimation(false)
        tabAnimator?.finishAnimation(at: .current)
        tabAnimator?.addAnimations(block)
        tabAnimator?.addCompletion { _ in
            self.animatingObjects -= 1
            if self.animatingObjects == 0, !self.gestureInterruptedButton {
                completion()
            }
        }
        tabAnimator?.startAnimation()
    }

    func showLineView(show: Bool) {
        if show {
            if UserDefaults.standard.integer(forKey: "shutterStyle") == 3 {
                cameraIcon.fillBorderView.layer.borderWidth = 0.5
                cameraIcon.fillBorderView.layer.borderColor = FindConstants.detailIconColorLight.cgColor
            }
            UIView.animate(withDuration: 0.6) {
                self.topLineView.alpha = 1
                self.cameraIcon.fillBorderView.alpha = 1
            }
        } else {
            cameraIcon.fillBorderView.layer.borderWidth = 0
            UIView.animate(withDuration: 0.1) {
                self.topLineView.alpha = 0
                self.cameraIcon.fillBorderView.alpha = 0
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
            CATransaction.setCompletionBlock {
                if !hide, !(ViewControllerState.currentVC is CameraViewController) {
                    self.showLineView(show: true)
                }
            }
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = fillLayer.path
            animation.toValue = newCurve
            animation.duration = Double(duration)
            fillLayer.path = newCurve
            fillLayer.add(animation, forKey: "path")
            
            CATransaction.commit()
            
            if hide {
                isUserInteractionEnabled = false
                UIView.animate(withDuration: Double(duration)) {
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
            
            showLineView(show: false)
            let newCurve = createCurve(with: 1, iPhoneX: deviceHasNotch)
            
            let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.fromValue = fillLayer.path
            animation.toValue = newCurve
            animation.duration = Double(duration)
            
            fillLayer.path = newCurve
            fillLayer.add(animation, forKey: "path")
            
            if show {
                isUserInteractionEnabled = true
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
        let cameraIconNormalInset = (FindConstants.shutterBoundsLength - cameraIconNormalLength) / 2 /// (92 - 40) / 2 = 26
        
        /// distance from bottom of screen to top of camera icon
        let distanceFromTargetTopToScreenBottom = FindConstantVars.shutterBottomDistance + FindConstants.shutterBoundsLength - cameraIconNormalInset
        
        /// distance from bottom of screen to **bottom** of target camera icon
        let distanceFromTargetBottomToScreenBottom = distanceFromTargetTopToScreenBottom - cameraIcon.bounds.width
        
        let difference = distanceFromTargetBottomToScreenBottom - distanceFromCameraBottomToScreenBottom
        
        cameraIcon.offsetNeeded = difference
    }
    
    func createCurve(with percentage: CGFloat = 1, iPhoneX: Bool = true) -> CGPath {
        let differenceInSize = UIScreen.main.fixedCoordinateSpace.bounds.width - FindConstants.designedWidth
        let offset = min(3, differenceInSize / 3)
        
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
