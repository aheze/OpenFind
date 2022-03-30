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
        let newList = List()
        realmModel.addList(list: newList)
        reloadDisplayedLists()
        update()
        presentDetails(list: newList)
    }

    func importList(list: List) {
        let viewController = ListsImportViewController(list: list) { [weak self] in
            guard let self = self else { return }
            var newList = list
            newList.id = UUID()
            self.realmModel.addList(list: newList)
            self.reloadDisplayedLists()
            self.update()
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        if #available(iOS 15.0, *) {
            if let presentationController = navigationController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
        }
        self.present(navigationController, animated: true)
    }
}
