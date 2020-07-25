//
//  HistoryCollectionViewFiles.swift
//  Find
//
//  Created by Zheng on 4/17/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SDWebImage
import SPAlert

extension NewHistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeaderID", for: indexPath) as! TitleSupplementaryView
        if let date = sectionToDate[indexPath.section] {
            let readableDate = date.convertDateToReadableString()
            headerView.todayLabel.text = readableDate
        }
        indexToHeader[indexPath.section] = headerView
        return headerView
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 3
        return CGSize(width: itemSize, height: itemSize)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCounts.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionCounts[section]
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
        cell.layer.masksToBounds = true
        if let hisModel = indexToData[indexPath.section] {
            let (shouldRound, cornerMasks) = calculateCornerRadius(indexPath: indexPath)
            if shouldRound {
                cell.layer.cornerRadius = 4
                cell.layer.maskedCorners = cornerMasks
            } else {
                cell.layer.cornerRadius = 0
            }
            let historyModel = hisModel[indexPath.item]
            let urlPath = historyModel.filePath
            let finalURL = folderURL.appendingPathComponent(urlPath)
            
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.imageView.sd_imageTransition = .fade
            cell.imageView.sd_setImage(with: finalURL)
            
            if historyModel.isHearted == true {
                cell.heartView.alpha = 1
                cell.pinkTintView.alpha = 1
            } else {
                cell.heartView.alpha = 0
                cell.pinkTintView.alpha = 0
            }
            
            if historyModel.isDeepSearched == true {
                cell.cachedView.alpha = 1
            } else {
                cell.cachedView.alpha = 0
            }
            
            if indexPathsSelected.contains(indexPath) {
                UIView.animate(withDuration: 0.1, animations: {
                    
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    cell.highlightView.alpha = 1
                    cell.checkmarkView.alpha = 1
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    collectionView.deselectItem(at: indexPath, animated: false)
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            }
        }
        
        return cell
    }
    
}

//MARK: Context Menu

extension NewHistoryViewController {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            
            let clearLoc = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
            let cancelLoc = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
            let deleteLoc = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
            let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
            
            
            guard let hisModel = self.indexToData[indexPath.section] else { print("NO CONTEXT"); return UIMenu(title: "No Actions")}
            let historyModel = hisModel[indexPath.item]
            
            guard let indexOfPhoto = self.indexPathToIndex[indexPath] else { print("NO INDEX"); return UIMenu(title: "No Actions")}
            
            var heartMessage = ""
            var heartImage = UIImage()
            if historyModel.isHearted {
                heartMessage = NSLocalizedString("unheart", comment: "HistoryCollectionViewFiles def=Unheart")
                heartImage = UIImage(systemName: "heart") ?? UIImage()
            } else {
                heartMessage = NSLocalizedString("heart", comment: "HistoryCollectionViewFiles def=Heart")
                heartImage = UIImage(systemName: "heart.fill") ?? UIImage()
            }
            
            var cacheMessage = ""
            var cacheImage = UIImage()
            if historyModel.isDeepSearched {
                
                cacheMessage = NSLocalizedString("uncache", comment: "HistoryCollectionViewFiles def=Uncache")
                cacheImage = UIImage(named: "ContextNotCached") ?? UIImage()
            } else {
                cacheMessage = NSLocalizedString("cache", comment: "HistoryCollectionViewFiles def=Cache")
                cacheImage = UIImage(named: "ContextCached") ?? UIImage()
            }
            
            // Create an action for copy
            
            let findLoc = NSLocalizedString("findLoc", comment: "Multipurpose def=Find")
            let find = UIAction(title: findLoc, image: UIImage(systemName: "magnifyingglass")) { action in
                self.presentFromIndexpath(indexPath: indexPath, directFind: true)
                // Perform copy
            }
            let heart = UIAction(title: heartMessage, image: heartImage) { action in
                if historyModel.isHearted {
                    self.changeHeart(nowHearted: false, atIndex: indexOfPhoto)
                } else {
                    self.changeHeart(nowHearted: true, atIndex: indexOfPhoto)
                }
                // Perform copy
            }
            let cacheAction = UIAction(title: cacheMessage, image: cacheImage) { action in
                if historyModel.isDeepSearched {
                    let clearThisCacheQuestion = NSLocalizedString("clearThisCacheQuestion", comment: "Multifile def=Clear this photo's cache?")
                    let cachingAgainTakeAWhile = NSLocalizedString("cachingAgainTakeAWhile", comment: "Multifile def=Caching again will take a while...")
                    
                    
                    let alert = UIAlertController(title: clearThisCacheQuestion, message: cachingAgainTakeAWhile, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: clearLoc, style: UIAlertAction.Style.destructive, handler: { _ in
                        self.uncachePhotos(at: [indexOfPhoto])
                    }))
                    alert.addAction(UIAlertAction(title: cancelLoc, style: UIAlertAction.Style.cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    var attributes = EKAttributes.centerFloat
                    attributes.displayDuration = .infinity
                    attributes.entryInteraction = .absorbTouches
                    attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                    attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
                    attributes.entryBackground = .color(color: .white)
                    attributes.screenInteraction = .absorbTouches
                    attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(300))
                    attributes.positionConstraints.maxSize = .init(width: .constant(value: 450), height: .constant(value: 550))
                    attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
                    attributes.lifecycleEvents.didAppear = {
                        self.doneAnimatingSEK?.doneAnimating()
                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
                    
                    let newPhoto = EditableHistoryModel()
                    newPhoto.filePath = historyModel.filePath
                    newPhoto.dateCreated = historyModel.dateCreated
                    newPhoto.isHearted = historyModel.isHearted
                    newPhoto.isDeepSearched = historyModel.isDeepSearched
                    
                    cacheController.folderURL = self.folderURL
                    cacheController.photos = [newPhoto]
                    cacheController.finishedCache = self
                    self.doneAnimatingSEK = cacheController
                    cacheController.view.layer.cornerRadius = 10
                    
                    SwiftEntryKit.display(entry: cacheController, using: attributes)
                }
            }
            let shareLoc = NSLocalizedString("shareLoc", comment: "HistoryCollectionViewFiles def=Share")
            let share = UIAction(title: shareLoc, image: UIImage(systemName: "square.and.arrow.up")) { action in
                
                let shareObject = HistorySharing(filePath: historyModel.filePath, folderURL: self.folderURL)
                let activityViewController = UIActivityViewController(activityItems: [shareObject], applicationActivities: nil)
                let tempController = UIViewController()
                tempController.modalPresentationStyle = .overFullScreen
                activityViewController.completionWithItemsHandler = { [weak tempController] _, _, _, _ in
                    if let presentingViewController = tempController?.presentingViewController {
                        presentingViewController.dismiss(animated: true, completion: nil)
                    } else {
                        tempController?.dismiss(animated: true, completion: nil)
                    }
                }
                if let popoverController = activityViewController.popoverPresentationController {
                    if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                        popoverController.sourceRect = cell.bounds
                        popoverController.sourceView = cell
                    }
                }
                self.present(tempController, animated: true) { [weak tempController] in
                    tempController?.present(activityViewController, animated: true, completion: nil)
                }
            }
            let delete = UIAction(title: deleteLoc, image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                let cantBeUndone = NSLocalizedString("cantBeUndone", comment: "Multipurpose def=This action can't be undone.")
                
                let deleteThisPhotoQuestion = NSLocalizedString("deleteThisPhotoQuestion", comment: "Multifile def=Delete photo?")
                
                let photoDeletedExclaim = NSLocalizedString("photoDeletedExclaim", comment: "Multifile def=Photo deleted!")
                
                let alert = UIAlertController(title: deleteThisPhotoQuestion, message: cantBeUndone, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: deleteLoc, style: UIAlertAction.Style.destructive, handler: { _ in
                    self.deletePhotoAt(photoIndex: indexOfPhoto)
                    let alertView = SPAlertView(title: photoDeletedExclaim, message: tapToDismiss, preset: SPAlertPreset.done)
                    alertView.duration = 2.6
                    alertView.present()
                }))
                alert.addAction(UIAlertAction(title: cancelLoc, style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                // Perform delete
            }
            
            let helpLoc = NSLocalizedString("help", comment: "Multipurpose def=Help")
            let help = UIAction(title: helpLoc, image: UIImage(systemName: "questionmark")) { action in
//                SwiftEntryKitTemplates.displayHistoryHelp()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
                
                let helpTitle = NSLocalizedString("helpTitle", comment: "SwiftEntryKitTemplates displayHistoryHelp def=Help")
                
                helpViewController.title = helpTitle
                helpViewController.helpJsonKey = "HistoryFindHelpArray"
//                helpViewController.goDirectlyToUrl = true
//                helpViewController.directUrl = "https://ahzzheng.github.io/FindHelp/History-HistoryControls.html"

                let navigationController = UINavigationController(rootViewController: helpViewController)
                navigationController.navigationBar.tintColor = UIColor.white
                navigationController.navigationBar.prefersLargeTitles = true

                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                navBarAppearance.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                
                navigationController.navigationBar.standardAppearance = navBarAppearance
                navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
                
                self.present(navigationController, animated: true, completion: nil)
            }
            // Empty menu for demonstration purposes
            
            let actionsLoc = NSLocalizedString("actionsLoc", comment: "HistoryCollectionViewFiles def=Actions")
            if self.selectButtonSelected == false {
                return UIMenu(title: actionsLoc, children: [find, heart, cacheAction, share, delete, help])
            } else {
                return nil
            }
            
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let identifier = configuration.identifier as? IndexPath {
                self.presentFromIndexpath(indexPath: identifier)
            }
        }
    }
    
    
    //MARK: Selection
    func deselectAllItems(deselect: Bool) {
        if deselect == true {
            numberOfSelected = 0
            var reloadPaths = [IndexPath]()
            for indexP in indexPathsSelected {
                collectionView.deselectItem(at: indexP, animated: false)
                if let cell = collectionView.cellForItem(at: indexP) as? HPhotoCell {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.highlightView.alpha = 0
                        cell.checkmarkView.alpha = 0
                        cell.transform = CGAffineTransform.identity
                    })
                } else {
                    reloadPaths.append(indexP)
                }
            }
            collectionView.reloadItems(at: reloadPaths)
            indexPathsSelected.removeAll()
        } else {
            var num = 0
            var reloadPaths = [IndexPath]()
            for i in 0..<collectionView.numberOfSections {
                for j in 0..<collectionView.numberOfItems(inSection: i) {
                    num += 1
                    let indP = IndexPath(row: j, section: i)
                    if !indexPathsSelected.contains(indP) {
                        indexPathsSelected.append(indP)
                        collectionView.selectItem(at: indP, animated: true, scrollPosition: [])
                        if let cell = collectionView.cellForItem(at: indP) as? HPhotoCell {
                            UIView.animate(withDuration: 0.1, animations: {
                                cell.highlightView.alpha = 1
                                cell.checkmarkView.alpha = 1
                                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                            })
                        } else {
                            reloadPaths.append(indP)
                        }
                    }
                    
                }
            }
            collectionView.reloadItems(at: reloadPaths)
            numberOfSelected = num
            
        }
    }
    
    func presentFromIndexpath(indexPath: IndexPath, directFind: Bool = false) {
        if let currentIndex = indexPathToIndex[indexPath] {
            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[indexPath.section] else { print("NO CELL MODEL"); return }
                let historyModel = hisModel[indexPath.item]
                if historyModel.isHearted == true {
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 0
                        cell.pinkTintView.alpha = 0
                    })
                }
            }
            
            let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
            mainContentVC.title = "PhotoPageContainerViewController"
            self.selectedIndexPath = indexPath
            mainContentVC.transitioningDelegate = mainContentVC.transitionController
            mainContentVC.transitionController.fromDelegate = self
            mainContentVC.transitionController.toDelegate = mainContentVC
            mainContentVC.delegate = self
            mainContentVC.currentIndex = currentIndex
            mainContentVC.photoSize = imageSize
            mainContentVC.cameFromFind = false
            mainContentVC.folderURL = folderURL
            
            mainContentVC.goDirectlyToFind = directFind
            
            mainContentVC.highlightColor = highlightColor
            
            mainContentVC.deletedPhoto = self
            mainContentVC.changeModel = self
            mainContentVC.changeCache = self
            
            if let photoCats = photoCategories {
                var modelArray = [EditableHistoryModel]()
                for photo in photoCats {
                    let newHistModel = EditableHistoryModel()
                    newHistModel.filePath = photo.filePath
                    newHistModel.dateCreated = photo.dateCreated
                    newHistModel.isHearted = photo.isHearted
                    newHistModel.isDeepSearched = photo.isDeepSearched
                    
                    for cont in photo.contents {
                        let realmContent = EditableSingleHistoryContent()
                        realmContent.text = cont.text
                        realmContent.height = CGFloat(cont.height)
                        realmContent.width = CGFloat(cont.width)
                        realmContent.x = CGFloat(cont.x)
                        realmContent.y = CGFloat(cont.y)
                        newHistModel.contents.append(realmContent)
                    }
                    modelArray.append(newHistModel)
                }
                mainContentVC.photoModels = modelArray
            }
            self.present(mainContentVC, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            if !indexPathsSelected.contains(indexPath) {
                indexPathsSelected.append(indexPath)
                numberOfSelected += 1
                if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.highlightView.alpha = 1
                        cell.checkmarkView.alpha = 1
                        cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    })
                }
            }
            
        } else {
            collectionView.deselectItem(at: indexPath, animated: true)
            presentFromIndexpath(indexPath: indexPath)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if selectButtonSelected == true {
            indexPathsSelected.remove(object: indexPath)
            numberOfSelected -= 1
            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            }
        }
    }
}
