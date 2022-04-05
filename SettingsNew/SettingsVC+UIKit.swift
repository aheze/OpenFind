//
//  SettingsVC+UIKit.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension SettingsViewController {
    func presentColorPicker() {
        if #available(iOS 14.0, *) {
            let colorPicker = UIColorPickerViewController()

            if #available(iOS 15.0, *) {
                if let presentationController = colorPicker.presentationController as? UISheetPresentationController {
                    presentationController.detents = [.medium(), .large()]
                }
            }

            self.present(colorPicker, animated: true)
            colorPicker.selectedColor = UIColor(hex: UInt(model.highlightsColor))
            colorPicker.supportsAlpha = false
            colorPicker.delegate = self
        } else {
            let colorPicker = ColorPickerNavigationViewController(model: self.colorPickerViewModel)
            self.present(colorPicker, animated: true)
        }
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        model.highlightsColor = Int(color.hex)
    }
}
