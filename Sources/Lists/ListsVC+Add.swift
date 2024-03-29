//
//  ListsVC+Add.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func addNewList() {
        DispatchQueue.main.async {
            let newList = List()
            self.realmModel.container.addList(list: newList)
            self.reloadDisplayedLists()
            self.update()
            self.presentDetails(list: newList)
            self.realmModel.incrementExperience(by: 5)
        }
    }

    func importList(list: List) {
        let viewController = ListsImportViewController(list: list) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                var newList = list
                newList.id = UUID()
                self.realmModel.container.addList(list: newList)
                self.reloadDisplayedLists()
                self.update()
                if let index = self.model.displayedLists.firstIndex(where: { $0.list.id == newList.id }) {
                    self.collectionView.scrollToItem(at: index.indexPath, at: .centeredVertically, animated: true)
                }
                self.realmModel.incrementExperience(by: 4)
            }
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        if #available(iOS 15.0, *) {
            if let presentationController = navigationController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium()]
            }
        }
        
        self.dismiss(animated: true) /// dismiss currently-visible view controllers, like Settings
        self.present(navigationController, animated: true)
    }
}
