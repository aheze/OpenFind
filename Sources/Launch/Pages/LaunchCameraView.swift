//
//  LaunchCameraView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct LaunchCameraView: View {
    @State var activeColor = Color.blue
    @State var showing = false
    @State var highlight = false

    var body: some View {
        LaunchPageViewContent(
            title: "Camera",
            description: "Search for text in real time.",
            footnote: "Got allergies or other dietary restrictions? Just point your phone at the nutrition label and OpenFind will scan it for you."
        ) {
            Button {
                changeColor()
            } label: {
                cameraPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            colors: [
                                UIColor(hex: 0x00AEEF).color,
                                Colors.accent.toColor(.black, percentage: 0.5).color
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(LaunchButtonStyle())
        }
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.6,
                    dampingFraction: 0.9,
                    blendDuration: 1
                )
            ) {
                showing = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
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

    let cornerRadius = CGFloat(8)

    var cameraPreview: some View {
        VStack {
            VStack(spacing: 6) {
                Group {
                    Text("INGREDIENTS:")
                        .font(UIFont.preferredCustomFont(forTextStyle: .title2, weight: .bold).font)

                    Text("Enriched Corn Meal (Corn Meal, Riboflavin, Folic Acid), ")
                        .foregroundColor(.black)
                        + Text("Cheese")
                        .foregroundColor(.white)
                        .font(UIFont.preferredMonospacedFont(forTextStyle: .title3, weight: highlight ? .semibold : .regular).font)

                        + Text(", Maltodextrin (Made from Corn), Sea Salt, Natural Flavors.")
                        .foregroundColor(.black)
                }
                .font(UIFont.preferredMonospacedFont(forTextStyle: .title3, weight: .regular).font)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .colorMultiply(highlight ? activeColor : .black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [
                                UIColor.white.color,
                                UIColor.white.toColor(.black, percentage: 0.08).color
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .padding(.bottom, -100) /// extend down a bit
            )
            .foregroundColor(.black)
            .padding(.top, 48)
            .padding(.horizontal, 36)
            .offset(x: 0, y: showing ? 0 : 400)
            .opacity(showing ? 1 : 0)
        }
    }

    func changeColor() {
        withAnimation {
            activeColor = [
                Color.red,
                Color.orange,
                Color.green,
                Color.blue,
                Color.purple
            ].randomElement() ?? .blue
        }
    }

    func getNumberOfColumnsAndWidth(from availableWidth: CGFloat) -> (Int, CGFloat) {
        let minimumCellLength = CGFloat(80)
        return minimumCellLength.getColumns(availableWidth: availableWidth)
    }
}
