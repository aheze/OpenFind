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
                ForEach(model.displayedLists) { list in
                    ListWidgetView(model: model, list: list)
                }
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
    @ObservedObject var model: KeyboardToolbarViewModel
    var list: List
    var body: some View {
        Button {
            model.listSelected?(list)
        } label: {
            HStack {
                Image(systemName: list.icon)
                Text(list.name.isEmpty ? "Untitled" : list.name)
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
            .contentShape(Rectangle())
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
