//
//  KeyboardToolbarViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class WordsKeyboardToolbarViewController: UIViewController {
    
    var model: WordsKeyboardToolbarViewModel
    init(model: WordsKeyboardToolbarViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        
        let containerView = WordsToolbarView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
    }
}
