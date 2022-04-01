//
//  ListsVC+Details.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ListsViewController {
    func presentDetails(list: List, focusFirstWord: Bool = false) {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let listsDetailViewModel = ListsDetailViewModel(
            list: list,
            listUpdated: { [weak self] newList in
                self?.realmModel.container.updateList(list: newList)
                self?.listUpdated(list: newList)
            },
            listDeleted: { [weak self] listToDelete in
                self?.realmModel.container.deleteList(list: listToDelete)
                self?.listDeleted(list: listToDelete)
            },
            realmModel: self.realmModel
        )
        
        listsDetailViewModel.focusFirstWord = focusFirstWord
        let viewController: ListsDetailViewController = storyboard.instantiateViewController(identifier: "ListsDetailViewController") { coder in
            
            let viewController = ListsDetailViewController(
                coder: coder,
                model: listsDetailViewModel,
                tabViewModel: self.tabViewModel,
                toolbarViewModel: self.toolbarViewModel,
                realmModel: self.realmModel
            )
            
            return viewController
        }
        
        /// keep it up to date. replacing!
        
        self.detailsViewController = viewController
        navigationController?.pushViewController(viewController, animated: true)
        
        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }
    }
}
