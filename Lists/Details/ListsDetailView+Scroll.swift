//
//  ListsDetailView+Scroll.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension View {
    
    /// Listen to scroll view offsets. Must set `scroll` coordinate space on the scroll view.
    func onOffsetChange(offset: @escaping (CGFloat) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: OffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                    .onPreferenceChange(OffsetPreferenceKey.self) { newValue in
                        offset(newValue)
                    }
            }
            .hidden()
        )
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
