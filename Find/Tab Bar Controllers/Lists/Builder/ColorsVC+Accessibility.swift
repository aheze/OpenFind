//
//  ColorsVC+Accessibility.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension String {
    func getDescription() -> String {
        var colorName = ""
        
        switch self {
        case "#eb2f06":
            colorName = "red"
        case "#e55039":
            colorName = "mahogany"
        case "#f7b731":
            colorName = "dark yellow"
        case "#fed330":
            colorName = "yellow"
        case "#78e08f":
            colorName = "light green"
        case "#fc5c65":
            colorName = "strawberry"
        case "#fa8231":
            colorName = "orange"
        case "#b8e994":
            colorName = "mint green"
        case "#2bcbba":
            colorName = "teal"
        case "#ff6348":
            colorName = "red-orange"
        case "#b71540":
            colorName = "dark red"
        case "#579f2b":
            colorName = "dark green"
        case "#d1d8e0":
            colorName = "light gray"
        case "#778ca3":
            colorName = "dark gray"
        case "#e84393":
            colorName = "magenta"
        case "#a55eea":
            colorName = "purple"
        case "#5352ed":
            colorName = "indigo"
        case "#70a1ff":
            colorName = "cornflower blue"
        case "#40739e":
            colorName = "navy blue"
        case "#45aaf2":
            colorName = "light blue"
        case "#2d98da":
            colorName = "dark blue"
        case "#00aeef":
            colorName = "Find blue"
        case "#4b6584":
            colorName = "blue-gray"
        case "#0a3d62":
            colorName = "midnight blue"
        default:
            colorName = "Color"
        }
        
        return colorName
    }
}
extension UIColor {
    func whichColor() -> String {
        
        var (h, s, b, a) : (CGFloat, CGFloat, CGFloat, CGFloat) = (0,0,0,0)
        _ = self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        print("HSB range- h: \(h), s: \(s), v: \(b)")
        
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

