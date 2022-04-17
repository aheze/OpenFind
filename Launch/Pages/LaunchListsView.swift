//
//  LaunchListsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct LaunchListsView: View {
    @State var showing = false
    @State var flash = false

    var body: some View {
        LaunchPageViewContent(
            title: "Lists",
            description: "Group words together.",
            footnote: "Need to find U.S. presidents in your textbook? You can do that in a split second. Trying to avoid artificial colors on your grocery run? Now you're all set."
        ) {
            Button {
                flashAgain()
            } label: {
                listsPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(UIColor.systemBackground.color)
                    .cornerRadius(16)
                    .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(LaunchButtonStyle())
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.6,
                    dampingFraction: 0.8,
                    blendDuration: 1
                )
            ) {
                showing = true
            }
        }
    }

    let presidents = ["George", "John", "Thomas"]
    var listsPreview: some View {
        VStack {
            HStack {
                Image("Zheng")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)

                VStack {
                    Text("Thomas Jefferson")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title1, weight: .medium).font)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Thomas Jefferson (April 13, 1743 – July 4, 1826) was an American statesman, diplomat, lawyer, architect, philosopher, and Founding Father who served as the third president of the United States from 1801 to 1809. - Wikipedia")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title2, weight: .regular).font)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                .foregroundColor(UIColor.label.color)
                .frame(maxWidth: .infinity)
            }

            VStack(spacing: 0) {
                HStack {
                    Text("U.S. Presidents")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .bold).font)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("🇺🇸")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Color.blue)
                .cornerRadius(16, corners: [.topLeft, .topRight])

                HStack {
                    ForEach(presidents, id: \.self) { name in
                        Text(name)
                            .font(UIFont.preferredCustomFont(forTextStyle: .headline, weight: .medium).font)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .background(
                    Color.red
                        .opacity(0.1)
                        .padding(.bottom, -100)
                )
            }
            .offset(x: 0, y: showing ? 0 : 400)
            .opacity(showing ? 1 : 0)
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

/// from https://stackoverflow.com/a/58606176/14351818
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
