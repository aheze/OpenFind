//
//  SettingsVC+Listen.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/5/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SupportDocs
import SwiftUI

extension SettingsViewController {
    func listen() {
        model.showHighlightColorPicker = { [weak self] in
            guard let self = self else { return }
            self.presentColorPicker()
        }

        SettingsData.resetAllSettings = { [weak self] in
            guard let self = self else { return }
            self.resetAllSettings()
        }

        SettingsData.deleteAllScannedData = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: "Delete All Scanned Data?", message: "Are you sure you want to delete all scanned data? This can't be undone.", preferredStyle: .actionSheet)
            alert.addAction(
                UIAlertAction(title: "Delete", style: .destructive) { _ in
                    ViewControllerCallback.deleteAllScannedData?(false)
                }
            )
            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { _ in }
            )

            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(
                    x: self.view.bounds.width / 2,
                    y: 50,
                    width: 1,
                    height: 1
                )
            }

            self.present(alert, animated: true, completion: nil)
        }

        SettingsData.shareLink = { [weak self] in
            guard let self = self else { return }
            self.shareLink()
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

        SettingsData.joinTheReddit = {
            if let url = URL(string: "https://www.reddit.com/r/findapp") {
                UIApplication.shared.open(url)
            }
        }
        
        SettingsData.translateFind = {
            if let url = URL(string: "https://getfind.app/translate") {
                UIApplication.shared.open(url)
            }
        }
        

        SettingsData.shareApp = { [weak self] in
            guard let self = self else { return }
            self.showShareApp()
        }
    }

    func shareLink() {
        guard let url = URL(string: "https://getfind.app/") else { return }
        UIPasteboard.general.url = url

        let tag = UUID().uuidString
        var attributes = Popover.Attributes()
        attributes.tag = tag
        attributes.position = .relative(popoverAnchors: [.top])
        attributes.sourceFrame = { [weak view] in view?.bounds ?? .zero }

        var insets = Global.safeAreaInsets
        insets.top += 16
        attributes.sourceFrameInset = insets

        attributes.presentation.animation = .spring()
        attributes.presentation.transition = .move(edge: .top)
        attributes.dismissal.animation = .spring(response: 3, dampingFraction: 0.8, blendDuration: 1)
        attributes.dismissal.transition = .move(edge: .top)

        let popover = Popover(attributes: attributes) {
            HStack {
                Image(systemName: "doc.on.doc")
                Text("Link Copied!")
            }
            .foregroundColor(.blue)
            .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
            .background(
                Capsule()
                    .fill(UIColor.systemBackground.color)
                    .shadow(
                        color: UIColor.label.color.opacity(0.1),
                        radius: 5,
                        x: 0,
                        y: 3
                    )
            )
        }

        self.present(popover)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let popover = self.view.popover(tagged: tag) {
                popover.dismiss()
            }
        }
    }

    func resetAllSettings() {
        let alert = UIAlertController(title: "Reset All Settings?", message: "Are you sure you want to reset all settings?", preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(title: "Reset", style: .default) { [weak self] action in
                guard let self = self else { return }
                self.realmModel.resetAllSettings()
            }
        )
        alert.addAction(
            UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        )
        
        if let popoverPresentationController = alert.popoverPresentationController {
            let sourceRect = CGRect(
                x: view.bounds.width / 2,
                y: 50,
                width: 1,
                height: 1
            )
            
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = sourceRect
            popoverPresentationController.permittedArrowDirections = .up
        }
        self.present(alert, animated: true, completion: nil)
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

    func getSupportDocs() -> UIViewController {
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
        return viewController
    }

    func showSupportDocs() {
        let viewController = self.getSupportDocs()
        self.present(viewController, animated: true)
    }

    func showShareApp() {
        let viewController = SettingsShareAppViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true)
    }
}

extension SettingsViewController: UIColorPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        realmModel.highlightsColor = Int(color.hex)
        realmModel.objectWillChange.send()
    }
}
