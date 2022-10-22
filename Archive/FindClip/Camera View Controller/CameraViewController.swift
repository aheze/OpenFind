//
//  CameraViewController.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import AVFoundation
import CoreMotion
import UIKit

class CameraViewController: UIViewController {
    @IBOutlet var cameraContentView: UIView!
    @IBOutlet var blurView: UIVisualEffectView!
    
    // MARK: Camera controls

    @IBOutlet var controlsBaseView: UIView!
    @IBOutlet var controlsContainer: passthroughGroupView!
    @IBOutlet var shutter: Shutter!
    
    @IBOutlet var fullScreenView: UIView!
    @IBOutlet var fullScreenImageView: UIImageView!
    @IBOutlet var fullScreenButton: FadingButton!
    @IBAction func fullScreenButtonPressed(_ sender: Any) {
        CurrentState.currentlyFullScreen.toggle()
        makeFullScreen(CurrentState.currentlyFullScreen)
    }
    
    @IBOutlet var flashView: UIView!
    @IBOutlet var flashImageView: UIImageView!
    @IBOutlet var flashDisableIcon: FlashDisableIcon!
    @IBOutlet var flashButton: FadingButton!
    @IBAction func flashButtonPressed(_ sender: Any) {
        CurrentState.flashlightOn.toggle()
        toggleFlashlight(CurrentState.flashlightOn)
    }
    
    @IBOutlet var showControlsView: UIView!
    @IBAction func showControlsPressed(_ sender: Any) {
        CurrentState.currentlyFullScreen = false
        makeFullScreen(CurrentState.currentlyFullScreen)
    }
    
    // MARK: Search bar

    var searchPressed: ((Bool) -> Void)?
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var textFieldContainer: UIView!
    @IBOutlet var textFieldBackgroundView: UIView!
    @IBOutlet var textField: PaddedTextField!
    
    // MARK: Download

    @IBOutlet var morphingLabel: LTMorphingLabel!
    @IBOutlet var getButton: FadingButton!
    @IBOutlet var goBackButton: FadingButton!
    
    var presentPressed: (() -> Void)?
    @IBAction func getButtonPressed(_ sender: Any) {
        if !GestureState.began {
            presentPressed?()
        }
    }
    
    @IBAction func goBackPressed(_ sender: Any) {
        if !GestureState.began {
            presentPressed?()
            UIView.animate(withDuration: 0.2) {
                self.goBackButton.alpha = 0
            }
        }
    }
    
    // MARK: Constraints

    @IBOutlet var textContainerTopC: NSLayoutConstraint!
    @IBOutlet var cameraControlsBottomC: NSLayoutConstraint!
    @IBOutlet var showControlsBottomC: NSLayoutConstraint!
    @IBOutlet var bottomPromptViewHeight: NSLayoutConstraint!
    @IBOutlet var goBackBottomC: NSLayoutConstraint!
    @IBOutlet var promptLabelTopC: NSLayoutConstraint!
    
    // MARK: Camera mask

    @IBOutlet var cameraMaskView: UIView!
    @IBOutlet var cameraMaskViewMain: UIView!
    @IBOutlet var cameraMaskBottomC: NSLayoutConstraint!
    @IBOutlet var cameraShadowBottomC: NSLayoutConstraint!
    @IBOutlet var overlayShadowBottomC: NSLayoutConstraint!
    
    @IBOutlet var gradientView: Gradient!
    
    @IBOutlet var shadowView: ClearShadow!
    @IBOutlet var overlayShadowView: ClearShadow!
    
    // MARK: Camera view

    @IBOutlet var cameraView: CameraView!
    
    var cameraFinishedSetup: (() -> Void)?
    let avSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: Focus

    @IBOutlet var focusView: UIView!
    @IBOutlet var focusGestureRecognizer: UILongPressGestureRecognizer!
    @IBAction func handleFocusGesture(_ sender: UILongPressGestureRecognizer) {
        focused(sender: sender)
    }
    
    // MARK: Finding

    var Sentence = ""
    var busyFastFinding = false
    var pixelBufferSize = CGSize(width: 0, height: 0)
    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    // MARK: Pausing

    var waitingToFind = false /// when changed letters in search bar, but already is finding, wait until finished.
    var currentPausedImage: UIImage?
    var captureCompletionBlock: ((UIImage) -> Void)?
    func capturePhoto(completion: ((UIImage) -> Void)?) { captureCompletionBlock = completion }
    @IBOutlet var pausedImageView: UIImageView!
    
    // MARK: Drawing

    @IBOutlet var drawingView: UIView!
    var currentComponents = [Component]()
    
    // MARK: Motion and AR Engine

    var motionManager = CMMotionManager()
    var initialAttitude: CMAttitude?
    var motionXAsOfHighlightStart = Double(0) ///     X
    var motionYAsOfHighlightStart = Double(0) ///     Y
    
    /// scale + haptic feedback
    var canNotify = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupGestures()
        configureButtons()
        configureConstraints()
        configureMotion()
    }
}
