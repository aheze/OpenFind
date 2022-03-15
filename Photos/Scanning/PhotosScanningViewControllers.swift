//
//  PhotosScanningViewControllers.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/18/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

/**
 Wrappers for the scanning icon / view controller
 */

class PhotosScanningViewController: UIViewController {
    var model: PhotosViewModel
    init(model: PhotosViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        self.title = "Scanning Photos"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(dismissSelf), imageName: "Dismiss")
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        
        let containerView = PhotosScanningView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.view.backgroundColor = .secondarySystemBackground

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }
    
    func presentIgnoredPhotosViewController() {
        
    }
}

class PhotosScanningIconController: UIViewController {
    var model: PhotosViewModel
    init(model: PhotosViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let containerView = PhotosScanningIcon(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

    }
}
