//
//  GeneralView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct GeneralView: View {
    var body: some View {
        DefaultColorView()
    }
}

struct DefaultColorView: View {
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
            VStack(spacing: 0) {
                HeaderView(text: "Default Highlight Color")
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RectangleButton(color: .customRed)
                        RectangleButton(color: .customOrange)
                        RectangleButton(color: .customYellow)
                        RectangleButton(color: .customGreen)
                        RectangleButton(color: .customBlue)
                        RectangleButton(color: .customDarkBlue)
                        RectangleButton(color: .customPurple)
                        RectangleButton(color: .customMagenta)
                    }
                    HStack(spacing: 0) {
                        RectangleButton(color: .customSalmon)
                        RectangleButton(color: .customYellorange)
                        RectangleButton(color: .customLime)
                        RectangleButton(color: .customNeon)
                        RectangleButton(color: .customLightBlue)
                        RectangleButton(color: .customMediumBlue)
                        RectangleButton(color: .customLightPurple)
                        RectangleButton(color: .customPink)
                    }
                }
            }
        }.cornerRadius(12)
    }
}
struct RectangleButton: View {
    var color: String
    var body: some View {
        Button(action: {
            UserDefaults.standard.set(color, forKey: "highlightColor")
        }) {
            Rectangle()
                .foregroundColor(Color(UIColor(hexString: color)))
                .aspectRatio(1.0, contentMode: .fit)
        }
    }
}
