//
//  ListsVC+CV.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.displayedLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "Cell",
            for: indexPath
        ) as? ListsContentCell else {
            fatalError()
        }
        
        let list = model.displayedLists[indexPath.item].list
        let color = UIColor(hex: list.color)
        cell.headerView.backgroundColor = color
        cell.headerImageView.image = UIImage(systemName: list.icon)
        cell.headerTitleLabel.text = list.displayedName
        cell.headerDescriptionLabel.text = list.desc
        cell.layer.cornerRadius = ListsCellConstants.cornerRadius
        
        if color.isLight {
            cell.headerImageView.tintColor = ListsCellConstants.titleColorBlack
            cell.headerTitleLabel.textColor = ListsCellConstants.titleColorBlack
            cell.headerDescriptionLabel.textColor = ListsCellConstants.descriptionColorBlack
        } else {
            cell.headerImageView.tintColor = ListsCellConstants.titleColorWhite
            cell.headerTitleLabel.textColor = ListsCellConstants.titleColorWhite
            cell.headerDescriptionLabel.textColor = ListsCellConstants.titleColorWhite
        }
        
        if model.isSelecting {
            cell.chipsContainerView.isUserInteractionEnabled = false
            cell.headerSelectionIconView.isHidden = false
            cell.headerSelectionIconView.alpha = 1
            if model.selectedLists.contains(where: { $0.id == list.id }) {
                cell.headerSelectionIconView.setState(.selected)
            } else {
                cell.headerSelectionIconView.setState(.empty)
            }
        } else {
            cell.chipsContainerView.isUserInteractionEnabled = true
            cell.headerSelectionIconView.isHidden = true
            cell.headerSelectionIconView.alpha = 0
            cell.headerSelectionIconView.setState(.empty)
        }
        
        cell.tapped = { [weak self] in
            guard let self = self else { return }
            
            if self.model.isSelecting {
                if self.model.selectedLists.contains(where: { $0.id == list.id }) {
                    self.model.selectedLists = self.model.selectedLists.filter { $0.id != list.id }
                    cell.headerSelectionIconView.setState(.empty)
                } else {
                    self.model.selectedLists.append(list)
                    cell.headerSelectionIconView.setState(.selected)
                }
            } else {
                if let displayedList = self.model.displayedLists.first(where: { $0.list.id == list.id }) {
                    self.presentDetails(list: displayedList.list)
                }
            }
        }
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListsContentCell else {
            fatalError()
        }
        
        let displayedList = model.displayedLists[indexPath.item]
        addChipViews(to: cell, with: displayedList)
    }
    
    func addChipViews(to cell: ListsContentCell, with displayedList: DisplayedList) {
        cell.chipsContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let frame = displayedList.frame
        let color = UIColor(hex: displayedList.list.color)
        
        for chipFrame in frame.chipFrames {
            let chipView = ListChipView(type: chipFrame.chipType)
            chipView.frame = chipFrame.frame
            chipView.label.text = chipFrame.string
            chipView.color = color
            chipView.setColors()
            
            switch chipFrame.chipType {
            case .word:
                chipView.backgroundView.backgroundColor = ListsCellConstants.chipBackgroundColor
                chipView.tapped = { [weak self] in
                    if let displayedList = self?.model.displayedLists.first(where: { $0.list.id == displayedList.list.id }) {
                        self?.presentDetails(list: displayedList.list)
                    }
                }
            case .wordsLeft:
                chipView.backgroundView.backgroundColor = color.withAlphaComponent(0.1)
                chipView.tapped = { [weak self] in
                    if let displayedList = self?.model.displayedLists.first(where: { $0.list.id == displayedList.list.id }) {
                        self?.presentDetails(list: displayedList.list)
                    }
                }
            case .addWords:
                chipView.backgroundView.backgroundColor = color.withAlphaComponent(0.1)
                chipView.tapped = { [weak self] in
                    if let displayedList = self?.model.displayedLists.first(where: { $0.list.id == displayedList.list.id }) {
                        self?.presentDetails(list: displayedList.list, focusFirstWord: true)
                    }
                }
            }
            cell.chipsContainerView.addSubview(chipView)
        }
    }
    
    func updateCellColors() {
        for index in model.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                for case let subview as ListChipView in cell.chipsContainerView.subviews {
                    subview.setColors()
                }
            }
        }
    }
}
