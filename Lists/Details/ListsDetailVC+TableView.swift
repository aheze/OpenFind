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
        wordsTableViewHeightC.constant = ListsDetailConstants.wordRowHeight * CGFloat(list.contents.count)
    }
}

extension ListsDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ListsDetailWordCell",
            for: indexPath
        ) as? ListsDetailWordCell else {
            fatalError()
        }
        
        let word = list.contents[indexPath.item]
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
