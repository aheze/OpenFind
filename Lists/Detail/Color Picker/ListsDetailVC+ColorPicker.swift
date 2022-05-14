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
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController()

            if #available(iOS 15.0, *) {
                if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium(), .large()]
                }
            }

            colorPicker.selectedColor = UIColor(hex: model.list.color)
            colorPicker.supportsAlpha = false
            colorPicker.delegate = self

            self.present(colorPicker, animated: true)
        } else {
            self.headerTopRightColorPickerModel.selectedColorChanged = { [weak self] in
                guard let self = self else { return }
                let color = self.headerTopRightColorPickerModel.selectedColor
                self.model.list.color = color.hex
                self.loadListContents()
            }
            let colorPicker = ColorPickerNavigationViewController(model: self.headerTopRightColorPickerModel)
            self.present(colorPicker, animated: true)
        }
    }
}

extension ListsDetailViewController: UIColorPickerViewControllerDelegate {
    /// This is called in iOS 15
    @available(iOS 15.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        model.list.color = color.hex
        loadListContents()
    }

    /// This is called in iOS 14
    @available(iOS 14.0, *)
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if #available(iOS 15.0, *) { } else {
            let color = viewController.selectedColor
            model.list.color = color.hex
            loadListContents()
        }
    }
}
