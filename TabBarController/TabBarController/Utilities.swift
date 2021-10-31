//
//  Utilities.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import UIKit

class ButtonView: UIButton {

    var tapped: (() -> Void)?
    var shouldFade = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchFinish(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        self.addTarget(self, action: #selector(touchConfirm(_:)), for: [.touchUpInside, .touchDragEnter])
    }

    @objc func touchDown(_ sender: UIButton) {
        fade(true)
    }
    @objc func touchFinish(_ sender: UIButton) {
        fade(false)
    }
    @objc func touchConfirm(_ sender: UIButton) {
        tapped?()
    }
    
    func fade(_ fade: Bool) {
        if shouldFade {
            if fade {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 1
                })
            }
        }
    }
}

extension UIViewController {
    func addChild(_ childViewController: UIViewController, in inView: UIView) {
        // Add Child View Controller
        addChild(childViewController)
        
        // Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        // Configure Child View
        childViewController.view.frame = inView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    func removeChild(_ childViewController: UIViewController) {
        // Notify Child View Controller
        childViewController.willMove(toParent: nil)

        // Remove Child View From Superview
        childViewController.view.removeFromSuperview()

        // Notify Child View Controller
        childViewController.removeFromParent()
    }
}

