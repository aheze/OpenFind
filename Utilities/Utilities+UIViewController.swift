//
//  Utilities+UIViewController.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension UIViewController {
    func addChildViewController(_ childViewController: UIViewController, in inView: UIView) {
        /// Add Child View Controller
        addChild(childViewController)
        
        /// Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        /// Configure Child View
        childViewController.view.frame = inView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        /// Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    
    func addChildViewControllerWithConstraints(_ childViewController: UIViewController, in inView: UIView) {
        /// Add Child View Controller
        addChild(childViewController)
        
        /// Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        /// Configure Child View
        childViewController.view.pinEdgesToSuperview()
        
        /// Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    
    func addResizableChildViewController(_ childViewController: UIViewController, in inView: UIView) {
        /// Add Child View Controller
        addChild(childViewController)
        
        /// Add Child View as Subview
        inView.insertSubview(childViewController.view, at: 0)
        
        /// Configure Child View
        childViewController.view.frame = inView.bounds
        
        /// Make the parent view's hug the bounds of the child view
        inView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: inView.topAnchor),
            childViewController.view.rightAnchor.constraint(equalTo: inView.rightAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: inView.bottomAnchor),
            childViewController.view.leftAnchor.constraint(equalTo: inView.leftAnchor)
        ])

        /// Notify Child View Controller
        childViewController.didMove(toParent: self)
    }
    
    func removeChildViewController(_ childViewController: UIViewController) {
        /// Notify Child View Controller
        childViewController.willMove(toParent: nil)

        /// Remove Child View From Superview
        childViewController.view.removeFromSuperview()

        /// Notify Child View Controller
        childViewController.removeFromParent()
    }
}

extension UIViewController {
    func presentShareSheet(items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(origin: self.view.center, size: CGSize(width: 1, height: 1))
            popoverController.sourceView = self.view
        }

        self.present(activityViewController, animated: true)
    }
}
