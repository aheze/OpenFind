//
//  ListsDetailVC+Add.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit


extension ListsDetailViewController {
    func addPressed() {
        let newWord = ""
        model.list.words.insert(newWord, at: 0)
        wordsTableView.insertRows(at: [0.indexPath], with: .automatic)
        updateTableViewHeightConstraint()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded() /// must be `view` for a smooth animation
        }
    }
}

extension ListsDetailViewController {
    func updateTableViewHeightConstraint() {
        let edgePadding = ListsDetailConstants.listSpacing
        let wordHeight = ListsDetailConstants.wordRowHeight * CGFloat(model.list.words.count)
        let height = edgePadding + wordHeight
        wordsTableViewHeightC.constant = height
    }
}
