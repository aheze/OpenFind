//
//  ViewController.swift
//  TabController
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class ViewController: UIViewController {
    
    lazy var photos: PhotosController = {
        return PhotosBridge.makeController()
    }()
    lazy var camera: CameraController = {
        return CameraBridge.makeController()
    }()
    lazy var lists: ListsController = {
        return ListsBridge.makeController()
    }()
    
    var toolbarViewModel: ToolbarViewModel!
    lazy var tabController: TabBarController<CameraToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
        toolbarViewModel = ToolbarViewModel()
        
        
        photos.viewController.activateSelectionToolbar = { [weak self] activate in
            guard let self = self else { return }
            if activate {
                withAnimation {
                    self.toolbarViewModel.toolbar = .photosSelection
                }
            } else {
                withAnimation {
                    self.toolbarViewModel.toolbar = .none
                }
            }
        }
        
        let tabController = TabControllerBridge.makeTabController(
            pageViewControllers: [photos.viewController, camera.viewController, lists.viewController],
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: camera.viewController.toolbar,
            photosSelectionToolbarView: photos.viewController.selectionToolbar,
            photosDetailToolbarView: photos.viewController.selectionToolbar,
            listsSelectionToolbarView: photos.viewController.selectionToolbar
        )
        
        tabController.delegate = self
        
        self.addChild(tabController.viewController, in: self.view)
        
        return tabController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load!")
        
        _ = tabController
    }
}

extension ViewController: TabBarControllerDelegate{
    
    func willBeginNavigatingTo(tab: TabState) {
        
    }
    
    func didFinishNavigatingTo(tab: TabState) {
        
    }
}
