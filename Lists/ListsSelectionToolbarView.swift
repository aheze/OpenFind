//
//  ListsSelectionToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ListsSelectionToolbarView: View {
    @ObservedObject var model: ListsViewModel

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "square.and.arrow.up") {
            }
            .disabled(model.selectedLists.count == 0)

            Text(selectedText())
                .font(.system(.headline))
                .frame(maxWidth: .infinity)

            ToolbarIconButton(iconName: "trash") {
                
            }
            .disabled(model.selectedLists.count == 0)
        }
    }

    func selectedText() -> String {
        if model.selectedLists.count == 1 {
            return "\(model.selectedLists.count) List Selected"
        } else {
            return "\(model.selectedLists.count) Lists Selected"
        }
    }
}
