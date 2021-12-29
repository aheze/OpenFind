//
//  ColorsVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension String {
    func getDescription() -> (String, Double) {
        var colorName = ""
        var pitch = 0.0
        
        switch self {
        case "#eb2f06":
            colorName = "red"
            pitch = 0.08
        case "#e55039":
            colorName = "mahogany"
            pitch = 0.16
        case "#f7b731":
            colorName = "dark yellow"
            pitch = 0.24
        case "#fed330":
            colorName = "yellow"
            pitch = 0.32
        case "#78e08f":
            colorName = "light green"
            pitch = 0.4
        case "#fc5c65":
            colorName = "strawberry"
            pitch = 0.48
        case "#fa8231":
            colorName = "orange"
            pitch = 0.56
        case "#b8e994":
            colorName = "mint green"
            pitch = 0.64
        case "#2bcbba":
            colorName = "teal"
            pitch = 0.72
        case "#ff6348":
            colorName = "red-orange"
            pitch = 0.8
        case "#b71540":
            colorName = "dark red"
            pitch = 0.88
        case "#00aeef":
            colorName = "Find blue"
            pitch = 0.96
        case "#579f2b":
            colorName = "dark green"
            pitch = 1.04
        case "#778ca3":
            colorName = "dark gray"
            pitch = 1.12
        case "#e84393":
            colorName = "magenta"
            pitch = 1.2
        case "#a55eea":
            colorName = "purple"
            pitch = 1.28
        case "#5352ed":
            colorName = "indigo"
            pitch = 1.36
        case "#70a1ff":
            colorName = "cornflower blue"
            pitch = 1.44
        case "#40739e":
            colorName = "navy blue"
            pitch = 1.52
        case "#45aaf2":
            colorName = "light blue"
            pitch = 1.6
        case "#2d98da":
            colorName = "dark blue"
            pitch = 1.68
        case "#d1d8e0":
            colorName = "light gray"
            pitch = 1.76
        case "#4b6584":
            colorName = "blue-gray"
            pitch = 1.84
        case "#0a3d62":
            colorName = "midnight blue"
            pitch = 1.92
        default:
            colorName = "Color"
        }
        
        return (colorName, pitch)
    }
}
extension UIColor {
    func whichColor() -> String {
        
        var (h, s, b, a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        _ = self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        

        
        var colorTitle = ""
        
        switch (h, s, b) {
        
        // red
        case (0...0.138, 0.88...1.00, 0.75...1.00):
            colorTitle = "red"
        // yellow
        case (0.139...0.175, 0.30...1.00, 0.80...1.00):
            colorTitle = "yellow"
        // green
        case (0.176...0.422, 0.30...1.00, 0.60...1.00):
            colorTitle = "green"
        // teal
        case (0.423...0.494, 0.30...1.00, 0.54...1.00):
            colorTitle = "teal"
        // blue
        case (0.495...0.667, 0.30...1.00, 0.60...1.00):
            colorTitle = "blue"
        // purple
        case (0.668...0.792, 0.30...1.00, 0.40...1.00):
            colorTitle = "purple"
        // pink
        case (0.793...0.977, 0.30...1.00, 0.80...1.00):
            colorTitle = "pink"
        // brown
        case (0...0.097, 0.50...1.00, 0.25...0.58):
            colorTitle = "brown"
        // white
        case (0...1.00, 0...0.05, 0.95...1.00):
            colorTitle = "white"
        // grey
        case (0...1.00, 0, 0.25...0.94):
            colorTitle = "grey"
        // black
        case (0...1.00, 0...1.00, 0...0.07):
            colorTitle = "black"
        default:
            colorTitle = "Color didn't fit defined ranges..."
        }
        
        return colorTitle
    }
}

