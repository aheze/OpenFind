//
//  ViewController.swift
//  FindAppClip1
//
//  Created by Zheng on 3/12/21.
//

import UIKit

class ViewController: UIViewController {
    
    var updateStatusBar: (() -> Void)?
    
    // MARK: Download
    @IBOutlet weak var downloadReferenceView: UIView!
    
    // MARK: Camera
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraReferenceView: UIView!
    
    // MARK: Contraints
    @IBOutlet weak var downloadReferenceTopC: NSLayoutConstraint!
    
    lazy var cameraViewController: CameraViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            viewController.searchPressed = { [weak self] pressed in
                guard let self = self else { return }
                self.longPressGestureRecognizer.isEnabled = !pressed
                self.panGestureRecognizer.isEnabled = !pressed
            }
            return viewController
        }
        fatalError()
    }()
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBAction func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        longPressed(sender: sender)
    }
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        panned(sender: sender)
    }
    
    // MARK: Gesture release animations
    var animator: UIViewPropertyAnimator? /// animate gesture endings
    
    var blurAnimator: UIViewPropertyAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupCameraView()
        setupDownloadView()
        
        longPressGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        blurCamera()
    }

}

