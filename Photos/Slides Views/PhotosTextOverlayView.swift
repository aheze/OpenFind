//
//  PhotosTextOverlayView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosTextOverlayView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        let imageName = getImageName()

        Button {
            print("Show text!")
        } label: {
            Image(systemName: imageName)
                .foregroundColor(.white)
                .padding(6)
                .background(
                    Circle()
                        .fill(
                            Color.accent
                        )
                )
        }
    }

    func getImageName() -> String {
        if #available(iOS 15.0, *) {
            return "text.viewfinder"
        } else {
            return "viewfinder"
        }
    }
}
