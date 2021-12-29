//
//  TabControllerBridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//

import SwiftUI

struct TabControllerBridge {
    static func makeTabController<PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>(
        pageViewControllers: [PageViewController],
        cameraViewModel: CameraViewModel,
        toolbarViewModel: ToolbarViewModel,
        photosSelectionToolbarView: PhotosSelectionToolbarView,
        photosDetailToolbarView: PhotosDetailToolbarView,
        listsSelectionToolbarView: ListsSelectionToolbarView
    ) -> TabBarController<PhotosSelectionToolbarView, PhotosDetailToolbarView, ListsSelectionToolbarView> {
        let tabBarController = TabBarController(
            pages: pageViewControllers,
            cameraViewModel: cameraViewModel,
            toolbarViewModel: toolbarViewModel,
            photosSelectionToolbarView: photosSelectionToolbarView,
            photosDetailToolbarView: photosDetailToolbarView,
            listsSelectionToolbarView: listsSelectionToolbarView
        )
        
        return tabBarController
    }
}
