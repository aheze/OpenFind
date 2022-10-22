//
//  LaunchViewController.swift
//  FindAppClip1
//
//  Created by Zheng on 3/17/21.
//

import UIKit

class LaunchViewController: UIViewController {
    // MARK: Status bar

    var firstStatusBarLaunch = true
    var makeStatusBarHidden = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if firstStatusBarLaunch {
            return .default
        }
        return .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        if firstStatusBarLaunch {
            return false
        } else if makeStatusBarHidden {
            return true
        } else {
            if CurrentState.currentlyPresenting {
                return false
            } else {
                return true
            }
        }
    }
    
    // MARK: Frames

    @IBOutlet var frameContainerView: UIView!
    
    @IBOutlet var frameWidthC: NSLayoutConstraint!
    @IBOutlet var frameHeightC: NSLayoutConstraint!
    
    @IBOutlet var topImageView: UIImageView!
    @IBOutlet var rightImageView: UIImageView!
    @IBOutlet var bottomImageView: UIImageView!
    @IBOutlet var leftImageView: UIImageView!
    
    @IBOutlet var edgeContainerView: UIView!
    @IBOutlet var topView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var leftView: UIView!
    
    // MARK: Overlay background

    @IBOutlet var blueBackgroundView: UIView!
    
    // MARK: Main

    @IBOutlet var mainReferenceView: UIView!
    lazy var mainViewController: ViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            viewController.updateStatusBar = { [weak self] in
                guard let self = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.setNeedsStatusBarAppearanceUpdate()
                }
            }
            viewController.cameraViewController.cameraFinishedSetup = { [weak self] in
                guard let self = self else { return }
                if self.launchAction == .goToPermissions {
                    self.finishPermissionsToMain()
                }
            }
            return viewController
        }
        fatalError()
    }()
    
    // MARK: Permissions

    @IBOutlet var permissionsReferenceView: UIView!
    lazy var permissionsViewController: PermissionsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "PermissionsViewController") as? PermissionsViewController {
            return viewController
        }
        fatalError()
    }()
    
    var launchAction = LaunchAction.goToMain
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topView.alpha = 0
        rightView.alpha = 0
        bottomView.alpha = 0
        leftView.alpha = 0
    
        determineAction()
        
        addChildViewController(mainViewController, in: mainReferenceView)
        mainViewController.cameraViewController.textFieldContainer.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.firstStatusBarLaunch = false
            self.makeStatusBarHidden = true
            UIView.animate(withDuration: 0.3) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    var viewDidLayout = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewDidLayout {
            viewDidLayout = true
            
            setupInitialFrames()
            
            if launchAction == .goToMain {
                goToMain()
            } else {
                goToPermissions()
            }
        }
    }
}
