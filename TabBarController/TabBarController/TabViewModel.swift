//
//  TabViewModel.swift
//  TabBarController
//
//  Created by Zheng on 10/30/21.
//

import SwiftUI

class TabViewModel: ObservableObject {
    @Published var activeTab = TabType.camera

}

enum TabType: String {
    case photos = "Photos"
    case camera = "Camera"
    case lists = "Lists"
}


/// grouping of all visual properties, for setting active/inactive
/// also for animations
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
    var backgroundHeight: CGFloat
    
    /// length of circle
    var length: CGFloat
    var fillColor: Color
    var rimColor: Color
    var rimWidth: CGFloat
    
    
    static let inactive: CameraAttributes = {
        return CameraAttributes(
            backgroundHeight: 48,
            length: CGFloat(26),
            fillColor: UIColor.gray.color,
            rimColor: UIColor.darkGray.color,
            rimWidth: 1
        )
    }()
    
    static let active: CameraAttributes = {
        return CameraAttributes(
            backgroundHeight: 120,
            length: CGFloat(64),
            fillColor: UIColor.blue.color,
            rimColor: UIColor.purple.color,
            rimWidth: 6
        )
    }()
}

extension UIColor {
    var color: Color {
        return Color(self)
    }
}



