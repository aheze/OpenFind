//
//  LivePreviewViewController.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import AVFoundation
import UIKit

struct LivePreviewImageSize {
    var viewSize: CGSize
    var size: CGSize
}

class LivePreviewViewController: UIViewController {
    var tabViewModel: TabViewModel
    
    @IBOutlet var previewContainerView: UIView!
    
    /// same bounds as `view`, contains the safe view
    @IBOutlet var safeViewContainer: UIView!
    var safeViewFrame = CGRect.zero
    @IBOutlet var safeView: UIView!
    
    @IBOutlet var safeViewLeftC: NSLayoutConstraint!
    @IBOutlet var safeViewTopC: NSLayoutConstraint!
    @IBOutlet var safeViewWidthC: NSLayoutConstraint!
    @IBOutlet var safeViewHeightC: NSLayoutConstraint!
    
    
    /// original, unscaled image size (pretty large)
//    var imageSize: LivePreviewImageSize?
    var imageSize: CGSize?
    
    /// image scaled down to the view
    var imageFitViewSize = CGSize.zero
    
    /// image filling the safe view
    var imageFillSafeRect = CGRect.zero
    
    /// hugging the image
    /// BUT, will be scaled to different aspect - normal or full screen.
    @IBOutlet var previewFitView: UIView!
    
    /// the frame of the scaled preview fit view, relative to `view`
    /// this basically adds the scale transforms to `previewFitView.frame`
    var previewFitViewFrame = CGRect.zero
    
    var previewFitViewScale = CGAffineTransform.identity
    /// the frame of the safe view, from `previewFitView`'s bounds
    var safeViewFrameFromPreviewFit = CGRect.zero
    
    /// update the frames of the camera
    var changeContentContainerViewFrame: ((CGRect) -> Void)?
    var changeSimulatedSafeViewFrame: ((CGRect) -> Void)?
    
    /// directly in view hierarchy
    @IBOutlet var testingView: UIView!
    @IBOutlet var testingView2: UIView!

    /// don't scale this
    @IBOutlet var previewContentView: UIView!
    
    /// scale to safe area
    @IBOutlet var livePreviewView: LivePreviewView!
    @IBOutlet var pausedImageView: UIImageView!
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoDataOutput = AVCapturePhotoOutput()
    var cameraDevice: AVCaptureDevice?
    
    /// a new frame of the live video was taken
    var frameCaptured: ((CVPixelBuffer) -> Void)?

    /// an actual photo was taken. Send back via another closure.
    var photoCaptured: ((UIImage) -> Void)?
    
    /// `true` = became `.aspectFill`
    var hitAspectTarget = false
    var aspectProgressTarget = CGFloat(1)
    
    /// `imageSize` updated, now update the aspect ratio
    var needSafeViewUpdate: (() -> Void)?
    
    init?(coder: NSCoder, tabViewModel: TabViewModel) {
        self.tabViewModel = tabViewModel
        super.init(coder: coder)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// need to disable animations, otherwise there is a weird moving
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        livePreviewView.videoPreviewLayer.frame = previewFitView.bounds
        CATransaction.commit()
        needSafeViewUpdate?()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let connection = livePreviewView.videoPreviewLayer.connection {
            switch UIDevice.current.orientation {
            case .portrait: connection.videoOrientation = .portrait
            case .landscapeRight: connection.videoOrientation = .landscapeLeft
            case .landscapeLeft: connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            default: connection.videoOrientation = .portrait
            }
        }
        
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//
//        let cameraPreviewTransform = livePreviewView.transform
//        needSafeViewUpdate?()
//
//        coordinator.animate { context in
//
//            let deltaTransform = coordinator.targetTransform
//            let deltaAngle: CGFloat = atan2(deltaTransform.b, deltaTransform.a)
//
//            var currentRotation = atan2(cameraPreviewTransform.b, cameraPreviewTransform.a)
//
//            // Adding a small value to the rotation angle forces the animation to occur in a the desired direction, preventing an issue where the view would appear to rotate 2PI radians during a rotation from LandscapeRight -> LandscapeLeft.
//            currentRotation += -1 * deltaAngle + 0.0001
//            self.livePreviewView.layer.setValue(currentRotation, forKeyPath: "transform.rotation.z")
//            self.livePreviewView.layer.frame = self.previewFitView.bounds
//        } completion: { context in
//            let currentTransform: CGAffineTransform = self.livePreviewView.transform
//            self.livePreviewView.transform = currentTransform
//        }
//    }

    func setup() {
        pausedImageView.alpha = 0
        livePreviewView.backgroundColor = .clear
        
        previewContentView.mask = safeViewContainer
        safeViewContainer.backgroundColor = Debug.tabBarAlwaysTransparent ? .black : .clear
        safeView.backgroundColor = .blue
    }
}
