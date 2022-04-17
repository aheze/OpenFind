//
//  LaunchCameraView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/17/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct LaunchCameraView: View {
    @State var flash = false
    @State var check = false

    var body: some View {
        LaunchPageViewContent(
            title: "Camera",
            description: "Search for text in real time.",
            footnote: "Got allergies or other dietary restrictions? Just point your phone at the nutrition label and Find will scan it for you."
        ) {
            Button {
                flashAgain()
            } label: {
                cameraPreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(UIColor.systemBackground.color)
                    .cornerRadius(16)
                    .aspectRatio(contentMode: .fit)
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
    var cameraPreview: some View {
        VStack {
            
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
