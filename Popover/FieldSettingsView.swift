//
//  FieldSettingsView.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct FieldSettingsConstants {
    static var sliderHeight = CGFloat(40)
    static var cornerRadius = CGFloat(12)
}

struct FieldSettingsView: View {
    @Binding var configuration: PopoverConfiguration.FieldSettings
    
    var body: some View {
        VStack(spacing: 0) {
            Text("WORD")
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 8, trailing: 12))
            
            Line()
            
            VStack(spacing: 10) {
                HStack {
                    Text("Default")
                    Spacer()
                    Image(systemName: "checkmark")
                }
                .foregroundColor(.white)
                .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 8, trailing: 12))
                .background(configuration.defaultColor.color)
                .cornerRadius(FieldSettingsConstants.cornerRadius)
                
                PaletteView()
                    .cornerRadius(FieldSettingsConstants.cornerRadius)
                
                OpacitySlider(value: $configuration.alpha, color: configuration.selectedColor)
                    .frame(height: FieldSettingsConstants.sliderHeight)
                    .cornerRadius(FieldSettingsConstants.cornerRadius)
            }
            .padding(12)
        }
        .frame(width: 180)
        .background(
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                Constants.tabBarDarkBackgroundColor.color.opacity(0.5)
            }
        )
        .cornerRadius(16)
    }
}

struct PaletteView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                PaletteButton(colorHex: 0xFF0000)
                PaletteButton(colorHex: 0xFFB100)
                PaletteButton(colorHex: 0xFFE600)
                PaletteButton(colorHex: 0x39DD00)
                PaletteButton(colorHex: 0x00AEEF)
                PaletteButton(colorHex: 0x0036FF)
            }
            .aspectRatio(6, contentMode: .fit)
            
            HStack(spacing: 0) {
                PaletteButton(colorHex: 0xFF7700)
                PaletteButton(colorHex: 0xFFD200)
                PaletteButton(colorHex: 0xE4FF43)
                PaletteButton(colorHex: 0x00FF93)
                PaletteButton(colorHex: 0x0091FF)
                PaletteButton(colorHex: 0x7A00FF)
            }
            .aspectRatio(6, contentMode: .fit)
        }
    }
}

struct PaletteButton: View {
    let colorHex: UInt
    //    var selectedColor
    var body: some View {
        Button {
            print("\(colorHex) pressed")
        } label: {
            UIColor(hex: colorHex).color
        }
    }
}

struct OpacitySlider: View {
    @Binding var value: CGFloat
    let color: UIColor
    
    var body: some View {
        
        GeometryReader { proxy in
            Color(UIColor.systemBackground).overlay(
                ZStack {
                    VStack(spacing: 0) {
                        ForEach(0..<6) { row in
                            HStack(spacing: 0) {
                                ForEach(0..<30) { column in
                                    
                                    let offset = row % 2 == 0 ? 1 : 0
                                    if (offset + column) % 2 == 0 {
                                        Color.clear
                                    } else {
                                        Color.black.opacity(0.15)
                                    }
                                }
                            }
                            .aspectRatio(30, contentMode: .fill)
                        }
                    }
                    
                    LinearGradient(colors: [.clear, color.color], startPoint: .leading, endPoint: .trailing)
                }
            )
            
            /// slider thumb
                .overlay(
                    Color.clear.overlay(
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(UIColor.systemBackground.color)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(color.withAlphaComponent(value).color)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(Color.white, lineWidth: 2)
                        }
                            .padding(6)
                            .frame(width: FieldSettingsConstants.sliderHeight, height: FieldSettingsConstants.sliderHeight)
                        
                        /// pin thumb to right of stretching `clear` container
                        , alignment: .trailing
                    )
                    /// set frame of stretching `clear` container
                        .frame(
                            width: FieldSettingsConstants.sliderHeight + value * (proxy.size.width - FieldSettingsConstants.sliderHeight)
                        )
                    , alignment: .leading)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            self.value = min(max(0, CGFloat(value.location.x / proxy.size.width)), 1)
                        }
                )
        }
    }
}

struct FieldSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FieldSettingsView(configuration: .constant(.init()))
            .previewLayout(.fixed(width: 250, height: 300))
    }
}
