//
//  ListsController+CollectionView.swift
//  Find
//
//  Created by Zheng on 3/28/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension ListsController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategories?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCollectionCell", for: indexPath) as! ListCollectionCell
        cell.isAccessibilityElement = true
        
        if let list = listCategories?[indexPath.item] {
            cell.title.text = list.name
            cell.nameDescription.text = list.descriptionOfList
            
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 100, weight: .semibold)
            let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(hexString: list.iconColorName), renderingMode: .alwaysOriginal)
            cell.imageView.image = newImage
            
            var textToDisplay = ""
            var overFlowCount = 0
            
            var accessibilityContents = ""
            for (index, text) in list.words.enumerated() {
                if index <= 10 {
                    if index == list.words.count - 1 {
                        textToDisplay += text
                        accessibilityContents += text
                    } else {
                        textToDisplay += "\(text)\n"
                        accessibilityContents += "\(text), "
                    }
                } else {
                    overFlowCount += 1
                }
            }
            
            if overFlowCount >= 1 {
                let overFlowCountMoreFormat = NSLocalizedString("%d overFlowCountMore",
                                                                comment: "ListsController def=\n... x more")
                textToDisplay += String.localizedStringWithFormat(overFlowCountMoreFormat, overFlowCount)
            }
            
            cell.contentsList.text = textToDisplay
            cell.baseView.layer.cornerRadius = 10
            cell.tapHighlightView.layer.cornerRadius = 10
            cell.tapHighlightView.alpha = 0
            cell.highlightView.layer.cornerRadius = 10
            
            let name = AccessibilityText(text: list.name + "\n", isRaised: false)
            let descriptionTitle = AccessibilityText(text: "Description:", isRaised: true)
            let descriptionString = AccessibilityText(text: list.descriptionOfList, isRaised: false)
            let contentsTitle = AccessibilityText(text: "Words to Find", isRaised: true)
            let contentsString = AccessibilityText(text: accessibilityContents, isRaised: false)
            let overflowString = AccessibilityText(text: (overFlowCount >= 1) ? ", and \(overFlowCount) more" : "", isRaised: false, customPitch: 0.8)
            
            let accessibilityLabel = UIAccessibility.makeAttributedText([name, descriptionTitle, descriptionString, contentsTitle, contentsString, overflowString])
            cell.accessibilityAttributedLabel = accessibilityLabel
        }
        if indexPathsSelected.contains(indexPath.item) {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            cell.highlightView.alpha = 1
            cell.checkmarkView.alpha = 1
        } else {
            collectionView.deselectItem(at: indexPath, animated: false)
            cell.highlightView.alpha = 0
            cell.checkmarkView.alpha = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        heightForTextAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        guard let cell = listCategories?[indexPath.item] else { return 0 }
        
        let sizeOfWidth = ((collectionView.bounds.width - (AdaptiveCollectionConfig.cellPadding * 3)) / 2) - 20
        
        let newDescHeight = cell.descriptionOfList.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        let array = cell.contents
        
        var textToDisplay = ""
        var overFlowCount = 0
        for (index, text) in array.enumerated() {
            if index <= 10 {
                if index == array.count - 1 {
                    textToDisplay += text
                } else {
                    textToDisplay += "\(text)\n"
                }
            } else {
                overFlowCount += 1
            }
        }
        if overFlowCount >= 1 {
            let overFlowCountMoreFormat = NSLocalizedString("%d overFlowCountMore",
                                                            comment: "ListsController def=\n... x more")
            
            textToDisplay += String.localizedStringWithFormat(overFlowCountMoreFormat, overFlowCount)
        }
    
        let newContentsHeight = textToDisplay.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 16))
        
        let titleHeight = cell.name.heightWithConstrainedWidth(width: sizeOfWidth, font: UIFont.systemFont(ofSize: 22, weight: .bold))
        
        let extendHeight = newDescHeight + newContentsHeight + titleHeight
        
        return AdaptiveCollectionConfig.cellBaseHeight + extendHeight + 8 // + 300
    }
  
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.append(indexPath.item)
            numberOfSelected += 1
            if let cell = collectionView.cellForItem(at: indexPath) as? ListCollectionCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 1
                    cell.checkmarkView.alpha = 1
                    cell.highlightView.frame.size.width = 40
                })
            }
                
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            currentEditingPresentationPath = indexPath.item
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let viewController = storyboard.instantiateViewController(withIdentifier: "ListBuilderViewController") as? ListBuilderViewController {
                viewController.finishedEditingList = self
                
                if let currentPath = listCategories?[currentEditingPresentationPath] {
                    viewController.name = currentPath.name
                    viewController.descriptionOfList = currentPath.descriptionOfList
                    var contents = [String]()
                    
                    for singleContent in currentPath.contents {
                        contents.append(singleContent)
                    }
                    viewController.isModalInPresentation = true
                    viewController.contents = contents
                    viewController.iconImageName = currentPath.iconImageName
                    viewController.iconColorName = currentPath.iconColorName
                    
                    viewController.donePressed = { [weak self] in
                        self?.presentingList?(false)
                    }
                }
                
                presentingList?(true)
                present(viewController, animated: true)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath.item)
            numberOfSelected -= 1
            let cell = collectionView.cellForItem(at: indexPath) as! ListCollectionCell
            UIView.animate(withDuration: 0.1, animations: {
                cell.highlightView.alpha = 0
                cell.checkmarkView.alpha = 0
            })
        }
    }
}
