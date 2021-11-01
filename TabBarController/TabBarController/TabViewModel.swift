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
        
        /// when active tab is camera
        static let inactiveDarkBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.white.color,
                backgroundHeight: 48
            )
        }()
        
        static let inactiveLightBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x7e7e7e).color,
                backgroundHeight: 48
            )
        }()
        
        /// always light background
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x40C74D).color,
                backgroundHeight: 48
            )
        }()
    }
    
    struct Lists {
        static let inactiveDarkBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor.white.color,
                backgroundHeight: 48
            )
        }()
        
        static let inactiveLightBackground: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0x7e7e7e).color,
                backgroundHeight: 48
            )
        }()
        
        static let active: IconAttributes = {
            return IconAttributes(
                foregroundColor: UIColor(hex: 0xFFC600).color,
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
            fillColor: UIColor(hex: 0x7e7e7e).withAlphaComponent(0.5).color,
            rimColor: UIColor(hex: 0x7e7e7e).color,
            rimWidth: 1
        )
    }()
    
    static let active: CameraAttributes = {
        return CameraAttributes(
            backgroundHeight: 98,
            length: CGFloat(64),
            fillColor: UIColor(hex: 0x00aeef).withAlphaComponent(0.5).color,
            rimColor: UIColor.white.color,
            rimWidth: 3
        )
    }()
}

extension UIColor {
    var color: Color {
        return Color(self)
    }
}



