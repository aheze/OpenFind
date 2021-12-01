//
//  ToolbarViewModel.swift
//  TabBarController
//
//  Created by Zheng on 11/12/21.
//

import SwiftUI


class ToolbarViewModel: ObservableObject {
    @Published var toolbar = Toolbar.none
    var cameraModel = Camera()
    
    init() { }
    
    enum Toolbar {
        case none
        case photosSelection
        case photosDetail
        case listsSelection
    }
    
    class Camera: ObservableObject {
        @Published var resultsCount = 0
        @Published var shutterPaused = false
        @Published var flashOn = false
        @Published var focusOn = false
        init() { }
        
    }
    class PhotosSelection: ObservableObject {
        @Published var selectedCount = 0
        @Published var starOn = false
        init() { }
    }
    class PhotosDetail: ObservableObject {
        @Published var starOn = false
        @Published var infoOn = false
        init() { }
    }
    class ListsSelection: ObservableObject {
        @Published var selectedCount = 0
        init() { }
    }
}
