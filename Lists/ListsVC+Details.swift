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
        /// keep it up to date. replacing!
        
        let viewController = self.getDetailViewController(list: list, focusFirstWord: focusFirstWord, addDismissButton: false)
        self.detailsViewController = viewController
        navigationController?.pushViewController(viewController, animated: true)
        
        viewController.updateSearchBarOffset = { [weak self] in
            guard let self = self else { return }
            self.updateNavigationBar?()
        }
    }
    
    func getDetailViewController(list: List, focusFirstWord: Bool, addDismissButton: Bool) -> ListsDetailViewController {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let listsDetailViewModel = ListsDetailViewModel(
            list: list,
            listUpdated: { [weak self] newList in
                self?.realmModel.container.updateList(list: newList)
                self?.listUpdated(list: newList)
            },
            listDeleted: { [weak self] listToDelete in
                print("deleting.")
                self?.realmModel.container.deleteList(list: listToDelete)
                self?.listDeleted(list: listToDelete)
            },
            realmModel: self.realmModel
        )
        
        listsDetailViewModel.focusFirstWord = focusFirstWord
        listsDetailViewModel.addDismissButton = addDismissButton
        let viewController: ListsDetailViewController = storyboard.instantiateViewController(identifier: "ListsDetailViewController") { coder in
            
            ListsDetailViewController(
                coder: coder,
                model: listsDetailViewModel,
                tabViewModel: self.tabViewModel,
                toolbarViewModel: self.toolbarViewModel,
                realmModel: self.realmModel
            )
        }
        return viewController
    }
}
