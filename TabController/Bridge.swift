//
//  Bridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//


import SwiftUI

public struct Bridge {
    public static func makeTabController<CameraToolbarView: View, PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>(
        pageViewControllers: [PageViewController],
        toolbarViewModel: ToolbarViewModel,
        cameraToolbarView: CameraToolbarView,
        photosSelectionToolbarView: PhotosSelectionToolbarView,
        photosDetailToolbarView: PhotosDetailToolbarView,
        listsSelectionToolbarView: ListsSelectionToolbarView
    ) -> TabBarController<CameraToolbarView, PhotosSelectionToolbarView, PhotosDetailToolbarView, ListsSelectionToolbarView> {
        
        let tabBarController = TabBarController(
            pages: pageViewControllers,
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: cameraToolbarView,
            photosSelectionToolbarView: photosSelectionToolbarView,
            photosDetailToolbarView: photosDetailToolbarView,
            listsSelectionToolbarView: listsSelectionToolbarView
        )
        
        return tabBarController
    }
}
