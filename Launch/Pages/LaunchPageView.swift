//
//  LaunchPageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum LaunchPageViewConstants {
    static var titleFont = UIFont.preferredCustomFont(forTextStyle: .largeTitle, weight: .semibold)
    static var descriptionFont = UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium)

    static var spacing = CGFloat(8)
    static var edgePadding = CGFloat(24) /// screen edge
    static var contentInset = EdgeInsets(top: 36, leading: 20, bottom: 36, trailing: 20)
}

struct LaunchPageView: View {
    @ObservedObject var model: LaunchViewModel
    @ObservedObject var pageViewModel: LaunchPageViewModel
    let c = LaunchPageViewConstants.self

    var body: some View {
        VStack {
            switch pageViewModel.identifier {
            case .empty:
                EmptyView()
            case .photos:
                LaunchPageViewContent(
                    title: "Photos",
                    description: "Find text."
                ) {
                    Text("HI!")
                }
            case .camera:
                EmptyView()
            case .lists:
                EmptyView()
            }
        }
    }
}

struct LaunchPageViewContent<Content: View>: View {
    var title: String
    var description: String
    @ViewBuilder let content: Content

    let c = LaunchPageViewConstants.self

    var body: some View {
        VStack(spacing: c.spacing) {
            Text(title)
                .font(c.titleFont.font)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text(description)
                .font(c.descriptionFont.font)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(UIColor.label.color)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(c.contentInset)
        .background(UIColor.systemBackground.color)
        .cornerRadius(16)
        .padding(.horizontal, c.edgePadding)
    }
}
