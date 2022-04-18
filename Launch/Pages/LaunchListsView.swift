//
//  LaunchListsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct LaunchListsView: View {
    @State var showingPainting = false
    @State var showingList = false
    @State var highlight = false
    @State var transform: SettingsProfileTransformState?

    var body: some View {
        LaunchPageViewContent(
            title: "Lists",
            description: "Group words together.",
            footnote: "Need to find U.S. presidents in your textbook? Save your eyesight, let Find do its thing. Want to avoid artificial colors on your next grocery run? Leave it to the app."
        ) {
            Button {
                changePortrait()
            } label: {
                listsPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .overlay(Color.black.opacity(showingPainting ? 0 : 1))
                    .cornerRadius(16)
                    .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(LaunchButtonStyle())
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.8,
                    dampingFraction: 1,
                    blendDuration: 1
                )
            ) {
                showingPainting = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(
                    .spring(
                        response: 0.6,
                        dampingFraction: 0.8,
                        blendDuration: 1
                    )
                ) {
                    showingList = true
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(
                    .spring(
                        response: 0.2,
                        dampingFraction: 1,
                        blendDuration: 1
                    )
                ) {
                    highlight = true
                }
            }
        }
    }

    let presidents = ["George", "John", "Thomas"]
    var listsPreview: some View {
        VStack(spacing: 0) {
            Color.clear.overlay(
                VStack {
                    PortraitView(length: 90, circular: false, transform: $transform)

                    Group {
                        Text("Thomas")
                            .foregroundColor(.white)
                            + Text(" Jefferson")
                            .foregroundColor(.black)
                    }
                    .font(UIFont.safeFont(name: "TimesNewRomanPSMT", size: 24).font)
                    .foregroundColor(UIColor.label.color)
                    .colorMultiply(highlight ? .red : .black)
                }
                .padding(36)
                .background(Color.white)
                .border(UIColor.systemBrown.color, width: 4)
                .shadow(
                    color: UIColor.label.color.opacity(0.25),
                    radius: 8,
                    x: 0,
                    y: 1
                )
                .background(
                    RadialGradient(
                        stops: [
                            .init(
                                color: UIColor.white.color,
                                location: 0.3
                            ),
                            .init(
                                color: UIColor.black.color,
                                location: 1
                            )
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                    .padding(-400)
                )
            )

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
                            .fixedSize(horizontal: true, vertical: false)
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
                    UIColor.systemBackground.color
                        .overlay(
                            Color.red
                                .opacity(0.1)
                        )
                        .padding(.bottom, -100)
                )
            }
            .offset(x: 0, y: showingList ? 0 : 400)
            .opacity(showingList ? 1 : 0)
        }
    }

    func changePortrait() {
        withAnimation(
            .spring(
                response: 0.6,
                dampingFraction: 0.6,
                blendDuration: 1
            )
        ) {
            if transform == nil {
                transform = SettingsProfileTransformState.allCases.randomElement()
            } else {
                transform = nil
            }
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
