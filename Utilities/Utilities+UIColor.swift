//
//  Utilities+UIColor.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

extension UIColor {
    var color: Color {
        return Color(self)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    var hex: UInt {
        return getHex() ?? 0x00AEEF
    }

    /// from https://stackoverflow.com/a/28645384/14351818
    func getHex() -> UInt? {
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        var fAlpha: CGFloat = 0
        if getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = UInt(fRed * 255.0)
            let iGreen = UInt(fGreen * 255.0)
            let iBlue = UInt(fBlue * 255.0)
            let iAlpha = UInt(fAlpha * 255.0)

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let hex = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return hex
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

/// from https://stackoverflow.com/a/46729248/14351818
extension UIColor {
    func toColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 1), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }

            return UIColor(
                red: CGFloat(r1 + (r2 - r1) * percentage),
                green: CGFloat(g1 + (g2 - g1) * percentage),
                blue: CGFloat(b1 + (b2 - b1) * percentage),
                alpha: CGFloat(a1 + (a2 - a1) * percentage)
            )
        }
    }
}

/// get gradient color for search bar field
extension UIColor {
    func getFieldColor(for index: Int) -> UIColor {
        let gradation = CGFloat(1) / 15
        let offset = gradation * CGFloat(index)
        return self.offset(by: offset)
    }

    var rgb: (r: CGFloat, g: CGFloat, b: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r: r, g: g, b: b)
        } else {
            return (0, 0, 0)
        }
    }

    var hsba: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return (h: h, s: s, b: b, a: a)
    }

    /// get a gradient color
    func offset(by offset: CGFloat) -> UIColor {
        let (h, s, b, a) = hsba
        var newHue = h - offset

        /// make it go back to positive
        while newHue <= 0 {
            newHue += 1
        }
        let normalizedHue = newHue.truncatingRemainder(dividingBy: 1)
        return UIColor(hue: normalizedHue, saturation: s, brightness: b, alpha: a)
    }

    /// darken or lighten
    func adjust(by offset: CGFloat) -> UIColor {
        let (r, g, b) = rgb
        let newR = r + offset
        let newG = g + offset
        let newB = b + offset

        return UIColor(red: newR, green: newG, blue: newB, alpha: 1)
    }
}

extension UIColor {
    static func == (l: UIColor, r: UIColor) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        l.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        r.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let precision = 4
        r1 = Double(r1).rounded(toPlaces: precision)
        g1 = Double(g1).rounded(toPlaces: precision)
        b1 = Double(b1).rounded(toPlaces: precision)

        r2 = Double(r2).rounded(toPlaces: precision)
        g2 = Double(g2).rounded(toPlaces: precision)
        b2 = Double(b2).rounded(toPlaces: precision)

        return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2
    }
}

func == (l: UIColor?, r: UIColor?) -> Bool {
    let l = l ?? .clear
    let r = r ?? .clear
    return l == r
}

extension UIColor {
    var isLight: Bool {
        let threshold = CGFloat(0.55)
        let (r, g, b) = rgb
        let brightness = CGFloat(
            ((r * 299) + (g * 587) + (b * 114)) / 1000
        )
        return (brightness > threshold)
    }
}
