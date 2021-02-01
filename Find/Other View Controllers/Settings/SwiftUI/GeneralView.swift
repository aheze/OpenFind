//
//  GeneralView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct GeneralView: View {
    @Binding var selectedHighlightColor: String
    var body: some View {
        DefaultColorView(selectedColor: $selectedHighlightColor)
    }
}

struct DefaultColorView: View {
    @Binding var selectedColor: String
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
            VStack(spacing: 0) {
                HeaderView(text: "Default Highlight Color")
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        RectangleButton(selectedColor: $selectedColor, color: .customRed)
                        RectangleButton(selectedColor: $selectedColor, color: .customOrange)
                        RectangleButton(selectedColor: $selectedColor, color: .customYellow)
                        RectangleButton(selectedColor: $selectedColor, color: .customGreen)
                        RectangleButton(selectedColor: $selectedColor, color: .customBlue)
                        RectangleButton(selectedColor: $selectedColor, color: .customDarkBlue)
                        RectangleButton(selectedColor: $selectedColor, color: .customPurple)
                        RectangleButton(selectedColor: $selectedColor, color: .customMagenta)
                    }
                    HStack(spacing: 0) {
                        RectangleButton(selectedColor: $selectedColor, color: .customSalmon)
                        RectangleButton(selectedColor: $selectedColor, color: .customYellorange)
                        RectangleButton(selectedColor: $selectedColor, color: .customLime)
                        RectangleButton(selectedColor: $selectedColor, color: .customNeon)
                        RectangleButton(selectedColor: $selectedColor, color: .customLightBlue)
                        RectangleButton(selectedColor: $selectedColor, color: .customMediumBlue)
                        RectangleButton(selectedColor: $selectedColor, color: .customLightPurple)
                        RectangleButton(selectedColor: $selectedColor, color: .customPink)
                    }
                }
            }
        }.cornerRadius(12)
    }
}
struct RectangleButton: View {
    @Binding var selectedColor: String
    
    var color: String
    var body: some View {
        Button(action: {
//            Defaults.highlightColor = color
            print("setting, \(color)")
//            UserDefaults.standard.setValue(color, forKey: "highlightColor")
            selectedColor = color
        }) {
            Rectangle()
                .foregroundColor(Color(UIColor(hexString: color)))
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    (selectedColor.lowercased() == color.lowercased()) ? AnyView(
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(Font.system(size: 19, weight: .medium))
                    ) : AnyView(EmptyView())
                )
        }
    }
}
