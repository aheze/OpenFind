//
//  SettingsVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension SettingsViewController {
    func listen() {
        model.showHighlightColorPicker = { [weak self] in
            guard let self = self else { return }
            self.presentColorPicker()
        }
        model.showScanningOptions = { [weak self] in
            guard let self = self else { return }
            
        }
    }

    func presentColorPicker() {
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController()

            if #available(iOS 15.0, *) {
                if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium(), .large()]
                }
            }

            self.present(colorPicker, animated: true)
            colorPicker.selectedColor = UIColor(hex: UInt(realmModel.highlightsColor))
            colorPicker.supportsAlpha = false
            colorPicker.delegate = self
        } else {
            self.colorPickerViewModel.selectedColorChanged = { [weak self] in
                guard let self = self else { return }
                let color = self.colorPickerViewModel.selectedColor
                self.realmModel.highlightsColor = Int(color.hex)
                self.realmModel.objectWillChange.send()
            }
            let colorPicker = ColorPickerNavigationViewController(model: self.colorPickerViewModel)
            self.present(colorPicker, animated: true)
        }
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        realmModel.highlightsColor = Int(color.hex)
        realmModel.objectWillChange.send()
    }
}
