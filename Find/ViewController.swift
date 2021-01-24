//
//  ViewController.swift
//  Find
//
//  Created by Zheng on 12/28/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let realm = try! Realm()
    var photoObjects: Results<HistoryModel>?
    
    @IBOutlet weak var tabBarView: TabBarView!
    @IBOutlet weak var tabBarHeightC: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
        
    @IBOutlet weak var blurContainerView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var shadeView: UIView!
    
    var globalUrl : URL = URL(fileURLWithPath: "")
    var highlightColor = "00aeef"
    
    // MARK: - View Controllers
    
    lazy var photos: PhotosWrapperController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as? PhotosViewController {
            
            let navigationController = PhotosNavController(rootViewController: viewController)
            navigationController.viewController = viewController
            viewController.modalPresentationCapturesStatusBarAppearance = true
            
            viewController.changePresentationMode = { [weak self] presentingSlides in
                guard let self = self else { return }
                
                if presentingSlides {
                    self.longPressGestureRecognizer.isEnabled = false
                    self.panGestureRecognizer.isEnabled = false
                    self.tabBarView.showPhotoSlideControls(show: true)
                } else {
                    self.longPressGestureRecognizer.isEnabled = true
                    self.panGestureRecognizer.isEnabled = true
                    self.tabBarView.showPhotoSlideControls(show: false)
                }
            }
            viewController.showSelectionControls = { [weak self] show in
                guard let self = self else { return }
                self.tabBarView.showPhotoSelectionControls(show: show)
                
                if show {
                    self.longPressGestureRecognizer.isEnabled = false
                    self.panGestureRecognizer.isEnabled = false
                } else {
                    self.longPressGestureRecognizer.isEnabled = true
                    self.panGestureRecognizer.isEnabled = true
                }
            }
            viewController.updateActions = { [weak self] action in
                guard let self = self else { return }
                self.tabBarView.updateActions(action: action, isPhotosControls: true)
            }
            viewController.updateSlideActions = { [weak self] action in
                guard let self = self else { return }
                self.tabBarView.updateActions(action: action, isPhotosControls: false)
            }
            viewController.dimSlideControls = { [weak self] (dim, isPhotosControls) in
                guard let self = self else { return }
                self.tabBarView.dimPhotoSlideControls(dim: dim, isPhotosControls: isPhotosControls)
            }
            viewController.hideTabBar = { [weak self] shouldHide in
                guard let self = self else { return }
                
                UIView.animate(withDuration: 0.2) {
                    self.tabBarView.alpha = shouldHide ? 0 : 1
                }
            }
            
            /// controls in selection
            tabBarView.photoSelectionControlPressed = { action in
                switch action {
                case .star:
                    viewController.star(viewController.shouldStarSelection)
                case .cache:
                    viewController.cache(viewController.shouldCacheSelection)
                case .delete:
                    viewController.deleteSelectedPhotos()
                default:
                    print("Can't handle action in selection")
                }
            }
            
            /// controls for each photo in slides
            tabBarView.photoSlideControlPressed = { action in
                viewController.currentSlidesController?.actionPressed(action: action)
            }
            
            let wrapper = PhotosWrapperController()
            wrapper.navController = navigationController
            return wrapper
        }
        fatalError()
    }()
    lazy var camera: CameraViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            viewController.globalUrl = globalUrl
            
            tabBarView.hideRealShutter = { hide in
                if hide {
                    viewController.cameraIcon.alpha = 0
                } else {
                    viewController.cameraIcon.alpha = 1
                }
            }
            viewController.cameraChanged = { [weak self] on in
                guard let self = self else { return }
                self.tabBarView.cameraIcon.toggle(on: on)
                if on {
                    self.tabBarView.makeLayerInactiveState(duration: 0.4, hide: true)
                    self.longPressGestureRecognizer.isEnabled = false
                    self.panGestureRecognizer.isEnabled = false
                    self.camera.makeActiveState()
                } else {
                    self.tabBarView.makeLayerActiveState(duration: 0.4, show: true)
                    self.longPressGestureRecognizer.isEnabled = true
                    self.panGestureRecognizer.isEnabled = true
                    self.camera.makeInactiveState()
                }
            }
            return viewController
        }
        fatalError()
    }()
    
    lazy var lists: ListsNavController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ListsController") as? ListsController {
            let navigationController = ListsNavController(rootViewController: viewController)
            navigationController.viewController = viewController
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.showSelectionControls = { [weak self] show in
                guard let self = self else { return }
                self.tabBarView.showListsControls(show: show)
                
                if show {
                    self.longPressGestureRecognizer.isEnabled = false
                    self.panGestureRecognizer.isEnabled = false
                } else {
                    self.longPressGestureRecognizer.isEnabled = true
                    self.panGestureRecognizer.isEnabled = true
                }
            }
            viewController.updateSelectionLabel = { [weak self] numberSelected in
                guard let self = self else { return }
                self.tabBarView.updateLabel(numberOfSelected: numberSelected)
            }
            tabBarView.listsDeletePressed = { [weak self] in
                guard let self = self else { return }
                viewController.listDeleteButtonPressed()
            }
            return navigationController
        }
        fatalError()
    }()
    
    // MARK: Camera shutoff
    var cameraShutoffTask = DispatchWorkItem { print("shut") }
    var shutoffCamera: (() -> Void)?
    
    // MARK: Gestures
    var blurAnimator: UIViewPropertyAnimator?
    var animator: UIViewPropertyAnimator? /// animate gesture endings
    
    var gestures = Gestures()
    
    // MARK: Gesture error refresh
    
    @IBOutlet weak var gestureRefreshButton: UIButton!
    @IBAction func gestureRefreshButtonPressed(_ sender: Any) {
        addChild(camera, in: containerView)
        if let currentVC = ViewControllerState.currentVC {
            removeChild(currentVC)
        }
        ViewControllerState.currentVC = camera
        ViewControllerState.newVC = nil
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
        panGestureRecognizer.setTranslation(.zero, in: containerView)
        gestures.completedMove = false
        gestures.direction = nil
        gestures.isAnimating = false
        gestures.totalTranslation = 0
        gestures.gestureSavedOffset = 0
        animator?.stopAnimation(true)
        blurAnimator?.stopAnimation(true)
        
        let block = {
            self.tabBarView.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
            self.tabBarView.listsIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
            self.tabBarView.cameraIcon.makeActiveState()()
        }
        block()
        self.tabBarView.cameraIcon.makeLayerActiveState(duration: Constants.transitionDuration)
        self.tabBarView.makeLayerActiveState(duration: Constants.transitionDuration)
        self.tabBarView.hideRealShutter?(false)
        self.tabBarView.cameraIcon.alpha = 0
        
        self.shadeView.alpha = 0
        self.blurView.effect = nil
        tabBarView.shadeView.alpha = 1
        tabBarView.blurView.effect = nil
        tabBarView.blurBackgroundView.alpha = 0
        containerView.sendSubviewToBack(camera.view) /// camera view
        containerView.bringSubviewToFront(blurContainerView)
    }
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if gestures.isAnimating {
                
                let listsCollectionView = lists.viewController.collectionView
                listsCollectionView?.isScrollEnabled = false
                listsCollectionView?.isScrollEnabled = true
                    
                let photosCollectionView = photos.navController.viewController.collectionView
                photosCollectionView?.isScrollEnabled = false
                photosCollectionView?.isScrollEnabled = true
                
                animator?.isReversed = false
                animator?.stopAnimation(true)
                if !gestures.isRubberBanding {
                    self.tabBarView.animatingObjects -= 1
                }
                if let currentValue = tabBarView.fillLayer?.presentation()?.value(forKeyPath: #keyPath(CAShapeLayer.path)) {
                    let currentPath = currentValue as! CGPath
                    tabBarView.fillLayer?.path = currentPath
                    tabBarView.fillLayer?.removeAllAnimations()
                }
                if let currentValue = tabBarView.cameraIcon.rimView.layer.presentation()?.value(forKeyPath: #keyPath(CALayer.borderColor)) {
                    let currentColor = currentValue as! CGColor
                    tabBarView.cameraIcon.rimView.layer.borderColor = currentColor
                    tabBarView.cameraIcon.rimView.layer.removeAllAnimations()
                }
                
                blurAnimator?.pauseAnimation()
                blurAnimator?.isReversed = false
                
                gestures.isAnimating = false
                
                if let viewToTrack = gestures.viewToTrackChanges {
                    let newPosition = viewToTrack.frame.origin.x
                    let difference = newPosition - gestures.framePositionWhenLifted
                    
                    if gestures.isRubberBanding {
                        let calculatedPosition: CGFloat
                        if newPosition <= 0 {
                            calculatedPosition = -pow(-newPosition, 1 / Constants.rubberBandingPower)
                        } else {
                            calculatedPosition = pow(newPosition, 1 / Constants.rubberBandingPower)
                        }
                        gestures.gestureSavedOffset = calculatedPosition
                        
                    } else {
                        let unadjustedTotal = gestures.totalTranslation + difference
                        var adjustedTotal = gestures.totalTranslation + difference
                        
                        if gestures.direction == .left {
                            if gestures.toOverlay { /// camera to lists
                                /// overflow
                                if unadjustedTotal <= -containerView.frame.width { /// totalValue is negative
                                    let calculatedDifference = pow(abs(newPosition), 1 / Constants.rubberBandingPower)
                                    adjustedTotal = -containerView.frame.width - calculatedDifference
                                }
                            } else { /// photos to camera
                                /// overflow
                                if newPosition > 0 {
                                    let calculatedDifference = pow(newPosition, 1 / Constants.rubberBandingPower)
                                    adjustedTotal = calculatedDifference
                                } else if newPosition <= -containerView.frame.width - Constants.gesturePadding { /// swiping right while camera is shown
                                    adjustedTotal = -containerView.frame.width - Constants.gesturePadding
                                }
                            }
                        } else if gestures.direction == .right {
                            if gestures.toOverlay { /// camera to photos
                                /// overflow
                                if newPosition > 0 {
                                    let calculatedDifference = pow(newPosition, 1 / Constants.rubberBandingPower)
                                    adjustedTotal = containerView.frame.width + calculatedDifference
                                }
                            } else { /// lists to camera
                                if unadjustedTotal <= 0 {
                                    let calculatedDifference = pow(abs(newPosition), 1 / Constants.rubberBandingPower)
                                    adjustedTotal = -calculatedDifference
                                } else if unadjustedTotal >= containerView.frame.width + Constants.gesturePadding { /// swiping right while camera is shown
                                    adjustedTotal = containerView.frame.width + Constants.gesturePadding
                                }
                            }
                        }
                        gestures.gestureSavedOffset = adjustedTotal
                    }
                }
            }
        case .ended, .cancelled, .failed:
            if !gestures.isAnimating && !gestures.hasMovedFromPress {
                let position: CGFloat
                
                gestures.totalTranslation = gestures.gestureSavedOffset
                if gestures.direction == .left {
                    position = containerView.frame.width + gestures.totalTranslation
                } else {
                    position = gestures.totalTranslation
                }
                
                if gestures.isRubberBanding {
                    finishMoveRubberBand(totalValue: gestures.totalTranslation, velocity: 0)
                } else {
                    if
                        let currentVC = ViewControllerState.currentVC,
                        let newVC = ViewControllerState.newVC
                    {
                        finishMoveVC(currentX: position, velocity: 0, from: currentVC, to: newVC)
                    }
                }
            }
        default:
            break
        }
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            if gestures.direction == nil {
                let timingParameters = UISpringTimingParameters(damping: 1, response: Constants.transitionDuration, initialVelocity: CGVector(dx: 0, dy: 0))
                blurAnimator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
            }
            blurAnimator?.pauseAnimation()
        case .changed:
            gestures.hasMovedFromPress = true
            let velocity = sender.velocity(in: view)
            let translation = sender.translation(in: view).x
            
            gestures.totalTranslation = translation + gestures.gestureSavedOffset
            
            if gestures.direction == nil {
                if velocity.x > 0 {
                    gestures.direction = .right
                    
                    switch ViewControllerState.currentVC {
                    case is PhotosWrapperController:
                        let photosCollectionView = photos.navController.viewController.collectionView
                        photosCollectionView?.isScrollEnabled = false
                        photosCollectionView?.isScrollEnabled = true
                        gestures.isRubberBanding = true
                    case is CameraViewController:
                        startMoveVC(from: camera, to: photos, direction: .right, toOverlay: true)
                    case is ListsNavController:
                        let listsCollectionView = lists.viewController.collectionView
                        listsCollectionView?.isScrollEnabled = false
                        listsCollectionView?.isScrollEnabled = true
                        startMoveVC(from: lists, to: camera, direction: .right, toOverlay: false)
                    default:
                        print("could not cast view controller")
                    }
                } else {
                    gestures.direction = .left
                    
                    switch ViewControllerState.currentVC {
                    case is PhotosWrapperController:
                        let photosCollectionView = photos.navController.viewController.collectionView
                        photosCollectionView?.isScrollEnabled = false
                        photosCollectionView?.isScrollEnabled = true
                        startMoveVC(from: photos, to: camera, direction: .left, toOverlay: false)
                    case is CameraViewController:
                        startMoveVC(from: camera, to: lists, direction: .left, toOverlay: true)
                    case is ListsNavController:
                        let listsCollectionView = lists.viewController.collectionView
                        listsCollectionView?.isScrollEnabled = false
                        listsCollectionView?.isScrollEnabled = true
                        gestures.isRubberBanding = true
                    default:
                        print("could not cast view controller")
                    }
                }
            } else {
                if gestures.isRubberBanding {
                    moveRubberBand(totalValue: gestures.totalTranslation)
                } else {
                    continueMoveVC(totalValue: gestures.totalTranslation)
                }
            }
        case .ended, .failed:
            self.gestures.hasMovedFromPress = false
            let velocity = sender.velocity(in: view)
            
            let position: CGFloat
            
            if gestures.direction == .left {
                position = containerView.frame.width + gestures.totalTranslation
            } else {
                position = gestures.totalTranslation
            }
            
            if gestures.isRubberBanding {
                finishMoveRubberBand(totalValue: gestures.totalTranslation, velocity: velocity.x)
            } else {
                if
                    let currentVC = ViewControllerState.currentVC,
                    let newVC = ViewControllerState.newVC
                {
                    finishMoveVC(currentX: position, velocity: velocity.x, from: currentVC, to: newVC)
                }
            }
        case .cancelled:
            print("CANCELLED")
        default:
            print("default pan")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shutoffCamera = {
            print("Shut off cam!!")
            self.camera.stopSession()
        }

        setupFilePath()
        checkIfHistoryImagesExist()
        checkForOldUserDefaults()
        
        tabBarHeightC.constant =  CGFloat(ConstantVars.tabHeight)
        
        ViewControllerState.currentVC = camera
        
        addChild(camera)
        
        // Add Child View as Subview
        containerView.insertSubview(camera.view, at: 0)
        
        // Configure Child View
        camera.view.frame = containerView.bounds
        camera.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        camera.didMove(toParent: self)
        
        longPressGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        
        longPressGestureRecognizer.cancelsTouchesInView = false
        
        tabBarView.changedViewController = { [weak self] newViewController in
            guard let self = self else { return }
            
            switch newViewController {
            case .photos:
                self.transition(to: self.photos)
            case .camera:
                self.transition(to: self.camera)
            case .lists:
                self.transition(to: self.lists)
            }
        }
        
        tabBarView.checkIfAnimating = { [weak self] in
            guard let self = self else { return false }
            
            if self.gestures.direction == nil || self.gestures.isRubberBanding {
                return false
            } else {
                return true
            }
        }
        
//        tabBarView.
        
        blurView.effect = nil
        shadeView.alpha = 0
        blurView.isHidden = false
        shadeView.isHidden = false
        
        gestureRefreshButton.layer.cornerRadius = 12
        
    }

    /// enable both the long press and pan gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestures.direction == nil {
            if let gesture = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = gesture.velocity(in: containerView)
                return abs(velocity.x) > abs(velocity.y)
            }
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let location = touch.location(in: containerView)
        
        let shutterArea = CGRect(x: containerView.bounds.width / 2 - 50, y: containerView.bounds.height - 140, width: 100, height: 140)
        let photoFilterArea = photos.navController.viewController.segmentedSlider?.frame ?? CGRect(x: 0, y: 0, width: 0, height: 0)
        if shutterArea.contains(location) || photoFilterArea.contains(location) {
            return false
        }
        return true
    }
}

