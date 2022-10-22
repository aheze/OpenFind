//
//  LaunchPhotosView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct LaunchPhotosView: View {
    @State var flash = false
    @State var scanned = false
    @State var zoomed = false
    @State var check = false

    var body: some View {
        LaunchPageViewContent(
            title: "Photos",
            description: "Search for text in your photos.",
            footnote: "Comes in handy when you're trying to find memes. OpenFind works 100% offline, never connects to the internet, and nothing ever leaves your phone."
        ) {
            Button {
                flashAgain()
            } label: {
                gridPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(UIColor.systemBackground.color)
                    .cornerRadius(16)
                    .aspectRatio(1, contentMode: .fit)
            }
            .buttonStyle(LaunchButtonStyle())
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(
                    .spring(
                        response: 0.3,
                        dampingFraction: 0.3,
                        blendDuration: 1
                    )
                ) {
                    scanned = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(
                    .spring(
                        response: 0.9,
                        dampingFraction: 0.8,
                        blendDuration: 1
                    )
                ) {
                    zoomed = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
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

    let numberOfRows = 4
    let cellSpacing = CGFloat(2)
    var gridPreview: some View {
        GeometryReader { geometry in

            VStack(spacing: cellSpacing) {
                ForEach(0 ..< numberOfRows, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0 ..< numberOfRows, id: \.self) { column in
                            let offset = CGFloat(row * column)
                            let shouldHighlight = getShouldHighlight(column: column, row: row)

                            Color.green
                                .overlay(
                                    Colors
                                        .accent
                                        .offset(by: offset * 0.005)
                                        .color
                                        .opacity(flash ? 1 : 0.5)
                                        .animation(.linear(duration: 0.5).delay(offset * 0.05), value: flash)
                                )
                                .overlay(
                                    VStack {
                                        let lineWidth = CGFloat(5)

                                        if shouldHighlight {
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.white, lineWidth: lineWidth)
                                                .padding(-lineWidth / 2)
                                                .opacity(scanned ? 1 : 0)
                                                .shadow(
                                                    color: Color.blue.opacity(0.75),
                                                    radius: 10,
                                                    x: 0,
                                                    y: 2
                                                )
                                                .scaleEffect(scanned ? 1 : 0.95)
                                        }
                                    }
                                )
                                .zIndex(shouldHighlight ? 1 : 0)
                                .aspectRatio(contentMode: .fit)
                                .overlay(
                                    VStack {
                                        if shouldHighlight, check {
                                            Image(systemName: "checkmark")
                                                .font(UIFont.systemFont(ofSize: 42, weight: .semibold).font)
                                                .foregroundColor(.white)
                                                .aspectRatio(contentMode: .fit)
                                                .transition(.scale(scale: 0.6))
                                        }
                                    }
                                )
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .zIndex(row == 1 ? 1 : 0)
                }
            }
            .scaleEffect(zoomed ? 1.346 : 1, anchor: .topTrailing)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    flash = true
                }
            }
        }
    }

    func getShouldHighlight(column: Int, row: Int) -> Bool {
        return column == 2 && row == 1
    }

    func flashAgain() {
        flash = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            flash = true
        }
    }
}
