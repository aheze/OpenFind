//
//  ColorPickerView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ColorPickerViewModel: ObservableObject {
    @Published var selectedColor = UIColor.blue
    
    let colors = [[UIColor]]()
    
    init() {
        
        /// leftmost color, vertically centered
        let baseColor = UIColor(hex: 0x00a1d8)
        for column in 0..<12 {
            let columnColor = model.baseColor.offset(by: -CGFloat(column) / CGFloat(12))
            
            var columnColors = [UIColor]()
            for row in -3..<5 {
                let color = columnColor.adjust(by: CGFloat(row) / CGFloat(6))
                columnColors.append(color)
            }
            
            colors.append(columnColors)
        }
    }
}

struct ColorPickerView: View {
    @ObservedObject var model: ColorPickerViewModel
    @State var colorPaletteSize = CGSize.zero

    var body: some View {
        Text("Color picker")

        HStack(spacing: 0) {
            ForEach(0..<12) { column in
                let columnColor = model.baseColor.offset(by: -CGFloat(column) / CGFloat(12))
                VStack(spacing: 0) {
                    ForEach(-3..<5) { row in
                        let color = columnColor.adjust(by: CGFloat(row) / CGFloat(6))

                        Color(color)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white)
                                .allowsHitTesting(false)
                                .opacity(model.selectedColor == color ? 1 : 0)
                        )
                    }
                }
            }
        }
        .aspectRatio(CGFloat(12) / 8, contentMode: .fit)
        .coordinateSpace(name: "Color")
        .sizeReader {
            colorPaletteSize = $0
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("Color"))
                .onChanged { value in
                    let x = value.location.x / colorPaletteSize.width
                    let y = value.location.y / colorPaletteSize.height
                    
                    let column = Int(x * 8)
                    let row = Int(y * 12)
                    
                    print("\(row), \(column)")
                }
        )
    }
}

extension View {
    /**
     Read a view's size. The closure is called whenever the size itself changes, or the transaction changes (in the event of a screen rotation.)
     From https://stackoverflow.com/a/66822461/14351818
     */
    func sizeReader(size: @escaping (CGSize) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            size(newValue)
                        }
                    }
            }
            .hidden()
        )
    }
}

struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { return CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}
