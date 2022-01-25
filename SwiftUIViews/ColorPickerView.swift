//
//  ColorPickerView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class ColorPickerViewModel: ObservableObject {
    @Published var selectedColor = UIColor(hex: 0x00a1d8)
    @Published var selectedIndex = (0, 0)
    let colors: [[UIColor]]

    init() {
        var colors = [[UIColor]]()

        /// leftmost color, vertically centered
        let baseColor = UIColor(hex: 0x00a1d8)
        for column in 0..<12 {
            let columnColor = baseColor.offset(by: -CGFloat(column) / CGFloat(12))

            var columnColors = [UIColor]()
            for row in -3..<5 {
                let color = columnColor.adjust(by: CGFloat(row) / CGFloat(6))
                columnColors.append(color)
            }

            colors.append(columnColors)
        }

        self.colors = colors
        for (column, columnColors) in colors.enumerated() {
            if let row = columnColors.firstIndex(where: { $0 == selectedColor }) {
                self.selectedIndex = (column, row)
            }
        }
    }
}

struct ColorPickerView: View {
    @ObservedObject var model: ColorPickerViewModel
    @State var colorPaletteSize = CGSize.zero

    var body: some View {
        Text("Color picker")
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ForEach(model.colors, id: \.self) { columnColors in
                    VStack(spacing: 0) {
                        ForEach(columnColors, id: \.self) { color in
                            Color(color)
                        }
                    }
                }
            }
            .aspectRatio(CGFloat(12) / 8, contentMode: .fit)
            .coordinateSpace(name: "Color")
            .sizeReader {
                colorPaletteSize = $0
            }
            .cornerRadius(12)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("Color"))
                    .onChanged { value in
                        let x = value.location.x / colorPaletteSize.width
                        let y = value.location.y / colorPaletteSize.height

                        let column = Int(x * 12)
                        let row = Int(y * 8)

                        model.selectedColor = model.colors[column][row]
                        model.selectedIndex = (column, row)
                    }
            )

            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.white, lineWidth: 4)
                .frame(width: colorPaletteSize.width / 12, height: colorPaletteSize.width / 12)
                .allowsHitTesting(false)
                .offset(
                    CGSize(
                        width: CGFloat(model.selectedIndex.0) * colorPaletteSize.width / 12,
                        height: CGFloat(model.selectedIndex.1) * colorPaletteSize.height / 8
                    )
                )
        }
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

