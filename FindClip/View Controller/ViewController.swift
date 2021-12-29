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

    @IBOutlet var downloadReferenceView: UIView!
    
    @IBOutlet var downloadCoverView: UIView!
    
    // MARK: Camera

    @IBOutlet var cameraContainerView: UIView!
    @IBOutlet var cameraReferenceView: UIView!
    
    // MARK: Contraints

    @IBOutlet var downloadReferenceTopC: NSLayoutConstraint!
    
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
        downloadCoverView.alpha = 1
        
        longPressGestureRecognizer.delegate = self
        panGestureRecognizer.delegate = self
        blurCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UIAccessibility.isVoiceOverRunning {
            let alert = UIAlertController(title: "Get the full app?", message: "This App Clip has limited compatibility with VoiceOver, while the full app is completely optimized for accessibility. Would you like to download the full app instead?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Download the full app", style: UIAlertAction.Style.default, handler: { _ in
                if let url = URL(string: "https://apps.apple.com/app/find-command-f-for-camera/id1506500202") {
                    UIApplication.shared.open(url)
                }
            }))
            alert.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.cancel, handler: nil))
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(x: (view.bounds.width / 2) - 40, y: view.bounds.height - 80, width: 80, height: 80)
            }
            present(alert, animated: true, completion: nil)
        }
    }
}
