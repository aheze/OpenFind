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
        let viewController = storyboard.instantiateViewController(identifier: "ListsDetailViewController") { coder in
            ListsDetailViewController(
                coder: coder,
                list: list,
                realmModel: self.realmModel,
                toolbarViewModel: self.toolbarViewModel,
                listUpdated: { [weak self] newList in
                    self?.realmModel.updateList(list: newList)
                    self?.listUpdated(list: newList)
                },
                searchConfiguration: self.searchConfiguration
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
