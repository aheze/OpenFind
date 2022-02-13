//
//  FieldSettingsView.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import Popovers
import SwiftUI

class FieldSettingsModel: ObservableObject {
    @Published var header = "WORD"
    @Published var defaultColor: UIColor = .init(hex: 0x00AEEF)
    @Published var selectedColor: UIColor?
    @Published var alpha: CGFloat = 1
    
    /// lists
    @Published var words = [String]()
    @Published var editListPressed: (() -> Void)?
    
    /// Notify when the class changed.
    public var changeSink: AnyCancellable?
    var changed: (() -> Void)?
    public init() {
        changeSink = objectWillChange.sink { [weak self] in
            DispatchQueue.main.async {
                self?.changed?()
            }
        }
    }
}

enum FieldSettingsConstants {
    static var sliderHeight = CGFloat(40)
    static var cornerRadius = CGFloat(12)
    
    /// padding outside all items
    static var padding = CGFloat(12)
    
    /// space between items
    static var spacing = CGFloat(10)
    static var buttonColor = UIColor(hex: 0x005278)
}

struct FieldSettingsView: View {
    @ObservedObject var model: FieldSettingsModel
    var configuration: SearchConfiguration
    
    var body: some View {
        VStack(spacing: 0) {
            PopoverReader { context in
                header(string: model.header)
            
                Line(color: configuration.popoverDividerColor)
            
                FieldSettingsContainer {
                    Button {
                        withAnimation {
                            model.selectedColor = nil
                        }
                    } label: {
                        HStack {
                            Text("Default")
                            Spacer()
                            Image(systemName: "checkmark")
                                .opacity(model.selectedColor == nil ? 1 : 0)
                        }
                        .asPopoverButton(foregroundColor: defaultButtonForegroundColor(), backgroundColor: model.defaultColor)
                    }
                    
                    PaletteView(selectedColor: $model.selectedColor)
                        .cornerRadius(FieldSettingsConstants.cornerRadius)
                    
                    OpacitySlider(value: $model.alpha, color: model.selectedColor ?? model.defaultColor)
                        .frame(height: FieldSettingsConstants.sliderHeight)
                        .cornerRadius(FieldSettingsConstants.cornerRadius)
                }
                
                listsView()
                    
//                .overlay(
//                    ScrollView {
//                        FieldSettingsContainer {
//                            ForEach(model.words, id: \.self) { word in
//                                Text(verbatim: word)
//                                    .modifier(PopoverButtonModifier(backgroundColor: FieldSettingsConstants.buttonColor))
//                            }
//                        }
//                    }
//                    alignment: .top
//                )
            }
        }
        .frame(width: 180)
        .background(
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: configuration.popoverBackgroundBlurStyle))
                configuration.popoverBackgroundColor.color.opacity(0.25)
            }
        )
        .cornerRadius(16)
    }
    
    func header(string: String, showEditListButton: Bool = false) -> some View {
        HStack {
            Text(string)
            
            if showEditListButton {
                Spacer()
                
                Button {
                    model.editListPressed?()
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .foregroundColor(configuration.popoverTextColor.color)
        .font(.system(size: 12, weight: .semibold))
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 10)
    }
    
    func listsView() -> some View {
        VStack(spacing: 0) {
            Line(color: configuration.popoverDividerColor)
            
            header(string: "WORDS", showEditListButton: true)
            
            ScrollView {
                FieldSettingsContainer(applyPadding: false) {
                    ForEach(model.words, id: \.self) { word in
                        Text(verbatim: word)
                            .asPopoverButton(foregroundColor: configuration.popoverTextColor, backgroundColor: configuration.popoverButtonColor)
                    }
                }
                .padding(EdgeInsets(top: 0, leading: FieldSettingsConstants.padding, bottom: FieldSettingsConstants.padding, trailing: FieldSettingsConstants.padding))
            }
        }
        .clipped()
        .opacity(model.words.isEmpty ? 0 : 1)
        .frame(height: model.words.isEmpty ? 0 : 200, alignment: .top)
    }
    
    func defaultButtonForegroundColor() -> UIColor {
        if model.defaultColor.isLight {
            return .black
        } else {
            return .white
        }
    }
}

struct FieldSettingsContainer<Content: View>: View {
    var applyPadding = true
    @ViewBuilder var content: Content
    var body: some View {
        if applyPadding {
            VStack(spacing: FieldSettingsConstants.spacing) {
                content
            }
            .padding(FieldSettingsConstants.padding)
        } else {
            VStack(spacing: FieldSettingsConstants.spacing) {
                content
            }
        }
    }
}

struct PopoverButtonModifier: ViewModifier {
    var foregroundColor: UIColor
    var backgroundColor: UIColor
    func body(content: Content) -> some View {
        content
            .foregroundColor(foregroundColor.color)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 10, leading: 12, bottom: 8, trailing: 12))
            .background(backgroundColor.color)
            .cornerRadius(FieldSettingsConstants.cornerRadius)
    }
}

extension View {
    func asPopoverButton(foregroundColor: UIColor, backgroundColor: UIColor) -> some View {
        modifier(PopoverButtonModifier(foregroundColor: foregroundColor, backgroundColor: backgroundColor))
    }
}

struct PaletteView: View {
    @Binding var selectedColor: UIColor?
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
    @Binding var selectedColor: UIColor?
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
    let color: UIColor
    
    var body: some View {
        GeometryReader { proxy in
            PopoverReader { context in
                
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
                        .frame(width: FieldSettingsConstants.sliderHeight, height: FieldSettingsConstants.sliderHeight),
                        
                        /// pin thumb to right of stretching `clear` container
                        alignment: .trailing
                    )
                    /// set frame of stretching `clear` container
                    .frame(
                        width: FieldSettingsConstants.sliderHeight + value * (proxy.size.width - FieldSettingsConstants.sliderHeight)
                    ),
                    alignment: .leading
                )
                .highPriorityGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            self.value = min(max(0, CGFloat(value.location.x / proxy.size.width)), 1)
                            context.isDraggingEnabled = false
                        }
                        .onEnded { _ in context.isDraggingEnabled = true }
                )
            }
            .drawingGroup() /// prevent thumb from disappearing when offset to show words
        }
    }
}

struct FieldSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        FieldSettingsView(
            model: FieldSettingsModel(),
            configuration: SearchConfiguration()
        )
        .previewLayout(.fixed(width: 250, height: 300))
    }
}
