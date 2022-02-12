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
        view.autoresizingMask = .flexibleHeight
        view.backgroundColor = .clear
        
        let containerView = WordsToolbarView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        let verticalPadding = CGFloat(12)
        let height = UIFont.preferredFont(forTextStyle: .body).lineHeight + verticalPadding * 2
        view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        
        print("Just loaded.")
        _ = reloadFrame(keyboardShown: model.keyboardShown)
    }
    
    /// return true if frame was reloaded
    func reloadFrame(keyboardShown: Bool) -> Bool {
        print("Reload. \(keyboardShown)")
        let currentHeight = view.frame.height
        let newHeight: CGFloat
        if keyboardShown {
            newHeight = 60
        } else {
            newHeight = 60 + Global.safeAreaInsets.bottom
        }
        
        let heightChanged = currentHeight != newHeight
        if heightChanged {
            view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: newHeight)
        }
        
        return heightChanged
    }
}
