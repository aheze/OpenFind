//
//  FindIconView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct FindIconView: View {
    var color: UInt = 0x00AEEF
    var alpha = CGFloat(1)

    var body: some View {
        
        GeometryReader { geometry in
            let spacing = geometry.size.height * FindIconUIView.spacingPercent
            let availableHeightForHighlights = geometry.size.height - (2 * spacing)
            let highlightHeight = availableHeightForHighlights / 3
            let alphaAdjustedColor = alphaAdjustedColor()

            VStack(
                alignment: .leading,
                spacing: spacing
            ) {
                Color(alphaAdjustedColor)
                    .cornerRadius(highlightHeight / 2)

                Color(alphaAdjustedColor.toColor(.white, percentage: 0.3))
                    .frame(width: highlightHeight * 2 + spacing)
                    .cornerRadius(highlightHeight / 2)

                Color(alphaAdjustedColor.toColor(.white, percentage: 0.6))
                    .frame(width: highlightHeight)
                    .cornerRadius(highlightHeight / 2)
            }
        }
    }

    func alphaAdjustedColor() -> UIColor {
        let uiColor = UIColor(hex: color)
        return uiColor.toColor(.white, percentage: 1 - alpha)
    }
}
