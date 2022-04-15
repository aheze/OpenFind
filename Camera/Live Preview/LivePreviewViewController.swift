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
    var changeContentContainerViewFrame: ((CGRect) -> Void)? /// called inside `changeAspectProgress`
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
    
    /// override loaded (if no camera found, still show)
    var loaded: (() -> Void)?
    
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

        Task {
            let orientation = await UIWindow.interfaceOrientation
            
            if let connection = livePreviewView.videoPreviewLayer.connection {
                switch orientation ?? .portrait {
                case .portrait: connection.videoOrientation = .portrait
                case .landscapeRight: connection.videoOrientation = .landscapeRight
                case .landscapeLeft: connection.videoOrientation = .landscapeLeft
                case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
                default: connection.videoOrientation = .portrait
                }
            }
            
            needSafeViewUpdate?()
        }
    }

    func setup() {
        pausedImageView.alpha = 0
        livePreviewView.backgroundColor = .clear
        
        previewContentView.mask = safeViewContainer
        safeViewContainer.backgroundColor = Debug.tabBarAlwaysTransparent ? .black : .clear
        safeView.backgroundColor = .blue
    }
}
