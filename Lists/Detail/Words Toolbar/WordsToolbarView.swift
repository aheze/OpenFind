//
//  WordsKeyboardToolbarView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

struct WordsToolbarView: View {
    @ObservedObject var model: WordsKeyboardToolbarViewModel

    var body: some View {
        HStack {
            Button {
                model.goToIndex?(model.selectedWordIndex - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .frame(width: 40)
            .disabled(model.selectedWordIndex == 0)

            Text("\(model.selectedWordIndex + 1) / \(model.totalWordsCount)")
                .font(.body.bold())
                .accessibility(hint: "\(model.selectedWordIndex + 1) out of \(model.totalWordsCount)".text)

            Button {
                model.goToIndex?(model.selectedWordIndex + 1)
            } label: {
                Image(systemName: "chevron.right")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .frame(width: 40)
            .disabled(model.selectedWordIndex == model.totalWordsCount - 1)

            Spacer()

            Button {
                model.addWordAfterIndex?(model.selectedWordIndex)
            } label: {
                Image(systemName: "plus")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .accessibility(hint: "Add word below".text)
            .frame(width: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            VisualEffectView(.systemChromeMaterial)
                .edgesIgnoringSafeArea(.all)
        )
    }
}


