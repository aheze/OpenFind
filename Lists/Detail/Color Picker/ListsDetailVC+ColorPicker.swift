//
//  ListsDetailVC+ColorPicker.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsDetailViewController {
    func presentColorPicker() {
//        if #available(iOS 14.0, *) {
//            let colorPicker = UIColorPickerViewController()
//
//            if #available(iOS 15.0, *) {
//                if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
//                    presentationController.detents = [.medium(), .large()]
//                }
//            }
//
//            self.present(colorPicker, animated: true)
//            colorPicker.selectedColor = UIColor(hex: model.list.color)
//            colorPicker.supportsAlpha = false
//            colorPicker.delegate = self
//        } else {
        self.headerTopRightColorPickerModel.selectedColorChanged = { [weak self] in
            guard let self = self else { return }

            let color = self.headerTopRightColorPickerModel.selectedColor
            print("change!!!: \(color) ->>> \(color.hex)")
            self.model.list.color = color.hex
            self.loadListContents()
        }
        let colorPicker = ColorPickerNavigationViewController(model: self.headerTopRightColorPickerModel)
        if #available(iOS 15.0, *) {
            if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
                presentationController.detents = [.medium(), .large()]
            }
        }
        self.present(colorPicker, animated: true)
//        }
    }
}

extension ListsDetailViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        model.list.color = color.hex
        loadListContents()
    }
}
