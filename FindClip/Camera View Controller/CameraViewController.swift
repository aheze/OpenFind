//
//  CameraViewController.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit
import CoreMotion
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraContentView: UIView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    // MARK: Camera controls
    @IBOutlet weak var controlsBaseView: UIView!
    @IBOutlet weak var controlsContainer: passthroughGroupView!
    @IBOutlet weak var shutter: Shutter!
    
    @IBOutlet weak var fullScreenView: UIView!
    @IBOutlet weak var fullScreenImageView: UIImageView!
    @IBOutlet weak var fullScreenButton: FadingButton!
    @IBAction func fullScreenButtonPressed(_ sender: Any) {
        CurrentState.currentlyFullScreen.toggle()
        makeFullScreen(CurrentState.currentlyFullScreen)
    }
    
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var flashImageView: UIImageView!
    @IBOutlet weak var flashDisableIcon: FlashDisableIcon!
    @IBOutlet weak var flashButton: FadingButton!
    @IBAction func flashButtonPressed(_ sender: Any) {
        CurrentState.flashlightOn.toggle()
        toggleFlashlight(CurrentState.flashlightOn)
    }
    
    @IBOutlet weak var showControlsView: UIView!
    @IBAction func showControlsPressed(_ sender: Any) {
        CurrentState.currentlyFullScreen = false
        makeFullScreen(CurrentState.currentlyFullScreen)
    }
    
    // MARK: Search bar
    var searchPressed: ((Bool) -> Void)?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldContainer: UIView!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var textField: PaddedTextField!
    
    // MARK: Download
    @IBOutlet weak var morphingLabel: LTMorphingLabel!
    @IBOutlet weak var getButton: FadingButton!
    @IBOutlet weak var goBackButton: FadingButton!
    
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
    @IBOutlet weak var textContainerTopC: NSLayoutConstraint!
    @IBOutlet weak var cameraControlsBottomC: NSLayoutConstraint!
    @IBOutlet weak var showControlsBottomC: NSLayoutConstraint!
    @IBOutlet weak var bottomPromptViewHeight: NSLayoutConstraint!
    @IBOutlet weak var goBackBottomC: NSLayoutConstraint!
    @IBOutlet weak var promptLabelTopC: NSLayoutConstraint!
    
    // MARK: Camera mask
    @IBOutlet weak var cameraMaskView: UIView!
    @IBOutlet weak var cameraMaskViewMain: UIView!
    @IBOutlet weak var cameraMaskBottomC: NSLayoutConstraint!
    @IBOutlet weak var cameraShadowBottomC: NSLayoutConstraint!
    @IBOutlet weak var overlayShadowBottomC: NSLayoutConstraint!
    
    @IBOutlet weak var gradientView: Gradient!
    
    @IBOutlet weak var shadowView: ClearShadow!
    @IBOutlet weak var overlayShadowView: ClearShadow!
    
    // MARK: Camera view
    @IBOutlet weak var cameraView: CameraView!
    
    var cameraFinishedSetup: (() -> Void)?
    let avSession = AVCaptureSession()
    var cameraDevice: AVCaptureDevice?
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: Focus
    @IBOutlet weak var focusView: UIView!
    @IBOutlet var focusGestureRecognizer: UILongPressGestureRecognizer!
    @IBAction func handleFocusGesture(_ sender: UILongPressGestureRecognizer) {
        focused(sender: sender)
    }
    
    // MARK: Finding
    var findText = ""
    var busyFastFinding = false
    var pixelBufferSize = CGSize(width: 0, height: 0)
    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    // MARK: Pausing
    var waitingToFind = false /// when changed letters in search bar, but already is finding, wait until finished.
    var currentPausedImage: UIImage?
    var captureCompletionBlock: ((UIImage) -> Void)?
    func capturePhoto(completion: ((UIImage) -> Void)?) { captureCompletionBlock = completion }
    @IBOutlet weak var pausedImageView: UIImageView!
    
    // MARK: Drawing
    @IBOutlet weak var drawingView: UIView!
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
