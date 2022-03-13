//
//  GeneralViews.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct Line: View {
    var color: UIColor
    var body: some View {
        Rectangle()
            .fill(Color(color))
            .frame(height: 1)
    }
}

/// Use UIKit blurs in SwiftUI.
struct VisualEffectView: UIViewRepresentable {
    /// The blur's style.
    public var style: UIBlurEffect.Style

    /// Use UIKit blurs in SwiftUI.
    public init(_ style: UIBlurEffect.Style) {
        self.style = style
    }

    public func makeUIView(context _: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }

    public func updateUIView(_ uiView: UIVisualEffectView, context _: UIViewRepresentableContext<Self>) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
