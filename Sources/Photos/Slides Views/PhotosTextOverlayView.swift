//
//  PhotosTextOverlayView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/25/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotosTextOverlayViewModel: ObservableObject {
    @Published var on = false
}

struct PhotosTextOverlayView: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var textOverlayViewModel: PhotosTextOverlayViewModel

    var body: some View {
        let imageName = getImageName()

        Button {
            withAnimation {
                textOverlayViewModel.on.toggle()
            }
        } label: {
            Image(systemName: imageName)
                .foregroundColor(.white)
                .padding(6)
                .background(
                    Circle()
                        .fill(
                            textOverlayViewModel.on ? Color.accent : Color.gray
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
