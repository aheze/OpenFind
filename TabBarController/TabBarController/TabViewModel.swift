//
//  TabViewModel.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

enum TabType: String {
    case photos = "Photos"
    case camera = "Camera"
    case lists = "Lists"
}


/// grouping of all visual properties, for setting active/inactive
/// also for animations
struct PhotosAttributes {
    struct Inactive {
        var foregroundColor = UIColor.gray.color
        var backgroundHeight = CGFloat(48)
    }
    struct Active {
        var foregroundColor = UIColor.green.color
        var backgroundHeight = CGFloat(48)
    }
}

struct IconAttributes {
    var foregroundColor: Color
    var backgroundHeight: CGFloat
    
    struct Photos {
        static let inactive: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.gray.color,
                backgroundHeight: 48
            )
        }()
        
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.green.color,
                backgroundHeight: 48
            )
        }()
    }
    
    struct Lists {
        static let inactive: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.gray.color,
                backgroundHeight: 48
            )
        }()
        
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.yellow.color,
                backgroundHeight: 48
            )
        }()
    }
}

struct CameraAttributes {
    var fillColor: Color
    var rimColor: Color
    var length: CGFloat
    
    static let inactive: CameraAttributes = {
        return CameraAttributes(
            fillColor: UIColor.gray.color,
            rimColor: UIColor.darkGray.color,
            length: CGFloat(26)
        )
    }()
    
    static let active: CameraAttributes = {
        return CameraAttributes(
            fillColor: UIColor.blue.color,
            rimColor: UIColor.purple.color,
            length: CGFloat(58)
        )
    }()
}

struct ListsAttributes {
    struct Inactive {
        var foregroundColor = UIColor.gray.color
        var backgroundHeight = CGFloat(48)
    }
    struct Active {
        var foregroundColor = UIColor.yellow.color
        var backgroundHeight = CGFloat(48)
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
