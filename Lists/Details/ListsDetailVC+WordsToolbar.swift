//
//  ListsDetailVC+WordsToolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func listenToWordsToolbar() {
        /// toolbar
        wordsKeyboardToolbarViewModel.goToIndex = { [weak self] index in
            guard let self = self else { return }
            self.focusCell(at: index)
            self.scrollToCell(at: index)
        }

        wordsKeyboardToolbarViewModel.addWordAfterIndex = { [weak self] index in
            guard let self = self else { return }
            let newIndex = index + 1
            self.addWord(at: newIndex)
            self.focusCell(at: newIndex)
            self.updateTableViewHeightConstraint()
        }
    }

    func updateWordsKeyboardToolbar() {
        if
            let word = model.activeWord,
            let index = model.list.words.firstIndex(where: { $0.id == word.id })
        {
            wordsKeyboardToolbarViewModel.selectedWordIndex = index
        }
        wordsKeyboardToolbarViewModel.totalWordsCount = model.list.words.count
    }

    func reloadWordsToolbarFrame(keyboardShown: Bool) {
        if
            let word = model.activeWord,
            let index = model.list.words.firstIndex(where: { $0.id == word.id }),
            let cell = wordsTableView.cellForRow(at: index.indexPath) as? ListsDetailWordCell
        {
            if wordsKeyboardToolbarViewController.reloadFrame(keyboardShown: keyboardShown) {
                cell.textField.reloadInputViews()
            }
        }
    }
}
