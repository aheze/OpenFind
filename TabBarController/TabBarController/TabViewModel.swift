//
//  TabViewModel.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

enum TabType {
    case photos
    case camera
    case lists
    
//    var visualAttributes: TabIconVisualAttributes {
//        switch self {
//        case .photos:
//            return .photos(.init())
//        case .camera:
//            return .camera(.init())
//        case .lists:
//            return .lists(.init())
//        }
//    }
}


/// grouping of all visual properties, for setting active/inactive
/// also for animations
//enum TabIconVisualAttributes {
//    case photos(PhotosAttributes)
//    case camera(CameraAttributes)
//    case lists(ListsAttributes)
    
    struct PhotosAttributes {
        var inactiveForegroundColor = UIColor.gray
        var activeForegroundColor = UIColor.green
        var imageName = "Photos"
    }
    
    struct CameraAttributes {
        var inactiveFillColor = UIColor.gray
        var inactiveRimColor = UIColor.darkGray
        var inactiveLength = CGFloat(26)
        
        var activeFillColor = UIColor.blue
        var activeRimColor = UIColor.purple
        var activeLength = CGFloat(58)
    }
    
    struct ListsAttributes {
        var inactiveForegroundColor = UIColor.gray
        var activeForegroundColor = UIColor.yellow
        var imageName = "Lists"
    }
//}

extension UIColor {
    var color: Color {
        return Color(self)
    }
}


class TabViewModel: ObservableObject {
    @Published var activeTab = TabType.camera
}
