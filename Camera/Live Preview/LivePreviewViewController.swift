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
    
    /// don't scale this
    @IBOutlet weak var previewContentView: UIView!
    
    /// scale for progress
    @IBOutlet weak var aspectProgressView: UIView!
    
    /// scale to safe area
    @IBOutlet weak var livePreviewView: LivePreviewView!
    @IBOutlet weak var pausedImageView: UIImageView!
    
    /// in case no camera was found
    var findFromPhotosButtonPressed: (() -> Void)?
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoDataOutput = AVCapturePhotoOutput()
    var cameraDevice: AVCaptureDevice!
    var captureCompletionBlock: ((UIImage) -> Void)?
    
    var imageSize: CGSize?
    
    var imageFitViewRect = CGRect.zero
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
        
        safeViewContainer.backgroundColor = .clear
        safeView.backgroundColor = .blue
    }
    
    func changeZoom(to zoom: CGFloat, animated: Bool) {
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
        aspectProgressView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        let previouslyHitAspectTarget = hitAspectTarget
        hitAspectTarget = scale >= aspectProgressTarget
        
        if previouslyHitAspectTarget != hitAspectTarget {
            UIView.animate(withDuration: 0.6) {
                self.safeViewContainer.backgroundColor = self.hitAspectTarget ? .blue : .clear
            }
        }
    }
}


