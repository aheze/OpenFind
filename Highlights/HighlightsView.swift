//
//  HighlightsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/30/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import SwiftUI

struct HighlightsView: View {
    @ObservedObject var highlightsViewModel: HighlightsViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(highlightsViewModel.highlights)) { highlight in
                    HighlightView(highlight: highlight, viewSize: geometry.size)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .opacity(highlightsViewModel.upToDate ? 1 : 0.5)
    }
}

struct HighlightView: View {
    let highlight: Highlight
    let viewSize: CGSize
    var body: some View {
        let gradient = LinearGradient(
            colors: highlight.colors.map { $0.color },
            startPoint: .leading,
            endPoint: .trailing
        )
        
        let cornerRadius = getCornerRadius(rectHeight: highlight.frame.height)
        
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(gradient)
            .opacity(0.2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: 2)
                    .opacity(0.8)
            )
            .opacity(highlight.state == .lingering ? 0.1 : 1)
            .opacity(highlight.alpha)
            .frame(with: highlight.frame.scaleTo(viewSize))
    }

    func getCornerRadius(rectHeight: CGFloat) -> CGFloat {
        return (rectHeight * 300) / 4
    }
}
