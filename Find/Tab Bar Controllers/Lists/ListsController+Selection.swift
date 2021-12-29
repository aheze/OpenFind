//
//  ListsController+Selection.swift
//  Find
//
//  Created by Zheng on 12/30/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SPAlert

extension ListsController {
    
    func selectPressed() {
        if listCategories?.count == 0 {
            showNoListsAlert()
        } else {
            selectButtonSelected.toggle()
            showSelectionControls?(selectButtonSelected)
            if selectButtonSelected {
                selectButton.title = NSLocalizedString("cancel", comment: "")
                collectionView.allowsMultipleSelection = true
                addButton.isEnabled = false
                
                selectButton.accessibilityHint = "Exit select mode"
            } else {
                selectButton.title = NSLocalizedString("universal-select", comment: "")
                collectionView.allowsMultipleSelection = false
                deselectAllItems()
                addButton.isEnabled = true
            }
        }
    }
    
    func showNoListsAlert() {
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = 0.7
        attributes.positionConstraints.size.height = .constant(value: 50)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        let contentView = UIView()
        contentView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        contentView.layer.cornerRadius = 8
        let subTitle = UILabel()
        
        let noListsCreatedYet = NSLocalizedString("noListsCreatedYet",
                                                  comment: "ListsController def=No Lists Created Yet!")
        subTitle.text = noListsCreatedYet
        subTitle.textColor = UIColor.white
        contentView.addSubview(subTitle)
        subTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let edgeWidth = CGFloat(600)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func deselectAllItems() {
        var reloadPaths = [IndexPath]()
        for indexP in indexPathsSelected {
            let indexPath = IndexPath(item: indexP, section: 0)
            collectionView.deselectItem(at: indexPath, animated: true)
            if let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            } else {
                reloadPaths.append(indexPath)
            }
        }
        collectionView.reloadItems(at: reloadPaths)
        indexPathsSelected.removeAll()
        numberOfSelected = 0
    }
    
    /// Pressed delete from controls
    func listDeleteButtonPressed() {
        
        var titleMessage = ""
        var finishMessage = ""
        if indexPathsSelected.count == 1 {
            let deleteThisListQuestion = NSLocalizedString("deleteThisListQuestion",
                                                           comment: "ListsController def=Delete this List?")
            let listDeletedExclaim = NSLocalizedString("listDeletedExclaim",
                                                       comment: "ListsController def=List deleted!")
            
            
            titleMessage = deleteThisListQuestion
            finishMessage = listDeletedExclaim
        } else if indexPathsSelected.count == listCategories?.count {
            let deleteAllListsQuestion = NSLocalizedString("deleteAllListsQuestion",
                                                           comment: "ListsController def=Delete ALL lists?!")
            let allListsDeletedExclaim = NSLocalizedString("allListsDeletedExclaim",
                                                       comment: "ListsController def=All lists deleted!")
            
            titleMessage = deleteAllListsQuestion
            finishMessage = allListsDeletedExclaim
        } else {
            let deleteSelectedCountLists = NSLocalizedString("Delete %d lists?",
                                                             comment:"ListsController def=Delete x lists?")
            let finishedDeleteSelectedCountLists = NSLocalizedString("%d lists deleted!",
                                                                     comment:"ListsController def=x lists deleted!")
            
            
            titleMessage = String.localizedStringWithFormat(deleteSelectedCountLists, indexPathsSelected.count)
            finishMessage = String.localizedStringWithFormat(finishedDeleteSelectedCountLists, indexPathsSelected.count)
        }
        
        let cantBeUndone = NSLocalizedString("cantBeUndone", comment: "Multipurpose def=This action can't be undone.")
        
        let alert = UIAlertController(title: titleMessage, message: cantBeUndone, preferredStyle: .alert)
        
        let delete = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
        
        alert.addAction(UIAlertAction(title: delete, style: UIAlertAction.Style.destructive, handler: { _ in
            var tempLists = [FindList]()
            var tempInts = [Int]()
            var arrayOfIndexPaths = [IndexPath]()
            for index in self.indexPathsSelected {
                if let cat = self.listCategories?[index] {
                    tempLists.append(cat)
                    tempInts.append(index)
                    arrayOfIndexPaths.append(IndexPath(item: index, section: 0))
                }
            }
            do {
                try self.realm.write {
                    self.realm.delete(tempLists)
                }
            } catch {

            }
            self.collectionView.deleteItems(at: arrayOfIndexPaths)
            self.indexPathsSelected.removeAll()
            self.numberOfSelected -= tempLists.count
            
            self.sortLists()
            
            let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
            let alertView = SPAlertView(title: finishMessage, message: tapToDismiss, preset: .done)
            alertView.present(duration: 3.6, haptic: .success)
            
            self.selectButtonSelected = false
            self.showSelectionControls?(self.selectButtonSelected)
            self.selectButton.title = NSLocalizedString("universal-select", comment: "")
            self.collectionView.allowsMultipleSelection = false
            self.deselectAllItems()
            self.addButton.isEnabled = true
            
            self.listsChanged?()
        }))
        
        let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
        alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
