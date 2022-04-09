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
    var realmModel: RealmModel
    var model: KeyboardToolbarViewModel
    var collectionViewModel: SearchCollectionViewModel
    
    init(
        searchViewModel: SearchViewModel,
        realmModel: RealmModel,
        model: KeyboardToolbarViewModel,
        collectionViewModel: SearchCollectionViewModel
    ) {
        self.searchViewModel = searchViewModel
        self.realmModel = realmModel
        self.model = model
        self.collectionViewModel = collectionViewModel
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
        view.autoresizingMask = .flexibleHeight
        view.backgroundColor = .clear
        
        let containerView = KeyboardToolbarView(
            searchViewModel: searchViewModel,
            realmModel: realmModel,
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
        
        _ = reloadFrame()
    }
    
    /// return true if frame was reloaded
    func reloadFrame() -> Bool {
        let currentHeight = view.frame.height
        let newHeight: CGFloat
        if collectionViewModel.keyboardShown {
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
