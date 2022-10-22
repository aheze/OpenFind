//
//  PopoverTipView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PopoverTipView: View {
    let title: String
    let description: String
    let action: (() -> Void)?

    let cornerRadius = CGFloat(16)

    var body: some View {
        Button {} label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(UIFont.preferredCustomFont(forTextStyle: .headline, weight: .bold).font)

                Text(description)
                    .font(UIFont.preferredCustomFont(forTextStyle: .body, weight: .regular).font)
            }
            .padding()
            .background(
                VisualEffectView(.regular)
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(UIColor.label.color.opacity(0.5), lineWidth: 2)
            )
        }
        .buttonStyle(EasingScaleButtonStyle())
    }
}

struct PopoverTipView_Previews: PreviewProvider {
    static var previews: some View {
        PopoverTipView(
            title: "Start Finding!",
            description: "Tap here to search your photos."
        ) {}
            .padding()
            .background(Color.gray)
    }
}
