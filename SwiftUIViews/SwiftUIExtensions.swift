//
//  SwiftUIExtensions.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

public extension View {
    /// Read a view's frame. From https://stackoverflow.com/a/66822461/14351818
    func readFrame(in coordinateSpace: CoordinateSpace = .global, rect: @escaping (CGRect) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentFrameReaderPreferenceKey.self, value: geometry.frame(in: coordinateSpace))
                    .onPreferenceChange(ContentFrameReaderPreferenceKey.self) { newValue in
                        DispatchQueue.main.async {
                            rect(newValue)
                        }
                    }
            }
            .hidden()
        )
    }
}

extension View {
    func addTopBorder() -> some View {
        overlay(
            Color.clear
                .overlay(
                    Rectangle()
                        .strokeBorder(UIColor.secondaryLabel.color, lineWidth: 0.25)
                        .padding(-0.25)
                )
                .mask(
                    Rectangle()
                        .padding(.top, -0.25) /// only show border on top
                )
                .frame(height: 200),

            alignment: .top
        )
    }
}

struct ContentFrameReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { return CGRect() }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

extension View {
    /**
     Read a view's size. The closure is called whenever the size itself changes, or the transaction changes (in the event of a screen rotation.)
     From https://stackoverflow.com/a/66822461/14351818
     */
    func readSize(size: @escaping (CGSize) -> Void) -> some View {
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

extension View {
    func blueBackground(highlighted: Bool = false, cornerRadius: CGFloat = 16) -> some View {
        self
            .background(highlighted ? Color.accent : Color.accent.opacity(0.1))
            .cornerRadius(cornerRadius)
    }
}
