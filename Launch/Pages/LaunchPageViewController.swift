//
//  LaunchPageViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

class LaunchPageViewController: UIViewController {
    var model: LaunchViewModel
    var pageViewModel: LaunchPageViewModel
    
    init(
        model: LaunchViewModel,
        identifier: LaunchPage
    ) {
        self.model = model
        let pageViewModel = LaunchPageViewModel(identifier: identifier)
        self.pageViewModel = pageViewModel
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
        
        let contentView = LaunchPageView(model: model, pageViewModel: pageViewModel)
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
