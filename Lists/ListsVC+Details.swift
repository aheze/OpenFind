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
        
        /// iPad
        if traitCollection.horizontalSizeClass == .regular, traitCollection.verticalSizeClass == .regular {
            let toolbarViewModel = ToolbarViewModel()
            let viewController = self.getDetailViewController(toolbarViewModel: toolbarViewModel, list: list, focusFirstWord: focusFirstWord, addDismissButton: true)
            self.detailsViewController = viewController
            
            let navigationController = UINavigationController(rootViewController: viewController)
            let toolbarController = ToolbarController.make(model: toolbarViewModel, rootViewController: navigationController)
            self.present(toolbarController, animated: true)
            
            toolbarViewModel.didDismiss = { [weak self] in
                guard let self = self else { return }
                print("did dismiss received!")
                self.reloadDisplayedLists()
                self.update()
                if let index = self.model.displayedLists.firstIndex(where: { $0.list.id == list.id }) {
                    self.collectionView.scrollToItem(at: index.indexPath, at: .centeredVertically, animated: true)
                }
            }
        } else {
            let viewController = self.getDetailViewController(toolbarViewModel: toolbarViewModel, list: list, focusFirstWord: focusFirstWord, addDismissButton: false)
            self.detailsViewController = viewController
            
            navigationController?.pushViewController(viewController, animated: true)
            viewController.updateSearchBarOffset = { [weak self] in
                guard let self = self else { return }
                self.updateNavigationBar?()
            }
        }
    }
    
    func getDetailViewController(toolbarViewModel: ToolbarViewModel, list: List, focusFirstWord: Bool, addDismissButton: Bool) -> ListsDetailViewController {
        let storyboard = UIStoryboard(name: "ListsContent", bundle: nil)
        let listsDetailViewModel = ListsDetailViewModel(
            list: list,
            listUpdated: { [weak self] newList, finalUpdate in
                guard let self = self else { return }
                self.realmModel.container.updateList(list: newList)
                self.listUpdated(list: newList)
                
                if finalUpdate {
                    self.reloadDisplayedLists()
                    self.update()
                    if let index = self.model.displayedLists.firstIndex(where: { $0.list.id == newList.id }) {
                        self.collectionView.scrollToItem(at: index.indexPath, at: .centeredVertically, animated: true)
                    }
                }
            },
            listDeleted: { [weak self] listToDelete in
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
                toolbarViewModel: toolbarViewModel,
                realmModel: self.realmModel
            )
        }
        return viewController
    }
}
