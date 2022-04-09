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
        Color.clear.overlay(
            GeometryReader { geometry in
                ZStack {
                    ForEach(highlightsViewModel.highlights) { highlight in
                        HighlightView(
                            model: highlightsViewModel,
                            highlight: highlight,
                            viewSize: geometry.size
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
        .edgesIgnoringSafeArea(.all)
        .opacity(highlightsViewModel.upToDate ? 1 : 0.5)
    }
}

struct HighlightView: View {
    @ObservedObject var model: HighlightsViewModel
    let highlight: Highlight
    let viewSize: CGSize
    var body: some View {
        let gradient = LinearGradient(
            colors: highlight.colors.map { $0.color },
            startPoint: .leading,
            endPoint: .trailing
        )

        let cornerRadius = getCornerRadius()
        let frame = getFrame()

        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(gradient)
            .opacity(0.2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: 1.2)
            )
            .opacity(getLingeringOpacity())
            .opacity(highlight.alpha)
            .frame(
                width: frame.width,
                height: frame.height
            )
            .rotationEffect(.radians(-highlight.position.angle))
            .position(
                x: frame.minX,
                y: frame.minY
            )
    }

    func getFrame() -> CGRect {
        if model.shouldScaleHighlights {
            return CGRect(
                x: highlight.position.center.x * viewSize.width,
                y: highlight.position.center.y * viewSize.height,
                width: highlight.position.size.width * viewSize.width,
                height: highlight.position.size.height * viewSize.height
            )
        } else {
            return CGRect(
                x: highlight.position.center.x,
                y: highlight.position.center.y,
                width: highlight.position.size.width,
                height: highlight.position.size.height
            )
        }
    }

    func getLingeringOpacity() -> CGFloat {
        if case .lingering = highlight.state {
            return 0.1
        } else {
            return 1
        }
    }

    func getCornerRadius() -> CGFloat {
        /// use shortest side for calculating
        let length = min(highlight.position.size.width, highlight.position.size.height)
        if model.shouldScaleHighlights {
            return (length * 300) / 4
        } else {
            return length / 3
        }
    }
}
