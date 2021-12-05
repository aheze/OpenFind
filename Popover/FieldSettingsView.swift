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
    
    @ObservedObject var model: FieldSettingsModel
    @Binding var stopDraggingGesture: Bool
    
    var body: some View {
        let _ = print("go: \(model.configuration)")
        VStack(spacing: 0) {
            Button {
                if model.configuration.showingWords {
                    withAnimation {
                        model.configuration.showingWords = false
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    if model.configuration.showingWords {
                        Image(systemName: "chevron.backward")
                    }
                    
                    Text(model.configuration.header)
                }
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .semibold))
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
            }
            .disabled(!model.configuration.showingWords)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
            
            Line()
            
            
            /// main content
            VStack(spacing: 10) {
                VStack(spacing: 10) {
                    Button {
                        withAnimation {
                            model.configuration.selectedColor = model.configuration.defaultColor
                        }
                    } label: {
                        HStack {
                            Text("Default")
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(model.configuration.defaultColor == model.configuration.selectedColor ? 1 : 0)
                        }
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                        .modifier(PopoverButtonModifier(backgroundColor: model.configuration.defaultColor))
                    }
                    
                    
                    PaletteView(selectedColor: $model.configuration.selectedColor)
                        .cornerRadius(FieldSettingsConstants.cornerRadius)
                    
                    OpacitySlider(value: $model.configuration.alpha, stopDraggingGesture: $stopDraggingGesture, color: model.configuration.selectedColor)
                        .frame(height: FieldSettingsConstants.sliderHeight)
                        .cornerRadius(FieldSettingsConstants.cornerRadius)
                }
                .padding(.horizontal, 12)
                
                if !model.configuration.words.isEmpty {
                    Line()
                    
                    VStack {
                        Button {
                            withAnimation {
                                model.configuration.showingWords = true
                            }
                        } label: {
                            Text("Show Words")
                                .modifier(PopoverButtonModifier(backgroundColor: PopoverConstants.buttonColor))
                            
                        }
                        
                        if let editListPressed = model.configuration.editListPressed {
                            Button {
                                editListPressed()
                            } label: {
                                Text("Edit List")
                                    .modifier(PopoverButtonModifier(backgroundColor: PopoverConstants.buttonColor))
                                
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.top, 10)
            .offset(x: model.configuration.showingWords ? -180 : 0, y: 0)
            .opacity(model.configuration.showingWords ? 0 : 1)
            .background(
                ScrollView {
                    VStack {
                        ForEach(model.configuration.words, id: \.self) { word in
                            let _ = print("word: \(word)")
                            Text(verbatim: word)
                                .modifier(PopoverButtonModifier(backgroundColor: PopoverConstants.buttonColor))
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 12)
                }
                    .offset(x: model.configuration.showingWords ? 0 : 180, y: 0)
                    .opacity(model.configuration.showingWords ? 1 : 0)
                , alignment: .top)
        }
        .padding(.bottom, 12)
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



struct PopoverButtonModifier: ViewModifier {
    var backgroundColor: UIColor
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 12, bottom: 8, trailing: 12))
            .background(backgroundColor.color)
            .cornerRadius(FieldSettingsConstants.cornerRadius)
    }
}


struct PaletteView: View {
    @Binding var selectedColor: UIColor
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                PaletteButton(color: UIColor(hex: 0xFF0000), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFB100), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFE600), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x39DD00), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x00AEEF), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x0036FF), selectedColor: $selectedColor)
            }
            .aspectRatio(6, contentMode: .fit)
            
            HStack(spacing: 0) {
                PaletteButton(color: UIColor(hex: 0xFF7700), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xFFD200), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0xE4FF43), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x00FF93), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x0091FF), selectedColor: $selectedColor)
                PaletteButton(color: UIColor(hex: 0x7A00FF), selectedColor: $selectedColor)
            }
            .aspectRatio(6, contentMode: .fit)
        }
    }
}

struct PaletteButton: View {
    let color: UIColor
    @Binding var selectedColor: UIColor
    var body: some View {
        Button {
            withAnimation {
                selectedColor = color
            }
        } label: {
            color.color
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .shadow(color: Color.black.opacity(0.25), radius: 3, x: 0, y: 1)
                        .opacity(color == selectedColor ? 1 : 0)
                )
        }
    }
}

struct OpacitySlider: View {
    @Binding var value: CGFloat
    @Binding var stopDraggingGesture: Bool
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
                                        UIColor.label.color.opacity(0.15)
                                    }
                                }
                            }
                            .aspectRatio(30, contentMode: .fill)
                        }
                    }
                    
                    LinearGradient(colors: [.clear, .white], startPoint: .leading, endPoint: .trailing)
                        .colorMultiply(color.color)
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
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            self.value = min(max(0, CGFloat(value.location.x / proxy.size.width)), 1)
                            stopDraggingGesture = true
                        }
                        .onEnded { _ in stopDraggingGesture = false }
                )
        }
        .drawingGroup() /// prevent thumb from disappearing when offset to show words
    }
}

//struct FieldSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        FieldSettingsView(configuration: .constant(.init()), stopDraggingGesture: .constant(false))
//            .previewLayout(.fixed(width: 250, height: 300))
//    }
//}
