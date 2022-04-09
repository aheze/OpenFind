//
//  SettingsVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SupportDocs
import UIKit

extension SettingsViewController {
    func listen() {
        presentationController?.delegate = self
        
        model.showHighlightColorPicker = { [weak self] in
            guard let self = self else { return }
            self.presentColorPicker()
        }

        SettingsData.resetAllSettings = { [weak self] in
            guard let self = self else { return }
            self.realmModel.resetAllSettings()
        }
        
        SettingsData.shareLink = { [weak self] in
            guard let self = self else { return }
            self.presentShareScreen()
        }

        SettingsData.rateTheApp = {
            guard let url = URL(string: "https://apps.apple.com/app/id1506500202") else { return }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)

            components?.queryItems = [
                URLQueryItem(name: "action", value: "write-review")
            ]

            guard let writeReviewURL = components?.url else { return }
            UIApplication.shared.open(writeReviewURL)
        }
        SettingsData.reportABug = {
            if let url = URL(string: "https://forms.gle/d4yb8tyfkCsY4rFn6") {
                UIApplication.shared.open(url)
            }
        }
        SettingsData.suggestNewFeatures = {
            if let url = URL(string: "https://forms.gle/pQrSyRnp9ZP7SJXdA") {
                UIApplication.shared.open(url)
            }
        }
        SettingsData.helpCenter = { [weak self] in
            guard let self = self else { return }
            self.showSupportDocs()
        }
        SettingsData.joinTheDiscord = {
            if let url = URL(string: "https://discord.com/invite/UJpHv8jmN5") {
                UIApplication.shared.open(url)
            }
        }
    }

    func presentShareScreen() {
        guard let url = URL(string: "https://getfind.app/") else { return }
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: 10, y: self.view.bounds.height - 50, width: 20, height: 20)
            popoverController.sourceView = self.view
        }

        self.present(activityViewController, animated: true)
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
    
    
    func showSupportDocs() {
        let dataSource = URL(string: "https://raw.githubusercontent.com/aheze/FindInfo/DataSource/_data/supportdocs_datasource.json")!
        let options = SupportOptions(
            categories: [
                .init(tag: "general", displayName: "General"),
                .init(tag: "photos", displayName: "Photos"),
                .init(tag: "camera", displayName: "Camera"),
                .init(tag: "lists", displayName: "Lists")
            ],
            navigationBar: .init(
                title: "Help Center",
                titleColor: .white,
                dismissButtonTitle: "Done",
                buttonTintColor: .white,
                backgroundColor: UIColor(hex: 0x44AB00)
            ),
            searchBar: .init(
                placeholder: "Find Articles",
                placeholderColor: UIColor.white.withAlphaComponent(0.75),
                textColor: .white,
                tintColor: .white,
                backgroundColor: UIColor.white.withAlphaComponent(0.3),
                clearButtonMode: .whileEditing
            ),
            progressBar: .init(
                foregroundColor: .white,
                backgroundColor: .clear
            ),
            listStyle: .insetGroupedListStyle,
            navigationViewStyle: .defaultNavigationViewStyle,
            other: .init(
                activityIndicatorStyle: UIActivityIndicatorView.Style.large,
                error404: URL(string: "https://aheze.github.io/FindInfo/404")!
            )
        )
        
        let viewController = SupportDocsViewController(dataSourceURL: dataSource, options: options)
        self.present(viewController, animated: true)
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        realmModel.highlightsColor = Int(color.hex)
        realmModel.objectWillChange.send()
    }
}

extension SettingsViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        mainViewController.searchViewModel.dismissKeyboard?()
        model.startedToDismiss?()
    }
}
