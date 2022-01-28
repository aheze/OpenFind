//
//  ListsDetailVC+IconPicker.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension ListsDetailViewController {
    func presentIconPicker() {
        if #available(iOS 15.0, *) {
            if let presentationController = self.iconPicker.searchNavigationController.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
        }
        self.present(self.iconPicker.searchNavigationController, animated: true)
        self.headerTopLeftIconPickerModel.selectedIcon = self.model.list.image
        self.headerTopLeftIconPickerModel.iconChanged = { [weak self] icon in
            self?.model.list.image = icon
        }
    }
}
