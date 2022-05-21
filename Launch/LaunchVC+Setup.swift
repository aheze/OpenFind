//
//  LaunchVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension LaunchViewController {
    func setup() {
        /// view setup
        activityIndicator.alpha = 0
        sceneContainer.alpha = 0
        sceneContainer.backgroundColor = .clear
        contentContainer.backgroundColor = .clear
        view.backgroundColor = Colors.accentDarkBackground
        
        listen()
        
        model.sceneType = .swiftUI
        
        /// SwiftUI overlay
        setupView()
        
        switch model.sceneType {
        case .realityKit:
            setupRealityKit()
        case .swiftUI:
            setupSwiftUI()
        case .none:
            setupSwiftUI() /// fallback
        }
    }
    
    func setupRealityKit() {
        activityIndicatorTopC.constant = 50
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.alpha = 1
        }
        
        if Debug.skipLaunchIntro {
            showUI()
        } else {
            /// need a bit of delay to ensure activity indicator showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.31) {
                self.setupRealityKitScene()
            }
        }
    }
    
    func setupSwiftUI() {
        let launchSceneModel = LaunchSceneModel()
        let contentView = LaunchSceneView(model: model, launchSceneModel: launchSceneModel)
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: sceneContainer)
        
        UIView.animate(withDuration: 0.5) {
            self.sceneContainer.alpha = 1
            self.imageView.alpha = 0
            self.activityIndicator.alpha = 0
        }
        
        showUI()
        
        launchSceneModel.entering = { [weak self] in
            self?.hideBackground()
        }
        
        launchSceneModel.done = { [weak self] in
            self?.finish()
        }
    }
}
