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
                
            }
            .disabled(model.selectedIndices.count == 0)
            
            Text(selectedText())
                .font(.system(.headline))
                .frame(maxWidth: .infinity)
            
            ToolbarIconButton(iconName: "trash") {
                model.deleteSelected?()
            }
            .disabled(model.selectedIndices.count == 0)
        }
    }
    
    func selectedText() -> String {
        if model.selectedIndices.count == 1 {
            return "\(model.selectedIndices.count) Word Selected"
        } else {
            return "\(model.selectedIndices.count) Words Selected"
        }
    }
}
