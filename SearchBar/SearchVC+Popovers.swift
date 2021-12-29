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
//        field.text.value
//        class FieldSettingsModel: ObservableObject {
//            @Published var header = "WORD"
//            @Published var defaultColor: UIColor = UIColor(hex: 0x00aeef)
//            @Published var selectedColor: UIColor = UIColor(hex: 0x00aeef)
//            @Published var alpha: CGFloat = 1
//
//            /// lists
//            @Published var words = [String]()
//            @Published var showingWords = false
//            @Published var editListPressed: (() -> Void)?
//        }
        let field = searchViewModel.fields[index]
        switch field.text.value {
        case .string(_):
//            string.
            let model = FieldSettingsModel()
            model.header = "WORD"
            model.defaultColor = field.text.defaultColor
            model.selectedColor = field.text.selectedColor
            model.alpha = field.text.colorAlpha
            
            model.changed = { [weak self] in
                guard let self = self else { return }
                self.searchViewModel.fields[index].text.defaultColor = model.defaultColor
                self.searchViewModel.fields[index].text.selectedColor = model.selectedColor
                self.searchViewModel.fields[index].text.colorAlpha = model.alpha
                if let cell = self.searchCollectionView.cellForItem(at: index.indexPath) as? SearchFieldCell {
                    cell.leftView.findIconView.setTint(color: model.selectedColor ?? model.defaultColor, alpha: model.alpha)
                }
            }
            
            var popover = Popover { FieldSettingsView(model: model) }
            popover.attributes.sourceFrame = { cell.windowFrame() }
            popover.attributes.sourceFrameInset.bottom = 8
            popover.attributes.position = .absolute(originAnchor: .bottomLeft, popoverAnchor: .topLeft)
            Popovers.present(popover)
        case .list(_):
//            list.
            break
        case .addNew:
            break
        }
    }
}
    
