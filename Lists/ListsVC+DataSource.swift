//
//  ListsVC+CV.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension ListsViewController {
    func update(animate: Bool = true) {
        var snapshot = Snapshot()
        let section = DataSourceSectionTemplate()
        snapshot.appendSections([section])
        snapshot.appendItems(model.displayedLists, toSection: section)
        dataSource.apply(snapshot, animatingDifferences: animate)

//        showEmptyContent(model.displayedSections.isEmpty)
//        updateViewsEnabled()
    }
    
    /// reload the collection view at an index path.
    func update(at indexPath: IndexPath, with list: List) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
            self.configureCellData(cell: cell, list: list)
        }
    }
    
    func configureCellData(cell: ListsContentCell, list: List) {
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
    }

    func configureCellSelection(cell: ListsContentCell, selected: Bool) {
        cell.contentView.isUserInteractionEnabled = !self.model.isSelecting
        if self.model.isSelecting {
            cell.headerSelectionIconView.isHidden = false
            cell.headerSelectionIconView.alpha = 1
            if selected {
                cell.headerSelectionIconView.setState(.selected)
            } else {
                cell.headerSelectionIconView.setState(.empty)
            }
        } else {
            cell.headerSelectionIconView.isHidden = true
            cell.headerSelectionIconView.alpha = 0
            cell.headerSelectionIconView.setState(.empty)
        }
    }

    func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, cachedDisplayedList -> UICollectionViewCell? in

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "Cell",
                for: indexPath
            ) as! ListsContentCell
            
            guard let displayedList = self.model.displayedLists.first(where: { $0.list.id == cachedDisplayedList.list.id }) else { return cell }
            let list = displayedList.list
            
            self.configureCellData(cell: cell, list: list)
            let selected = self.model.selectedLists.contains(where: { $0.id == list.id })
            self.configureCellSelection(cell: cell, selected: selected)
            
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
        
        return dataSource
    }
}

extension ListsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? ListsContentCell else {
            fatalError()
        }
        
        let displayedList = model.displayedLists[indexPath.item]
        self.addChipViews(to: cell, with: displayedList)
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
