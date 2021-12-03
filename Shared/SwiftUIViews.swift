//
//  Views.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct Line: View {
    var body: some View {
        Rectangle()
            .fill(Color(UIColor.white.withAlphaComponent(0.1)))
            .frame(height: 1)
    }
}
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
