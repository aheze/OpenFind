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

        let cornerRadius = getCornerRadius(rectHeight: highlight.position.size.height)

//        Color.blue
//            .opacity(0.2)
//            .border(.black, width: 0.5)
//            .overlay(
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(gradient)
            .opacity(0.2)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(gradient, lineWidth: 0.5)
                    .opacity(0.8)
            )
            .opacity(getLingeringOpacity())
            .opacity(highlight.alpha)
            .frame(
                width: highlight.position.size.width * viewSize.width,
                height: highlight.position.size.height * viewSize.height
            )
            .rotationEffect(.radians(-highlight.position.angle))
            .position(
                x: highlight.position.center.x * viewSize.width,
                y: highlight.position.center.y * viewSize.height
            )
//            .padding(.leading, highlight.position.horizontalOffset * viewSize.width)

//        ,
            //                    .frame(with: highlight.position.sentenceFrame.scaleTo(viewSize))
//                alignment: .leading
//            )
            
//            .frame(with: highlight.position.sentenceFrame.scaleTo(viewSize))
    }

    func getLingeringOpacity() -> CGFloat {
        if case .lingering = highlight.state {
            return 0.1
        } else {
            return 1
        }
    }

    func getCornerRadius(rectHeight: CGFloat) -> CGFloat {
        return (rectHeight * 300) / 4
    }
}
