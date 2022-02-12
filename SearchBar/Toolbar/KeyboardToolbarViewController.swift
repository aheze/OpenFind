//
//  KeyboardToolbarViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

class KeyboardToolbarViewController: UIViewController {
    var searchViewModel: SearchViewModel
    var model: KeyboardToolbarViewModel
    var collectionViewModel: SearchCollectionViewModel
    
    init(
        searchViewModel: SearchViewModel,
        model: KeyboardToolbarViewModel,
        collectionViewModel: SearchCollectionViewModel
    ) {
        self.searchViewModel = searchViewModel
        self.model = model
        self.collectionViewModel = collectionViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        print("LOAD.")
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleHeight]
        
        let containerView = KeyboardToolbarView(
            searchViewModel: searchViewModel,
            model: model,
            collectionViewModel: collectionViewModel
        )
        let hostingController = UIHostingController(rootView: containerView)
        hostingController.view.frame = view.bounds
        hostingController.view.backgroundColor = .clear
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    /// return true if frame was reloaded
    func reloadFrame(keyboardShown: Bool) -> Bool {
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
