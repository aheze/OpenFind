//
//  LivePreviewViewController.swift
//  Camera
//
//  Created by Zheng on 11/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

class LivePreviewViewController: UIViewController {
    
    @IBOutlet weak var previewContainerView: UIView!
    
    /// same bounds as `view`, contains the safe view
    @IBOutlet weak var safeViewContainer: UIView!
    @IBOutlet weak var safeView: UIView!
    
    @IBOutlet weak var safeViewLeftC: NSLayoutConstraint!
    @IBOutlet weak var safeViewTopC: NSLayoutConstraint!
    @IBOutlet weak var safeViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var safeViewHeightC: NSLayoutConstraint!
    
    
    /// hugging the image
    /// BUT, will be scaled to different aspect - normal or full screen.
    @IBOutlet weak var previewFitView: UIView!
    @IBOutlet weak var previewFitViewLeftC: NSLayoutConstraint!
    @IBOutlet weak var previewFitViewTopC: NSLayoutConstraint!
    @IBOutlet weak var previewFitViewWidthC: NSLayoutConstraint!
    @IBOutlet weak var previewFitViewHeightC: NSLayoutConstraint!
    
    /// directly in view hierarchy
    @IBOutlet weak var testingView: UIView!
    @IBOutlet weak var testingView2: UIView!
    
    /// should match the frame of the image
    @IBOutlet weak var drawingView: UIView!
    var drawingViewProjectedFrame = CGRect.zero
    
    /// inside the drawing view, should match the safe view
    @IBOutlet weak var simulatedSafeView: UIView!
    
    /// don't scale this
    @IBOutlet weak var previewContentView: UIView!
    
    /// scale to safe area
    @IBOutlet weak var livePreviewView: LivePreviewView!
    @IBOutlet weak var pausedImageView: UIImageView!
    
    /// in case no camera was found
    var findFromPhotosButtonPressed: (() -> Void)?
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoDataOutput = AVCapturePhotoOutput()
    var cameraDevice: AVCaptureDevice?
    var captureCompletionBlock: ((UIImage) -> Void)?
    
    var imageSize: CGSize?
    
    var imageFitViewSize = CGSize.zero
    var imageFillSafeRect = CGRect.zero
    
    /// `true` = became `.aspectFill`
    var hitAspectTarget = false
    var aspectProgressTarget = CGFloat(1)
    
    /// `imageSize` updated, now update the aspect ratio
    var needSafeViewUpdate: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let viewBounds = view.layer.bounds
        livePreviewView.videoPreviewLayer.bounds = viewBounds
        livePreviewView.videoPreviewLayer.position = CGPoint(x: viewBounds.midX, y: viewBounds.midY)
        
    }
    
    func setup() {
        configureCamera()
        pausedImageView.alpha = 0
        livePreviewView.backgroundColor = .clear
        previewContentView.mask = safeViewContainer
        
        safeViewContainer.backgroundColor = Debug.tabBarAlwaysTransparent ? .blue : .clear
        safeView.backgroundColor = .blue
        
//        drawingView.addDebugBorders(.systemOrange)
//        simulatedSafeView.addDebugBorders(.systemGreen)
//        testingView.addDebugBorders(.red)
//        testingView2.addDebugBorders(.white)
//        aspectProgressView.addDebugBorders(.systemBlue)
        
        simulatedSafeView.backgroundColor = .systemGreen.withAlphaComponent(0.3)
        simulatedSafeView.layer.borderColor = UIColor.systemGreen.cgColor
        simulatedSafeView.layer.borderWidth = 5
        
    }
    
    func changeZoom(to zoom: CGFloat, animated: Bool) {
        guard let cameraDevice = cameraDevice else { return }
        do {
            try cameraDevice.lockForConfiguration()
            if animated {
                cameraDevice.ramp(toVideoZoomFactor: zoom, withRate: 200)
            } else {
                cameraDevice.videoZoomFactor = zoom
            }
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Error focusing \(error)")
        }
    }
    
    func changeAspectProgress(to aspectProgress: CGFloat) {
        let extraProgress = aspectProgressTarget - 1
        let scale = 1 + (extraProgress * aspectProgress)
        let previouslyHitAspectTarget = hitAspectTarget
        hitAspectTarget = scale >= aspectProgressTarget
        
        UIView.animate(withDuration: 0.3) {
            self.previewFitView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        if !Debug.tabBarAlwaysTransparent {
            if previouslyHitAspectTarget != hitAspectTarget {
                UIView.animate(withDuration: 0.6) {
                    self.safeViewContainer.backgroundColor = self.hitAspectTarget ? .blue : .clear
                }
            }
        }
    }
}


