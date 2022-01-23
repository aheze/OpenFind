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
        let wordHeight = ListsDetailConstants.wordRowHeight * CGFloat(model.list.contents.count)
        let height = edgePadding + wordHeight
        wordsTableViewHeightC.constant = height
    }
}

extension ListsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.list.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListsDetailWordCell",
            for: indexPath
        ) as? ListsDetailWordCell else {
            fatalError()
        }
        
        let word = model.list.contents[indexPath.item]
        cell.textField.text = word
        cell.leftView.isHidden = true
        cell.rightView.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListsDetailConstants.wordRowHeight
    }
    
}

extension ListsDetailViewController: UITableViewDelegate {
    
}
