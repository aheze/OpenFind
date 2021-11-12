//
//  Bridge.swift
//  TabBarController
//
//  Created by Zheng on 10/28/21.
//


import SwiftUI

public struct Bridge {
    public static func makeTabViewController<ToolbarViewModel: ObservableObject, CameraToolbarView: View, PhotosSelectionToolbarView: View, PhotosDetailToolbarView: View, ListsSelectionToolbarView: View>(
        pageViewControllers: [PageViewController],
        toolbarViewModel: ToolbarViewModel,
        cameraToolbarView: CameraToolbarView,
        photosSelectionToolbarView: PhotosSelectionToolbarView,
        photosDetailToolbarView: PhotosDetailToolbarView,
        listsSelectionToolbarView: ListsSelectionToolbarView
    ) -> TabBarController<ToolbarViewModel, CameraToolbarView, PhotosSelectionToolbarView, PhotosDetailToolbarView, ListsSelectionToolbarView> {
        
        let toolbarController = TabBarController(
            pages: pageViewControllers,
            toolbarViewModel: toolbarViewModel,
            cameraToolbarView: cameraToolbarView,
            photosSelectionToolbarView: photosSelectionToolbarView,
            photosDetailToolbarView: photosDetailToolbarView,
            listsSelectionToolbarView: listsSelectionToolbarView
        )
        
        return toolbarController
    }
}
