//
//  SearchVC+Popovers.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//

import Popovers
import UIKit

extension SearchViewController {
    func presentPopover(for index: Int, from cell: UICollectionViewCell) {
        let popover = getPopover(for: index, from: cell)
        if let existingPopover = view.popover(tagged: PopoverIdentifier.fieldSettingsIdentifier) {
            replace(existingPopover, with: popover)
        } else {
            present(popover)
        }
    }

    func getPopover(for index: Int, from cell: UICollectionViewCell) -> Popover {
        let model = FieldSettingsModel()

        let field = searchViewModel.fields[index]
        switch field.value {
        case .word(let word):

            model.header = "WORD"
            model.defaultColor = UIColor(hex: word.color)
            model.selectedColor = field.overrides.selectedColor
            model.alpha = field.overrides.alpha
            model.changed = { [weak self] in
                guard let self = self else { return }
                var field = self.searchViewModel.fields[index]
                field.overrides.selectedColor = model.selectedColor
                field.overrides.alpha = model.alpha
                self.searchViewModel.updateField(at: index, with: field, notify: true)

                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.leftView.findIconView.setTint(color: model.selectedColor ?? model.defaultColor, alpha: model.alpha)
                }
            }

        case .list(let list, _):

            model.header = "LIST"
            model.defaultColor = UIColor(hex: list.color)
            model.selectedColor = field.overrides.selectedColor
            model.alpha = field.overrides.alpha
            model.words = list.words
            model.editListPressed = { [weak self] in
                guard let self = self else { return }
                if let existingPopover = self.view.popover(tagged: PopoverIdentifier.fieldSettingsIdentifier) {
                    existingPopover.dismiss()
                }
                guard let viewController = ViewControllerCallback.getListDetailController?(list) else { return }
                let navigationController = UINavigationController(rootViewController: viewController)
                self.present(navigationController, animated: true)
            }
            model.changed = { [weak self] in
                guard let self = self else { return }
                var field = self.searchViewModel.fields[index]
                field.overrides.selectedColor = model.selectedColor
                field.overrides.alpha = model.alpha
                self.searchViewModel.updateField(at: index, with: field, notify: true)
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    let color = field.overrides.selectedColor ?? UIColor(hex: list.color)
                    let textColor = color.getTextColor(backgroundIsDark: true)
                    cell.leftView.imageView.tintColor = UIColor.white.toColor(textColor, percentage: field.overrides.alpha)
                }
            }

        case .addNew:
            break
        }

        let configuration = searchViewModel.configuration
        var popover = Popover { FieldSettingsView(model: model, configuration: configuration) }
        popover.attributes.rubberBandingMode = .none
        popover.attributes.sourceFrame = { cell.windowFrame() }
        popover.attributes.sourceFrameInset.bottom = 8
        popover.attributes.position = .absolute(originAnchor: .bottomLeft, popoverAnchor: .topLeft)
        popover.attributes.tag = PopoverIdentifier.fieldSettingsIdentifier

        return popover
    }
}


