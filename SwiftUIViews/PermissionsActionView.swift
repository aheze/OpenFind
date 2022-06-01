//
//  PermissionsActionView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 6/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PermissionsActionView: View {
    let image: String
    let title: String
    let description: String
    let actionLabel: String
    let dark: Bool
    let action: () -> Void

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        let descriptionFont = getDescriptionFont()
        Color.clear.overlay(
            AdaptiveStack(vertical: verticalSizeClass != .compact, spacing: 32) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 160, height: 160)
                    .accessibility(hidden: true)

                let alignment: HorizontalAlignment = verticalSizeClass != .compact ? .center : .leading
                let labelAlignment: Alignment = verticalSizeClass != .compact ? .center : .leading
                let textAlignment: TextAlignment = verticalSizeClass != .compact ? .center : .leading

                VStack(alignment: alignment, spacing: 28) {
                    VStack(alignment: alignment, spacing: 12) {
                        Text(title)
                            .font(UIFont.preferredFont(forTextStyle: .title1).font)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(dark ? UIColor.white.color : UIColor.label.color)

                        Text(description)
                            .font(descriptionFont.font)
                            .minimumScaleFactor(0.4) /// allow resizing
                            .frame(maxWidth: .infinity, alignment: labelAlignment)
                            .multilineTextAlignment(textAlignment)
                            .foregroundColor(dark ? UIColor.white.withAlphaComponent(0.75).color : UIColor.secondaryLabel.color)
                    }

                    Button(action: action) {
                        let colors = dark
                            ? [
                                Colors.accent.toColor(.black, percentage: 0.75).color,
                                Colors.accent.toColor(.black, percentage: 0.75).withAlphaComponent(0.5).color
                            ]
                            : [
                                Colors.accent.color,
                                Colors.accent.offset(by: 0.02).color
                            ]

                        Text(actionLabel)
                            .font(descriptionFont.font)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24))
                            .background(
                                LinearGradient(
                                    colors: colors,
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, verticalSizeClass != .compact ? 48 : 0)
            }
            .padding(.vertical, 100)
            .frame(maxWidth: getMaxWidth())
        )
        .edgesIgnoringSafeArea(.all)
        .padding(.horizontal, verticalSizeClass != .compact ? 0 : 64)
    }

    /// for iPad
    func getMaxWidth() -> CGFloat? {
        if verticalSizeClass == .regular && horizontalSizeClass == .regular {
            return 500
        }
        return nil
    }

    func getDescriptionFont() -> UIFont {
        if verticalSizeClass == .regular && horizontalSizeClass == .regular {
            return UIFont.preferredCustomFont(forTextStyle: .title2, weight: .medium)
        }
        return UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium)
    }
}

struct CameraPermissionsViewTester: View {
    @StateObject var model = CameraPermissionsViewModel()
    var body: some View {
        CameraPermissionsView(model: model)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.accent)
    }
}

@available(iOS 15.0, *)
struct CameraPermissionsView_Previews: PreviewProvider {
    static var previews: some View {
        CameraPermissionsViewTester()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

struct AdaptiveStack<Content: View>: View {
    let vertical: Bool
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(vertical: Bool, horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.vertical = vertical
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if vertical {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            } else {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            }
        }
    }
}
