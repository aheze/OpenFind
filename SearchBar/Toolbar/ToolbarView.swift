//
//  KeyboardToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ToolbarView: View {
    @ObservedObject var model: KeyboardToolbarViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(model.realmModel.lists) { list in
                    ListWidgetView(list: list)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
                .edgesIgnoringSafeArea(.all)
        )
        .overlay(
            Rectangle()
                .fill(Color(UIColor.secondaryLabel))
                .frame(height: 0.25),
            alignment: .top
        )
    }
}

struct ListWidgetView: View {
    var list: List
    var body: some View {
        Button {} label: {
            HStack {
                Image(systemName: list.icon)
                Text(list.name)
            }
            .foregroundColor(
                Color(textColor())
            )
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(
                Color(
                    UIColor(hex: list.color)
                )
            )
            .cornerRadius(10)
        }
    }

    func textColor() -> UIColor {
        let color = UIColor(hex: list.color)
        if color.isLight {
            return .black
        } else {
            return .white
        }
    }
}
