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
    @State var present = false
    @State var presentingUUID: UUID?

    var body: some View {
        HStack {
            ToolbarIconButton(iconName: "doc.on.doc") {
                let words = model.selectedWords.map { $0.string }
                let string = words.joined(separator: ", ")
                let pasteboard = UIPasteboard.general

                pasteboard.string = string
                
                present = true
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
        .popover(
            present: $present,
            attributes: {
                $0.sourceFrameInset = UIEdgeInsets(16)
                $0.position = .relative(
                    popoverAnchors: [
                        .top,
                    ]
                )
                $0.presentation.animation = .spring()
                $0.presentation.transition = .move(edge: .top)
                $0.dismissal.animation = .spring(response: 3, dampingFraction: 0.8, blendDuration: 1)
                $0.dismissal.transition = .move(edge: .top)
                $0.dismissal.mode = [.dragUp]
                $0.dismissal.dragDismissalProximity = 0.1
            }
        ) {
            NotificationViewPopover(icon: "doc.on.doc", text: "Words copied!", color: Colors.accent)
                .onAppear {
                    presentingUUID = UUID()
                    let currentID = presentingUUID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        if currentID == presentingUUID {
                            present = false
                        }
                    }
                }
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
