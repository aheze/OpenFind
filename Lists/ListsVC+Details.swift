//
//  ListsVC+Details.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ListsViewController {
    func presentDetails(list: List) {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let viewController: ListsDetailViewController = storyboard.instantiateViewController(identifier: "ListsDetailViewController") { coder in
            
            let listsDetailViewModel = ListsDetailViewModel(
                list: list,
                listUpdated: { [weak self] newList in
                    self?.realmModel.updateList(list: newList)
                    self?.listUpdated(list: newList)
                },
                listDeleted: { [weak self] listToDelete in
                    self?.realmModel.deleteList(list: listToDelete)
                    self?.listDeleted(list: listToDelete)
                },
                realmModel: self.realmModel
            )
            
            return ListsDetailViewController(
                coder: coder,
                model: listsDetailViewModel,
                toolbarViewModel: self.toolbarViewModel,
                searchViewModel: self.searchViewModel,
                realmModel: self.realmModel
            )
        }
        
        self.detailsViewController = viewController
        navigationController?.pushViewController(viewController, animated: true)
        
        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }
    }
}
