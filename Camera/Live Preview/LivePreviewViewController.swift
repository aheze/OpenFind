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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        configureCamera()
        pausedImageView.alpha = 0
    }
    
    func changeZoom(to zoom: CGFloat) {
        do {
            try cameraDevice.lockForConfiguration()
            cameraDevice.ramp(toVideoZoomFactor: zoom, withRate: 200)
            cameraDevice.unlockForConfiguration()
        } catch {
            print("Error focusing \(error)")
        }
//        cameraDevice.ramp(toVideoZoomFactor: <#T##CGFloat#>, withRate: <#T##Float#>)
    }
}


