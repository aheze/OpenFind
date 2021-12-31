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
                ForEach(Array(highlightsViewModel.reusedHighlights)) { highlight in
                    HighlightView(highlight: highlight, viewSize: geometry.size)
                }
                
                ForEach(Array(highlightsViewModel.addedHighlights)) { highlight in
                    HighlightView(highlight: highlight, viewSize: geometry.size)
                }
                
                ForEach(Array(highlightsViewModel.lingeringHighlights)) { highlight in
                    HighlightView(highlight: highlight, viewSize: geometry.size)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
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
        
        let frame = getScaledRect()
        let cornerRadius = getCornerRadius(rectHeight: frame.height)
        
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(gradient)
            .opacity(0.2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: 2)
                    .opacity(0.8)
            )
            .frame(rect: frame)
    }

    func getScaledRect() -> CGRect {
        var rect = CGRect(
            x: highlight.frame.origin.x * viewSize.width,
            y: highlight.frame.origin.y * viewSize.height,
            width: highlight.frame.width * viewSize.width,
            height: highlight.frame.height * viewSize.height
        )
        rect = rect.insetBy(dx: -3, dy: -3)
        
        return rect
    }
    
    func getCornerRadius(rectHeight: CGFloat) -> CGFloat {
        return rectHeight / 10
    }
}
