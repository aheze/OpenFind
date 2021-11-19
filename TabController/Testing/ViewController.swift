//
//  ViewController.swift
//  TabController
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var photos: PhotosController = {
        return Photos.Bridge.makeController()
    }()
    lazy var camera: CameraController = {
        return Camera.Bridge.makeController()
    }()
    lazy var lists: ListsController = {
        return Lists.Bridge.makeController()
    }()
    
    var toolbarViewModel: ToolbarViewModel!
    lazy var tabController: TabBarController<Camera.CameraToolbarView, Photos.PhotosSelectionToolbarView, PhotosSelectionToolbarView, PhotosSelectionToolbarView> = {
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
        
        let tabController = Bridge.makeTabController(
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
        
        view.backgroundColor = .green
    }
}
