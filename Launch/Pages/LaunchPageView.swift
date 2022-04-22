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
    static var descriptionFont = UIFont.preferredCustomFont(forTextStyle: .title2, weight: .medium)
    static var descriptionFontLarge = UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium)

    static var spacing = CGFloat(16)
    static var edgePadding = CGFloat(24) /// screen edge
    static var contentInset = EdgeInsets(top: 36, leading: 20, bottom: 36, trailing: 20)

    static var cornerRadius = CGFloat(20)
    static var borderWidth = CGFloat(2)
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
                LaunchPhotosView()
            case .camera:
                LaunchCameraView()
            case .lists:
                LaunchListsView()
            case .final:
                LaunchFinalView(model: model)
            }
        }
    }
}

struct LaunchPageViewContent<Content: View>: View {
    var title: String
    var description: String
    var footnote: String
    @ViewBuilder let content: Content

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    let c = LaunchPageViewConstants.self

    var body: some View {
        VStack(spacing: c.spacing) {
            Text(title)
                .font(c.titleFont.font)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            Color.clear.overlay(
                Group {
                    Text(description)
                        .foregroundColor(.white)
                        + Text(" ")
                        + Text(footnote)
                        .foregroundColor(.white.opacity(0.75))
                }
                .font(getDescriptionFont().font)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.4) /// allow resizing
                .frame(maxWidth: .infinity, alignment: .leading),

                alignment: .top
            )
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(c.contentInset)
        .background(UIColor.systemBackground.color.opacity(0.1))
        .cornerRadius(c.cornerRadius)
        .padding(.horizontal, c.edgePadding)
        .padding(.vertical, 0.5) /// view gets clipped a bit, add a bit of padding
    }

    func getDescriptionFont() -> UIFont {
        if horizontalSizeClass == .regular && verticalSizeClass == .regular {
            return c.descriptionFontLarge
        } else {
            return c.descriptionFont
        }
    }
}
