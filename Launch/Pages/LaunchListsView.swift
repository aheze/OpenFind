//
//  LaunchListsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

struct LaunchListsView: View {
    @State var flash = false
    @State var check = false

    var body: some View {
        LaunchPageViewContent(
            title: "Lists",
            description: "Group words together.",
            footnote: "Now when your Spanish teacher assigns you a vocab list you're all set. Maybe make a list of foods that you'd like to avoid."
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
