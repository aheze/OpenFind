//
//  ListsDetailVC+DataSource.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit


extension ListsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.list.words.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListsDetailWordCell",
            for: indexPath
        ) as? ListsDetailWordCell else {
            fatalError()
        }

        /// basics
        let word = model.list.words[indexPath.item]
        cell.textField.text = word.string
        cell.leftView.isHidden = true
        cell.rightView.isHidden = true

        if model.selectedWords.contains(where: { $0.id == word.id }) {
            cell.leftSelectionIconView.setState(.selected)
        } else {
            cell.leftSelectionIconView.setState(.empty)
        }

        /// set the toolbar
        cell.textField.inputAccessoryView = wordsKeyboardToolbarViewController.view
        
        cell.startedEditing = { [weak self] in
            guard let self = self else { return }
            if let index = self.model.list.words.firstIndex(where: { $0.id == word.id }) {
                self.wordsKeyboardToolbarViewModel.selectedWordIndex = index

                if self.model.activeWord == nil {
                    /// Wait for the keyboard to show if no word selected yet
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.scrollToCell(at: index)
                    }
                } else {
                    
                    /// otherwise, directly scroll
                    self.scrollToCell(at: index)
                }
                
                self.model.activeWord = word
            }
        }
        cell.finishedEditing = { [weak self] in
            guard let self = self else { return }
            self.model.activeWord = nil
        }

        cell.leftViewTapped = { [weak self] in
            guard let self = self else { return }
            if self.model.selectedWords.contains(where: { $0.id == word.id }) {
                self.model.selectedWords = self.model.selectedWords.filter { $0.id != word.id }
                cell.leftSelectionIconView.setState(.empty)
            } else {
                self.model.selectedWords.append(word)
                cell.leftSelectionIconView.setState(.selected)
            }
        }
        cell.textChanged = { [weak self] newText, replacementString in
            guard let self = self else { return true }

            let newWords = replacementString
                .components(separatedBy: "•")
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

            /// a new bullet-separated string was pasted
            if newWords.count > 1 {
                /// index of cell where the paste occurred
                if let index = self.model.list.words.firstIndex(where: { $0.id == word.id }) {
                    /// if empty, replace cell text with the first new word
                    if self.model.list.words[index].string.isEmpty {
                        cell.textField.text = newWords[0]
                        self.model.list.words[index].string = newWords[0]

                        let wordsToAdd = Array(newWords.dropFirst())
                        self.addWords(words: wordsToAdd, originIndex: index)

                    } else {
                        /// else, just append all the new words
                        self.addWords(words: newWords, originIndex: index)
                    }

                    self.updateTableViewHeightConstraint()

                    return false
                }
            } else {
                /// normal text update.
                if let index = self.model.list.words.firstIndex(where: { $0.id == word.id }) {
                    self.model.list.words[index].string = newText
                }
            }

            return true
        }

        /// configure which parts of the cell are visible
        if model.isEditing {
            cell.stackViewLeftC.constant = 0
            cell.stackViewRightC.constant = 0
            cell.leftView.isHidden = false
            cell.rightView.isHidden = false
        } else {
            cell.stackViewLeftC.constant = ListsDetailConstants.listRowContentEdgeInsets.left
            cell.stackViewRightC.constant = ListsDetailConstants.listRowContentEdgeInsets.right
            cell.leftView.isHidden = true
            cell.rightView.isHidden = true
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListsDetailConstants.wordRowHeight
    }
}
