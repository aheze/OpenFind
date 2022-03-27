//
//  PhotosSelectionToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSelectionToolbarView: View {
    @ObservedObject var model: PhotosViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "square.and.arrow.up") {}
                .disabled(model.selectedPhotos.count == 0)

            Text(selectedText())
                .font(.system(.headline))
                .frame(maxWidth: .infinity)

            ToolbarIconButton(iconName: "trash") {
                deleteSelected()
            }
            .disabled(model.selectedPhotos.count == 0)
        }
    }

    func selectedText() -> String {
        if model.selectedPhotos.count == 1 {
            return "\(model.selectedPhotos.count) Photo Selected"
        } else {
            return "\(model.selectedPhotos.count) Photos Selected"
        }
    }

    func deleteSelected() {
        model.delete(photos: model.selectedPhotos)
        model.stopSelecting?()
    }
}
