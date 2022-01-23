//
//  PhotosVC+Selection.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class PhotosSelectionViewModel: ObservableObject {
    @Published var selectedCount = 0
    @Published var starOn = false
    init() {}
}

struct PhotosSelectionToolbarView: View {
    @ObservedObject var model: PhotosSelectionViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: model.starOn ? "star.fill" : "star") {
                model.starOn.toggle()
            }
            .disabled(model.selectedCount == 0)

            Text(selectedText())
                .font(.system(.headline))
                .frame(maxWidth: .infinity)

            ToolbarIconButton(iconName: "trash") {}
                .disabled(model.selectedCount == 0)
        }
    }

    func selectedText() -> String {
        if model.selectedCount == 1 {
            return "\(model.selectedCount) Photo Selected"
        } else {
            return "\(model.selectedCount) Photos Selected"
        }
    }
}
