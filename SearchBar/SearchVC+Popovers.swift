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
        let field = searchViewModel.fields[index]
        switch field.value {
        case .word(let word):

            let model = FieldSettingsModel()
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

            let configuration = self.searchViewModel.configuration
            var popover = Popover { FieldSettingsView(model: model, configuration: configuration) }
            popover.attributes.rubberBandingMode = .none
            popover.attributes.sourceFrame = { cell.windowFrame() }
            popover.attributes.sourceFrameInset.bottom = 8
            popover.attributes.position = .absolute(originAnchor: .bottomLeft, popoverAnchor: .topLeft)
            present(popover)
        case .list(let list):
            let model = FieldSettingsModel()
            model.header = "LIST"
            model.defaultColor = UIColor(hex: list.color)
            model.selectedColor = field.overrides.selectedColor
            model.alpha = field.overrides.alpha
            model.words = list.words
            model.editListPressed = {
                ViewControllerCallback.showList?(list)
            }
            model.changed = { [weak self] in
                guard let self = self else { return }
                var field = self.searchViewModel.fields[index]
                field.overrides.selectedColor = model.selectedColor
                field.overrides.alpha = model.alpha
                self.searchViewModel.updateField(at: index, with: field, notify: true)
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.leftView.imageView.tintColor = UIColor.white.toColor(model.selectedColor ?? UIColor(hex: list.color), percentage: model.alpha)
                }
            }

            let configuration = self.searchViewModel.configuration
            var popover = Popover { FieldSettingsView(model: model, configuration: configuration) }
            popover.attributes.rubberBandingMode = .none
            popover.attributes.sourceFrame = { cell.windowFrame() }
            popover.attributes.sourceFrameInset.bottom = 8
            popover.attributes.position = .absolute(originAnchor: .bottomLeft, popoverAnchor: .topLeft)
            present(popover)
        case .addNew:
            break
        }
    }
}
