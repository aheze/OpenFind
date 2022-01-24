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
        return model.editableWords.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListsDetailWordCell",
            for: indexPath
        ) as? ListsDetailWordCell else {
            fatalError()
        }
        
        let word = model.editableWords[indexPath.item]
        cell.textField.text = word.string
        cell.leftView.isHidden = true
        cell.rightView.isHidden = true
        
        if model.selectedIndices.contains(indexPath.item) {
            cell.leftSelectionIconView.setState(.selected)
        } else {
            cell.leftSelectionIconView.setState(.empty)
        }
        
        cell.leftViewTapped = { [weak self] in
            guard let self = self else { return }
            if let index = self.model.editableWords.firstIndex(where: { $0.id == word.id }) {
                if self.model.selectedIndices.contains(index) {
                    self.model.selectedIndices = self.model.selectedIndices.filter { $0 != index }
                    cell.leftSelectionIconView.setState(.empty)
                } else {
                    self.model.selectedIndices.append(index)
                    cell.leftSelectionIconView.setState(.selected)
                }
            }
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
