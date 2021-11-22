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
    
//    var currentlyCapturing = false
    
    @IBOutlet weak var livePreviewView: LivePreviewView!
    @IBOutlet weak var pausedImageView: UIImageView!
    
    let session = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoDataOutput = AVCapturePhotoOutput()
    var cameraDevice: AVCaptureDevice!
    var captureCompletionBlock: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        configureCamera()
        pausedImageView.alpha = 0
    }
    
    func changeZoom(to zoom: CGFloat) {
        
    }
}


