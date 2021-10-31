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
struct PhotosAttributes {
    struct Inactive {
        var foregroundColor = UIColor.gray.color
    }
    struct Active {
        var foregroundColor = UIColor.green.color
    }
}

struct CameraAttributes {
    struct Inactive {
        var fillColor = UIColor.gray.color
        var rimColor = UIColor.darkGray.color
        var length = CGFloat(26)
    }
    struct Active {
        var fillColor = UIColor.blue.color
        var rimColor = UIColor.purple.color
        var length = CGFloat(58)
    }
}

struct ListsAttributes {
    struct Inactive {
        var foregroundColor = UIColor.gray.color
    }
    struct Active {
        var foregroundColor = UIColor.yellow.color
    }
}

extension UIColor {
    var color: Color {
        return Color(self)
    }
}


class TabViewModel: ObservableObject {
    @Published var activeTab = TabType.camera
}
