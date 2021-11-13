//
//  ToolbarViewModel.swift
//  TabBarController
//
//  Created by Zheng on 11/12/21.
//

import SwiftUI


public class ToolbarViewModel: ObservableObject {
    @Published public var toolbar = Toolbar.none
    
    public init() { }
    
    public enum Toolbar {
//        case none
//        case photosSelection(PhotosSelection)
//        case photosDetail(PhotosDetail)
//        case listsSelection(ListsSelection)
        case none
        case photosSelection
        case photosDetail
        case listsSelection
    }
    
    public class Camera: ObservableObject {
        @Published public var resultsCount = 0
        @Published public var flashOn = false
        @Published public var focusOn = false
        public init() { }
    }
    public class PhotosSelection: ObservableObject {
        @Published public var selectedCount = 0
        @Published public var starOn = false
        public init() { }
    }
    public class PhotosDetail: ObservableObject {
        @Published public var starOn = false
        @Published public var infoOn = false
        public init() { }
    }
    public class ListsSelection: ObservableObject {
        @Published public var selectedCount = 0
        public init() { }
    }
}
