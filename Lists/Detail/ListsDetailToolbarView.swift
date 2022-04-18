//
//  ListsDetailToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ListsDetailToolbarView: View {
    @ObservedObject var model: ListsDetailViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "doc.on.doc") {
                let words = model.selectedWords.map { $0.string }
                let string = words.joined(separator: "•")
                let pasteboard = UIPasteboard.general

                pasteboard.string = string
            }
            .disabled(model.selectedWords.count == 0)

            Text(selectedText())
                .font(.system(.headline))
                .frame(maxWidth: .infinity)

            ToolbarIconButton(iconName: "trash") {
                model.deleteSelected?()
            }
            .disabled(model.selectedWords.count == 0)
        }
    }

    func selectedText() -> String {
        if model.selectedWords.count == 1 {
            return "\(model.selectedWords.count) Word Selected"
        } else {
            return "\(model.selectedWords.count) Words Selected"
        }
    }
}
