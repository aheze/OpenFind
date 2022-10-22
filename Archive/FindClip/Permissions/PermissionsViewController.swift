//
//  PermissionsViewController.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import UIKit

class PermissionsViewController: UIViewController {
    @IBOutlet var searchBarView: UIView!
    @IBAction func searchButtonPressed(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)

        searchBarView.shake()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.permissionsView.transform = CGAffineTransform(translationX: 0, y: -32)
            self.permissionsBottomView.transform = CGAffineTransform(scaleX: 1, y: 1 + (32 / self.permissionsBottomView.bounds.height * 2))
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveLinear) {
                self.permissionsView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.permissionsBottomView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
        permissionsAnimationCount += 1
        UIView.animate(withDuration: 0.2) {
            self.permissionsNeededLabel.alpha = 1
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.permissionsAnimationCount -= 1
                if self.permissionsAnimationCount == 0 {
                    UIView.animate(withDuration: 0.5) {
                        self.permissionsNeededLabel.alpha = 0
                    }
                }
            }
        }
    }
    
    @IBOutlet var graphicsReferenceView: UIView!
    @IBOutlet var expandedGraphicsReferenceView: UIView!
    
    var changeToSettings = false
    var permissionsAnimationCount = 0
    @IBOutlet var permissionsNeededLabel: UILabel!
    @IBOutlet var permissionsBackgroundView: UIView!
    @IBOutlet var permissionsView: UIView!
    @IBOutlet var permissionsShadowView: UIView!
    @IBOutlet var permissionsBottomView: UIView!
    @IBOutlet var allowAccessButton: GradientButton!
    @IBAction func allowAccessPressed(_ sender: Any) {
        requestAccess()
    }
    
    // MARK: Permissions

    var granted: (() -> Void)? /// tell LaunchVC that permission was granted
    var permissionAction = PermissionAction.ask
    
    // MARK: Gestures

    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        handlePan(sender: sender)
    }
    
    var began = false
    var animator: UIViewPropertyAnimator? /// animate gesture endings
    var savedOffset = CGFloat(0)
    
    // MARK: Constraints

    @IBOutlet var searchBarTopC: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureConstraints()
        addGraphicsView()
        
        if changeToSettings {
            allowAccessButton.setTitle("Go to Settings", for: .normal)
        }
    }
    
    var viewDidLayout = false
    var didLayoutSubviews: (() -> Void)?
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        
        if !viewDidLayout {
            viewDidLayout = true
            didLayoutSubviews?()
        }
    }
}
