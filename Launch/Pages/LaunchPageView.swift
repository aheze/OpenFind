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
                EmptyView()
            case .lists:
                EmptyView()
            }
        }
    }
}

struct LaunchPhotosView: View {
    @State var flash = false
    @State var check = false

    var body: some View {
        LaunchPageViewContent(
            title: "Photos",
            description: "Search for text in your photos.",
            footnote: "Comes in handy when you're trying to find memes. Find works 100% offline, never connects to the internet, and nothing ever leaves your phone."
        ) {
            Button {
                flashAgain()
            } label: {
                gridPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(UIColor.systemBackground.color)
                    .cornerRadius(16)
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        VStack {
                            if check {
                                Image(systemName: "checkmark")
                                    .font(UIFont.systemFont(ofSize: 64, weight: .semibold).font)
                                    .foregroundColor(.white)
                                    .padding(24)
                                    .aspectRatio(contentMode: .fit)
                                    .background(
                                        VisualEffectView(.systemUltraThinMaterialLight)
                                    )
                                    .cornerRadius(20)
                                    .transition(.scale(scale: 0.6))
                            }
                        }
                    )
            }
            .buttonStyle(LaunchButtonStyle())
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(
                    .spring(
                        response: 0.3,
                        dampingFraction: 0.4,
                        blendDuration: 1
                    )
                ) {
                    check = true
                }
            }
        }
    }

    let cellSpacing = CGFloat(2)
    var gridPreview: some View {
        GeometryReader { geometry in
            let (numberOfColumns, columnWidth) = getNumberOfColumnsAndWidth(from: geometry.size.width)
            let numberOfRows = Int(ceil(geometry.size.height / columnWidth))

            VStack(spacing: cellSpacing) {
                ForEach(0 ..< numberOfRows, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0 ..< numberOfColumns, id: \.self) { column in
                            let offset = CGFloat(row * column)

                            Color.green
                                .overlay(
                                    Colors
                                        .accent
                                        .offset(by: offset * 0.005)
                                        .color
                                        .opacity(flash ? 1 : 0.5)
                                        .animation(.linear(duration: 0.5).delay(offset * 0.05), value: flash)
                                )
                        }
                    }
                    .aspectRatio(CGFloat(numberOfColumns), contentMode: .fit)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    flash = true
                }
            }
        }
    }

    func flashAgain() {
        flash = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            flash = true
        }
    }

    func getNumberOfColumnsAndWidth(from availableWidth: CGFloat) -> (Int, CGFloat) {
        let minimumCellLength = CGFloat(80)
        return minimumCellLength.getColumns(availableWidth: availableWidth)
    }
}

struct LaunchPageViewContent<Content: View>: View {
    var title: String
    var description: String
    var footnote: String
    @ViewBuilder let content: Content

    let c = LaunchPageViewConstants.self

    var body: some View {
        VStack(spacing: c.spacing) {
            Text(title)
                .font(c.titleFont.font)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .fixedSize(horizontal: false, vertical: true)

            Group {
                Text(description)
                    .foregroundColor(.white)
                    + Text(" ")

                    + Text(footnote)
                    .foregroundColor(.white.opacity(0.75))
            }
            .font(c.descriptionFont.font)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(c.contentInset)
        .background(UIColor.systemBackground.color.opacity(0.1))
        .cornerRadius(c.cornerRadius)
        .padding(.horizontal, c.edgePadding)
        .padding(.vertical, 0.5) /// view gets clipped a bit, add a bit of padding
    }
}
