//
//  ListsDetailVC+Add.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func addWord(at index: Int = 0) {
        let newWord = EditableWord(string: "")
        model.list.words.insert(newWord, at: index)
        wordsTableView.insertRows(at: [index.indexPath], with: .automatic)
        updateWordsKeyboardToolbar()
    }

    func addWords(words: [String], originIndex: Int) {
        var newWords = [EditableWord]()
        var indices = [Int]()
        for (index, word) in words.enumerated() {
            let editableWord = EditableWord(string: word)
            newWords.append(editableWord)
            indices.append(index)
        }

        model.list.words.insert(contentsOf: newWords, at: originIndex + 1)
        let newWordsIndices = indices.map { (originIndex + 1 + $0).indexPath }

        wordsTableView.insertRows(at: newWordsIndices, with: .automatic)
        updateWordsKeyboardToolbar()

        realmModel.incrementExperience(by: 4)
    }
}

extension ListsDetailViewController {
    func updateTableViewHeightConstraint(animated: Bool = true) {
        let edgePadding = ListsDetailConstants.listSpacing
        let wordHeight = ListsDetailConstants.wordRowHeight * CGFloat(model.list.words.count)
        let height = edgePadding + wordHeight
        wordsTableViewHeightC.constant = height

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded() /// must be `view` for a smooth animation
            }
        }
    }
}
