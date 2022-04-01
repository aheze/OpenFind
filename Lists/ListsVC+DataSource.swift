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

//        Thread 1: "Diffable data source detected item identifiers that are equal but have different hash values. Two identifiers which compare as equal must return the same hash value. You must fix this in the Hashable (Swift) or hash property (Objective-C) implementation for the type of these identifiers. Identifiers that are equal but have different hash values: (Find_New.DisplayedList(list: Find_New.List(id: C096B168-A362-418E-B9CB-CCC46F4412CC, title: \"my list\", description: \"\", icon: \"bubble.left\", color: 4286779648, words: [\"a\", \"name\", \"typo\"], dateCreated: 2022-03-30 17:04:35 +0000), frame: Find_New.ListFrame(chipFrames: []))) and (Find_New.DisplayedList(list: Find_New.List(id: C096B168-A362-418E-B9CB-CCC46F4412CC, title: \"my list\", description: \"\", icon: \"bubble.left\", color: 4278190080, words: [\"and Dbd\", \"name\", \"typo\"], dateCreated: 2022-03-30 17:04:35 +0000), frame: Find_New.ListFrame(chipFrames: [])))"
        
//        showEmptyContent(model.displayedSections.isEmpty)
//        updateViewsEnabled()
    }
    
    /// reload the collection view at an index path.
    func update(at indexPath: IndexPath, with displayedList: DisplayedList) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ListsContentCell {
            cell.view.configureData(list: displayedList.list)
            
            DispatchQueue.main.async {
                let (_, columnWidth) = self.listsFlowLayout.getColumns(bounds: self.view.bounds.width, insets: Global.safeAreaInsets)
                _ = self.writeCellFrameAndReturnSize(index: indexPath.item, availableWidth: columnWidth)
                
                cell.view.addChipViews(with: displayedList.list, chipFrames: displayedList.frame.chipFrames)
            }
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
            
            let selected = self.model.selectedLists.contains(where: { $0.id == list.id })
            cell.view.configureSelection(selected: selected, modelSelecting: self.model.isSelecting)
            cell.view.configureData(list: list)
            
            cell.tapped = { [weak self] in
                guard let self = self else { return }
                
                if self.model.isSelecting {
                    if self.model.selectedLists.contains(where: { $0.id == list.id }) {
                        self.model.selectedLists = self.model.selectedLists.filter { $0.id != list.id }
                        cell.view.headerSelectionIconView.setState(.empty)
                    } else {
                        self.model.selectedLists.append(list)
                        cell.view.headerSelectionIconView.setState(.selected)
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
        cell.view.addChipViews(with: displayedList.list, chipFrames: displayedList.frame.chipFrames) { [weak self] focus in
            if let displayedList = self?.model.displayedLists.first(where: { $0.list.id == displayedList.list.id }) {
                self?.presentDetails(list: displayedList.list, focusFirstWord: true)
            }
        }
    }

    func updateCellColors() {
        for index in model.displayedLists.indices {
            if let cell = collectionView.cellForItem(at: index.indexPath) as? ListsContentCell {
                for case let subview as ListChipView in cell.view.chipsContainerView.subviews {
                    subview.setColors()
                }
            }
        }
    }
}
