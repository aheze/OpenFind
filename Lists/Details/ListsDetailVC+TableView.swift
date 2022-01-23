//
//  ListsDetailVC+TableView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsDetailViewController {
    func updateTableViewHeightConstraint() {
        let edgePadding = ListsDetailConstants.listSpacing
        let wordHeight = ListsDetailConstants.wordRowHeight * CGFloat(model.list.words.count)
        let height = edgePadding + wordHeight
        wordsTableViewHeightC.constant = height
    }
}

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
        
        let word = model.list.words[indexPath.item]
        cell.textField.text = word
        cell.leftView.isHidden = true
        cell.rightView.isHidden = true
        
        if model.selectedIndices.contains(indexPath.item) {
            cell.leftSelectionIconView.setState(.selected)
        } else {
            cell.leftSelectionIconView.setState(.empty)
        }
        
        cell.leftViewTapped = { [weak self] in
            guard let self = self else { return }
            if self.model.selectedIndices.contains(indexPath.item) {
                self.model.selectedIndices = self.model.selectedIndices.filter { $0 != indexPath.item }
                cell.leftSelectionIconView.setState(.empty)
            } else {
                self.model.selectedIndices.append(indexPath.item)
                cell.leftSelectionIconView.setState(.selected)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListsDetailConstants.wordRowHeight
    }
    
}

extension ListsDetailViewController: UITableViewDelegate {
    
}
