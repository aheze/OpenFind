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
    }
    
    func changeZoom(to zoom: CGFloat) {
        do {
            try cameraDevice.lockForConfiguration()
            cameraDevice.ramp(toVideoZoomFactor: zoom, withRate: 200)
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Error focusing \(error)")
        }
    }
}


