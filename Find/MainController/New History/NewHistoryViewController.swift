//
//  HCollectionViewController.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit
import SwiftEntryKit
import RealmSwift
import SPAlert
import LinkPresentation

protocol UpdateImageDelegate: class {
    func changeImage(image: UIImage)
}
protocol ChangeNumberOfSelected: class {
    func changeLabel(to: Int)
}
protocol ChangeAttributes: class {
    func changeFloat(to: String)
    func getRect() -> CGRect
}
protocol GiveSearchPhotos: class {
    func changeSearchPhotos(photos: [URL])
}
protocol DoneAnimatingSEK: class {
    func doneAnimating()
}
class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
    
    let cancel = NSLocalizedString("cancel", comment: "Multipurpose def=Cancel")
    let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
    let cantBeUndone = NSLocalizedString("cantBeUndone", comment: "Multipurpose def=This action can't be undone.")
    
    //MARK: Realm
    let realm = try! Realm()
    var photoCategories: Results<HistoryModel>?
    //MARK: Realm Converter
    
    var indexNumber = 0
    func indexmatcherToInt(indexMatcher: IndexMatcher) -> Int {
        indexNumber += 1
        return indexNumber
    }
    
    var highlightColor = "00aeef"
    var aboutToBeCached = [HistoryModel]()
    
    var indexToHeader = [Int: TitleSupplementaryView]()
    
    //MARK: Finding
    //    var shouldDismissSEK = true
    var selectedIndexPath: IndexPath!
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var sectionToDate: [Int: Date] = [Int: Date]()
    
    var indexToData = [Int: [HistoryModel]]()
    var indexPathToIndex = [IndexPath: Int]()
    var indexToIndexPath = [Int: IndexPath]()
    
    var sectionCounts = [Int]()
    var imageSize = CGSize(width: 0, height: 0)
    
    private let itemsPerRow: CGFloat = 4
    
    //MARK:  Selection Variables
    var shouldCache = true
    var shouldHeart = true
    var indexPathsSelected = [IndexPath]() {
        didSet {
            checkForHearts()
            
            if indexPathsSelected.count == 0 {
                changeFloatDelegate?.changeFloat(to: "Disable")
            } else {
                changeFloatDelegate?.changeFloat(to: "Enable")
            }
        }
        
    }
    //MARK: Share
    var urlOfImageToShare: URL?
    var selectedUrlImages = [URL]()
    var sampleImage = UIImage()
    @IBOutlet weak var tempShareView: UIView!
    
    @IBOutlet weak var tempShareWidthC: NSLayoutConstraint!
    @IBOutlet weak var tempShareHeightC: NSLayoutConstraint!
    @IBOutlet weak var tempShareRightC: NSLayoutConstraint!
    @IBOutlet weak var tempShareBottomC: NSLayoutConstraint!
    
    
    func checkForHearts() {
        var selectedHeartCount = 0
        var selectedNotHeartCount = 0
        
        var selectedCacheCount = 0
        var selectedNotCacheCount = 0
        
        for item in indexPathsSelected {
            let itemToEdit = indexToData[item.section]
            
            if let singleItem = itemToEdit?[item.item] { /// Not very clear but ok
                
                if singleItem.isHearted == true {
                    selectedHeartCount += 1
                } else {
                    selectedNotHeartCount += 1
                }
                
                if singleItem.isDeepSearched == true {
                    selectedCacheCount += 1
                } else {
                    selectedNotCacheCount += 1
                }
            }
        }
        
        if selectedNotHeartCount >= selectedHeartCount {
            shouldHeart = true
            changeFloatDelegate?.changeFloat(to: "Unfill Heart")
        } else {
            changeFloatDelegate?.changeFloat(to: "Fill Heart")
            shouldHeart = false
        }
        
        if selectedNotCacheCount >= 1 {
            shouldCache = true
            changeFloatDelegate?.changeFloat(to: "NotCached")
        } else {
            shouldCache = false
            changeFloatDelegate?.changeFloat(to: "Cached")
        }
    }
    var numberOfSelected = 0 {
        didSet {
            changeNumberDelegate?.changeLabel(to: numberOfSelected)
        }
    }
    
    @IBOutlet var noPhotosDisplay: UIView!
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    weak var changeNumberDelegate: ChangeNumberOfSelected?
    weak var changeFloatDelegate: ChangeAttributes?
    weak var changeSearchPhotos: GiveSearchPhotos?
    weak var doneAnimatingSEK: DoneAnimatingSEK?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var selectAll: UIButton!
    var deselectAll = false
    
    @IBOutlet weak var inBetweenSelect: NSLayoutConstraint!
    var selectButtonSelected = false
    var swipedToDismiss = true
    
    let selectLoc = NSLocalizedString("selectLoc", comment: "NewHistoryViewController def=Select")
    let selectAllLoc = NSLocalizedString("selectAllLoc", comment: "NewHistoryViewController def=Select All")
    
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        if deselectAll == false { /// Select All cells, change label to opposite
            deselectAll = true
            print("select all")
            
            let deselectAllLoc = NSLocalizedString("deselectAllLoc", comment: "NewHistoryViewController def=Deselect All")
            
            selectAll.setTitle(deselectAllLoc, for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: false)
        } else {
            print("deselect all")
            deselectAll = false
            
            
            
            selectAll.setTitle(selectAllLoc, for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: true)
        }
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        if selectButtonSelected == false {
            selectButtonSelected = true
            collectionView.allowsMultipleSelection = true
            fadeSelectOptions(fadeOut: "fade in")
            
        } else { ///Cancel will now be Select
            
            selectButtonSelected = false
            SwiftEntryKit.dismiss()
            fadeSelectOptions(fadeOut: "fade out")
            collectionView.allowsMultipleSelection = false
            
        }
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func fadeSelectOptions(fadeOut: String) {
        switch fadeOut {
        case "fade out":
            if selectButtonSelected == false {
                deselectAllItems(deselect: true)
                deselectAll = false
                UIView.transition(with: selectButton, duration: 0.08, options: .transitionCrossDissolve, animations: {
                    self.selectButton.setTitle(self.selectLoc, for: .normal)
                }, completion: { _ in
                    UIView.transition(with: self.selectAll, duration: 0.1, options: .transitionCrossDissolve, animations: {
                        self.selectAll.setTitle(self.selectAllLoc, for: .normal)
                    }, completion: nil)
                })
                
                
                inBetweenSelect.constant = -5
                selectAll.alpha = 1
                UIView.animate(withDuration: 0.08, animations: {
                    self.view.layoutIfNeeded()
                    self.selectAll.alpha = 0
                }) { _ in
                    self.selectAll.isHidden = true
                }
            }
            
        case "fade in":
            if photoCategories?.count == 0 {
                selectButtonSelected = false
                var attributes = EKAttributes.bottomFloat
                attributes.entryBackground = .color(color: .white)
                attributes.entranceAnimation = .translation
                attributes.exitAnimation = .translation
                attributes.displayDuration = 0.7
                attributes.positionConstraints.size.height = .constant(value: 50)
                attributes.statusBar = .light
                attributes.entryInteraction = .absorbTouches
                
                let contentView = UIView()
                contentView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                contentView.layer.cornerRadius = 8
                let subTitle = UILabel()
                
                let noPhotosTakenYet = NSLocalizedString("noPhotosTakenYet", comment: "NewHistoryViewController def=No Photos Taken Yet!")
                subTitle.text = noPhotosTakenYet
                subTitle.textColor = UIColor.white
                contentView.addSubview(subTitle)
                subTitle.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                let edgeWidth = CGFloat(600)
                attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
                SwiftEntryKit.display(entry: contentView, using: attributes)
                
            } else {
                var attributes = EKAttributes.bottomFloat
                attributes.entryBackground = .color(color: .white)
                attributes.entranceAnimation = .translation
                attributes.exitAnimation = .translation
                attributes.displayDuration = .infinity
                attributes.positionConstraints.size.height = .constant(value: 50)
                attributes.statusBar = .light
                attributes.entryInteraction = .absorbTouches
                attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
                
                let edgeWidth = CGFloat(600)
                attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
                
                
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
                attributes.lifecycleEvents.didAppear =  {
                    if let rect = self.changeFloatDelegate?.getRect() {
                        self.tempShareWidthC.constant = rect.width
                        self.tempShareHeightC.constant = rect.height
                        let viewFrame = self.view.convert(self.view.bounds, to: nil)
                        let newX = viewFrame.origin.x
                        let newY = viewFrame.origin.y
                        
                        let hor = (rect.origin.x + rect.width) - newX
                        var vert = (rect.origin.y + rect.height) - newY
                        vert -= 10
                        
                        let horDiff = self.view.bounds.width - hor
                        let vertDiff = self.view.bounds.height - vert
                        
                        self.tempShareRightC.constant = horDiff
                        self.tempShareBottomC.constant = vertDiff
                        self.tempShareView.layoutIfNeeded()
                    }
                }
                let customView = HistorySelectorView()
                customView.buttonPressedDelegate = self
                
                changeFloatDelegate = customView
                changeNumberDelegate = customView
                SwiftEntryKit.display(entry: customView, using: attributes)
                
                changeFloatDelegate?.changeFloat(to: "Disable")
                
                let done = NSLocalizedString("done", comment: "Multipurpose def=Done")
                selectButton.setTitle(done, for: .normal)
                inBetweenSelect.constant = 5
                selectAll.isHidden = false
                UIView.animate(withDuration: 0.08, animations: {
                    self.selectAll.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
            
        case "firstTimeSetup":
            selectAll.alpha = 0
            selectAll.isHidden = true
            deselectAll = false
            selectButtonSelected = false
        default:
            print("unknown case, fade")
        }
    }
    
    @IBOutlet weak var xButton: UIButton!
    
    @IBAction func xButtonPressed(_ sender: Any) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        SwiftEntryKit.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tempShareView.isUserInteractionEnabled = false
        tempShareView.backgroundColor = UIColor.clear
        populateRealm()
        sortHist()
        getData()
        selectButton.layer.cornerRadius = 6
        selectAll.layer.cornerRadius = 6
        fadeSelectOptions(fadeOut: "firstTimeSetup")
        deselectAllItems(deselect: true)
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 82, right: 16)
        if photoCategories?.count ?? 0 > 0 {
            if let samplePhoto = photoCategories?[0] {
                
                let finalUrl = folderURL.appendingPathComponent(samplePhoto.filePath)
                if let newImage = finalUrl.loadImageFromDocumentDirectory() {
                    imageSize = newImage.size
                    sampleImage = newImage
                }
            }
        }
        indexPathsSelected.removeAll()
        
        let defaults = UserDefaults.standard
        let historyViewedBefore = defaults.bool(forKey: "historyViewedBefore")
        if historyViewedBefore == false {
            defaults.set(true, forKey: "historyViewedBefore")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "HistoryTutorialViewController") as! HistoryTutorialViewController
            vc.view.layer.cornerRadius = 10
            vc.view.clipsToBounds = true
            
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .disabled
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(100))
            attributes.positionConstraints.maxSize = .init(width: .constant(value: 600), height: .constant(value: 800))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                SwiftEntryKit.display(entry: vc, using: attributes)
            })
            
        }
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        if viewControllerToPresent.title == "PhotoPageContainerViewController" {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    
    
}

extension NewHistoryViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [EditableHistoryModel], popup: String) {
        
        let defaults = UserDefaults.standard
        let existingCacheCount = defaults.integer(forKey: "cacheCountTotal")
        let newCacheCount = existingCacheCount + photos.count
        defaults.set(newCacheCount, forKey: "cacheCountTotal")
        
        let tapToDismiss = NSLocalizedString("tapToDismiss", comment: "Multipurpose def=Tap to dismiss")
        if popup == "Keep" {
            let keptCachedPhotos = NSLocalizedString("keptCachedPhotos", comment: "NewHistoryViewController def=Kept cached photos!")
            
            let alertView = SPAlertView(title: keptCachedPhotos, message: tapToDismiss, preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
        } else if popup == "Finished" {
            let alertView = SPAlertView(title: "Caching done!", message: tapToDismiss, preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
            
        }
        
        if let photoCats = photoCategories {
            
            for currentPhoto in photoCats {
                for cachedPhoto in photos {
                    
                    if currentPhoto.dateCreated == cachedPhoto.dateCreated {
                        do {
                            try realm.write {
                                currentPhoto.isDeepSearched = cachedPhoto.isDeepSearched
                                realm.delete(currentPhoto.contents)
                                
                                for cont in cachedPhoto.contents {
                                    
                                    let realmContent = SingleHistoryContent()
                                    realmContent.text = cont.text
                                    realmContent.height = Double(cont.height)
                                    realmContent.width = Double(cont.width)
                                    realmContent.x = Double(cont.x)
                                    realmContent.y = Double(cont.y)
                                    currentPhoto.contents.append(realmContent)
                                }
                            }
                        } catch {
                            print("Error saving cache. \(error)")
                        }
                        print("done cache, curr:: \(currentPhoto)")
                    }
                    
                }
            }
            collectionView.reloadData()
            photoCategories = photoCats
        }
    }
}




extension NewHistoryViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        rePresentFloat()
    }
    func rePresentFloat() {
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size.height = .constant(value: 50)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        
        let edgeWidth = CGFloat(600)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        attributes.lifecycleEvents.didAppear =  {
            if let rect = self.changeFloatDelegate?.getRect() {
                self.tempShareWidthC.constant = rect.width
                self.tempShareHeightC.constant = rect.height
                let viewFrame = self.view.convert(self.view.bounds, to: nil)
                let newX = viewFrame.origin.x
                let newY = viewFrame.origin.y
                
                let hor = (rect.origin.x + rect.width) - newX
                var vert = (rect.origin.y + rect.height) - newY
                vert -= 10
                
                let horDiff = self.view.bounds.width - hor
                let vertDiff = self.view.bounds.height - vert
                
                self.tempShareRightC.constant = horDiff
                self.tempShareBottomC.constant = vertDiff
                self.tempShareView.layoutIfNeeded()
            }
        }
        let customView = HistorySelectorView()
        customView.buttonPressedDelegate = self
        
        changeFloatDelegate = customView
        changeNumberDelegate = customView
        SwiftEntryKit.display(entry: customView, using: attributes)
        changeNumberDelegate?.changeLabel(to: numberOfSelected)
        checkForHearts()
    }
}


extension NewHistoryViewController: ButtonPressed {
    
    
    func floatButtonPressed(button: String) {
        var tempPhotos = [HistoryModel]()
        var deleteFromSections = [Int: Int]()
        var filePaths = [URL]()
        
        var sectionsTouched = [Int]()
        
        var alreadyCached = 0
        var sectionsToDelete = [Int]()
        for selected in indexPathsSelected {
            let section = selected.section
            if !sectionsTouched.contains(section) {
                sectionsTouched.append(section)
            }
            if deleteFromSections[section] == nil {
                deleteFromSections[section] = 1
            } else {
                deleteFromSections[section]! += 1
            }
            if let photoCat = indexToData[selected.section] {
                let photo = photoCat[selected.item]
                let urlString = photo.filePath
                
                let finalUrl = folderURL.appendingPathComponent(urlString)
                if photo.isDeepSearched == true {
                    alreadyCached += 1
                }
                filePaths.append(finalUrl)
                tempPhotos.append(photo)
            }
        }
        
        for section in deleteFromSections {
            if sectionCounts[section.key] == section.value {
                sectionsToDelete.append(section.key)
            }
        }
        switch button {
            
        case "find":
            SwiftEntryKit.dismiss()
            performSegue(withIdentifier: "goToHistoryFind", sender: self)
        case "heart":
            for item in indexPathsSelected {
                let itemToEdit = indexToData[item.section]
                if let singleItem = itemToEdit?[item.item] {
                    do {
                        try realm.write {
                            singleItem.isHearted = shouldHeart
                        }
                    } catch {
                        print("Error saving category \(error)")
                    }
                }
            }
            collectionView.reloadItems(at: indexPathsSelected)
            
            selectButtonSelected = false
            fadeSelectOptions(fadeOut: "fade out")
            SwiftEntryKit.dismiss()
            collectionView.allowsMultipleSelection = false
            
        case "delete":
            
            var titleMessage = ""
            var finishMessage = ""
            if indexPathsSelected.count == 1 {
                
                let deleteThisPhotoQuestion = NSLocalizedString("deleteThisPhotoQuestion", comment: "NewHistoryViewController def=Delete photo?")
                let photoDeletedExclaim = NSLocalizedString("photoDeletedExclaim", comment: "NewHistoryViewController def=Photo deleted!")
                
                
                titleMessage = deleteThisPhotoQuestion
                finishMessage = photoDeletedExclaim
            } else if indexPathsSelected.count == photoCategories?.count {
                let deleteAllPhotosQuestion = NSLocalizedString("deleteAllPhotosQuestion", comment: "NewHistoryViewController def=Delete ALL photos?!")
                let allPhotosDeletedExclaim = NSLocalizedString("allPhotosDeletedExclaim", comment: "NewHistoryViewController def=All photos deleted!")
                
                titleMessage = deleteAllPhotosQuestion
                finishMessage = allPhotosDeletedExclaim
            } else {
                let deletexPhotos = NSLocalizedString("Delete %d photos?", comment:"NewHistoryViewController def=Delete x photos?")
                
                let finishedDeletexPhotos = NSLocalizedString("%d photos deleted!", comment:"NewHistoryViewController def=x photos deleted!")
                
                
                titleMessage = String.localizedStringWithFormat(deletexPhotos, indexPathsSelected.count)
                finishMessage = String.localizedStringWithFormat(finishedDeletexPhotos, indexPathsSelected.count)
    //            titleMessage = "Delete \(indexPathsSelected.count) lists?"
    //            finishMessage = "\(indexPathsSelected.count) lists deleted!"
            }
            
            
    
//
//
//            var titleMessage = ""
//            var finishMessage = ""
//            if indexPathsSelected.count == 1 {
//                titleMessage = "Delete photo?"
//                finishMessage = "Photo deleted!"
//            } else if indexPathsSelected.count == photoCategories?.count {
//                titleMessage = "Delete ALL photos?!"
//                finishMessage = "All photos deleted!"
//            } else {
//                titleMessage = "Delete \(indexPathsSelected.count) photos?"
//                finishMessage = "\(indexPathsSelected.count) photos deleted!"
//            }
            
            let delete = NSLocalizedString("delete", comment: "Multipurpose def=Delete")
            let alert = UIAlertController(title: titleMessage, message: cantBeUndone, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: delete, style: UIAlertAction.Style.destructive, handler: { _ in
                
                var tempIntSelected = self.indexPathsSelected
                self.selectButtonSelected = false
                self.fadeSelectOptions(fadeOut: "fade out")
                SwiftEntryKit.dismiss()
                self.collectionView.allowsMultipleSelection = false
                
                var contents = [SingleHistoryContent]()
                for photo in tempPhotos {
                    for content in photo.contents {
                        contents.append(content)
                    }
                }
                
                do {
                    try self.realm.write {
                        self.realm.delete(contents)
                        self.realm.delete(tempPhotos)
                    }
                } catch {
                    print("DELETE PRESSED, but ERROR deleting photos...... \(error)")
                }
                
                
                print("Deleting from file now")
                let fileManager = FileManager.default
                for filePath in filePaths {
                    print("file... \(filePath)")
                    do {
                        try fileManager.removeItem(at: filePath)
                    } catch {
                        print("Could not delete items: \(error)")
                    }
                }
                
                
                
                self.getData()
                if sectionsToDelete.count == 0 {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.deleteItems(at: tempIntSelected)
                    })
                } else {
                    self.collectionView.performBatchUpdates({
                        let sections = IndexSet(sectionsToDelete)
                        self.collectionView.deleteSections(sections)
                    })
                }
                
                for section in sectionsTouched {
                    self.modifySection(modifiedSection: section)
                    self.reloadEdgeItems(modifiedSection: section)
                }
                tempIntSelected.removeAll()
                
                
                let alertView = SPAlertView(title: finishMessage, message: self.tapToDismiss, preset: SPAlertPreset.done)
                alertView.duration = 2.6
                alertView.present()
                
            }))
            
            
            alert.addAction(UIAlertAction(title: cancel, style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
            
            
            
        case "cache":
            
            if shouldCache == true {
                var attributes = EKAttributes.centerFloat
                attributes.displayDuration = .infinity
                attributes.entryInteraction = .absorbTouches
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
                attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
                attributes.entryBackground = .color(color: .white)
                attributes.screenInteraction = .absorbTouches
                attributes.positionConstraints.size.height = .constant(value: screenBounds.size.height - CGFloat(300))
                //                attributes.positionConstraints.maxSize = .init(width: .constant(value: 300), height: .constant(value: 400))
                attributes.positionConstraints.maxSize = .init(width: .constant(value: 450), height: .constant(value: 550))
                
                attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
                attributes.lifecycleEvents.didAppear = {
                    self.doneAnimatingSEK?.doneAnimating()
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
                var editablePhotoArray = [EditableHistoryModel]()
                for item in indexPathsSelected {
                    let itemToEdit = indexToData[item.section]
                    if let singleItem = itemToEdit?[item.item] {
                        let newPhoto = EditableHistoryModel()
                        newPhoto.filePath = singleItem.filePath
                        newPhoto.dateCreated = singleItem.dateCreated
                        newPhoto.isHearted = singleItem.isHearted
                        newPhoto.isDeepSearched = singleItem.isDeepSearched
                        editablePhotoArray.append(newPhoto)
                    }
                }
                
                cacheController.folderURL = folderURL
                cacheController.photos = editablePhotoArray
                cacheController.finishedCache = self
                self.doneAnimatingSEK = cacheController
                cacheController.view.layer.cornerRadius = 10
                
                selectButtonSelected = false
                fadeSelectOptions(fadeOut: "fade out")
                SwiftEntryKit.dismiss()
                collectionView.allowsMultipleSelection = false
                
                SwiftEntryKit.display(entry: cacheController, using: attributes)
            } else {
                var arrayOfUncache = [Int]()
                for indexP in indexPathsSelected {
                    if let index = indexPathToIndex[indexP] {
                        arrayOfUncache.append(index)
                    }
                }
//
//                var titleMessage = ""
//                var finishMessage = ""
//                if arrayOfUncache.count == 1 {
//                    titleMessage = "Clear this photo's cache?"
//                    finishMessage = "Cache cleared!"
//                } else if arrayOfUncache.count == photoCategories?.count {
//                    titleMessage = "Clear ENTIRE cache?!"
//                    finishMessage = "Entire cache cleared!"
//                } else {
//                    titleMessage = "Clear \(arrayOfUncache.count) photos' caches?"
//                    finishMessage = "\(arrayOfUncache.count) caches deleted!"
//                }
//
                
                var titleMessage = ""
                var finishMessage = ""
                if indexPathsSelected.count == 1 {
                    
                    let clearThisCacheQuestion = NSLocalizedString("clearThisCacheQuestion", comment: "NewHistoryViewController def=Clear this photo's cache?")
                    let cacheClearedExclaim = NSLocalizedString("cacheClearedExclaim", comment: "NewHistoryViewController def=Cache cleared!")
                    
                    
                    titleMessage = clearThisCacheQuestion
                    finishMessage = cacheClearedExclaim
                } else if indexPathsSelected.count == photoCategories?.count {
                    let deleteEntireCacheQuestion = NSLocalizedString("deleteEntireCacheQuestion", comment: "NewHistoryViewController def=Clear ENTIRE cache?!")
                    let entireCacheDeletedExclaim = NSLocalizedString("entireCacheDeletedExclaim", comment: "NewHistoryViewController def=Entire cache cleared!")
                    
                    titleMessage = deleteEntireCacheQuestion
                    finishMessage = entireCacheDeletedExclaim
                } else {
                    let deletexCaches = NSLocalizedString("Delete %d caches?", comment:"NewHistoryViewController def=Clear x photos' caches?")
                    
                    let finishedDeletexCaches = NSLocalizedString("%d photos caches deleted!", comment:"NewHistoryViewController def=x caches cleared!")
                    
                    
                    titleMessage = String.localizedStringWithFormat(deletexCaches, arrayOfUncache.count)
                    finishMessage = String.localizedStringWithFormat(finishedDeletexCaches, arrayOfUncache.count)
        //            titleMessage = "Delete \(indexPathsSelected.count) lists?"
        //            finishMessage = "\(indexPathsSelected.count) lists deleted!"
                }
                
                let cachingAgainTakeAWhile = NSLocalizedString("cachingAgainTakeAWhile", comment: "NewHistoryViewController def=Caching again will take a while...")
                let clear = NSLocalizedString("clear", comment: "Multipurpose def=Clear")
                
                let alert = UIAlertController(title: titleMessage, message: cachingAgainTakeAWhile, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: clear, style: UIAlertAction.Style.destructive, handler: { _ in
                    self.uncachePhotos(at: arrayOfUncache)
                    let alertView = SPAlertView(title: finishMessage, message: self.tapToDismiss, preset: SPAlertPreset.done)
                    alertView.duration = 2.6
                    alertView.present()
                    
                    self.selectButtonSelected = false
                    self.fadeSelectOptions(fadeOut: "fade out")
                    SwiftEntryKit.dismiss()
                    self.collectionView.allowsMultipleSelection = false
                }))
                alert.addAction(UIAlertAction(title: self.cancel, style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        case "share":
            print("share")
            var arrayOfUrlStrings = [String]()
            for indexP in indexPathsSelected {
                let bigItem = indexToData[indexP.section]
                if let photo = bigItem?[indexP.item] {
                    arrayOfUrlStrings.append(photo.filePath)
                }
            }
            shareData(arrayOfUrlStrings)
            
        default: print("unknown, bad string")
            
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToHistoryFind":
            SwiftEntryKit.dismiss()
            segue.destination.presentationController?.delegate = self
            let destinationVC = segue.destination as! HistoryFindController
            var modelArray = [EditableHistoryModel]()
            for indexPath in indexPathsSelected {
                let itemToEdit = indexToData[indexPath.section]
                if let singleItem = itemToEdit?[indexPath.item] {
                    
                    let newHistModel = EditableHistoryModel()
                    newHistModel.filePath = singleItem.filePath
                    newHistModel.dateCreated = singleItem.dateCreated
                    newHistModel.isHearted = singleItem.isHearted
                    newHistModel.isDeepSearched = singleItem.isDeepSearched
                    
                    for cont in singleItem.contents {
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
            }
            destinationVC.folderURL = folderURL
            destinationVC.highlightColor = highlightColor
            destinationVC.photos = modelArray
            
            modelArray.forEach { (edit) in
                print(edit.contents)
            }
            
            var tempPhotos = [HistoryModel]()
            for selected in indexPathsSelected {
                if let photoCat = indexToData[selected.section] {
                    let photo = photoCat[selected.item]
                    tempPhotos.append(photo)
                }
            }
            print("going to find hist")
        default:
            print("BAD PATH SEGUE ID")
        }
    }
    
}

extension NewHistoryViewController {
    
    func shareData(_ dataToShare: [String]) {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            SwiftEntryKit.dismiss()
        default:
            print("other")
        }
        var objects = [HistorySharing]()
        for url in dataToShare {
            let shareObject = HistorySharing(filePath: url, folderURL: folderURL)
            objects.append(shareObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        
        let tempController = UIViewController()
        tempController.modalPresentationStyle = .overFullScreen
        activityViewController.completionWithItemsHandler = { [weak tempController] _, _, _, _ in
            if let presentingViewController = tempController?.presentingViewController {
                presentingViewController.dismiss(animated: true, completion: nil)
            } else {
                tempController?.dismiss(animated: true, completion: nil)
            }
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                self.rePresentFloat()
            default:
                print("other")
            }
            
        }
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 42, height: 42)
            popoverController.sourceView = tempShareView
        }
        present(tempController, animated: true) { [weak tempController] in
            tempController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
extension NewHistoryViewController {
    
    func uncachePhotos(at: [Int]) {
        
        if let photoCats = photoCategories {
            for index in at {
                let realmPhoto = photoCats[index]
                do {
                    try realm.write {
                        realm.delete(realmPhoto.contents)
                        realmPhoto.isDeepSearched = false
                    }
                } catch {
                    print("ERROR changing CACHE!! \(error)")
                }
            }
            
            getData()
            
            var indexPathsToReload = [IndexPath]()
            for index in at {
                if let indP = indexToIndexPath[index] {
                    indexPathsToReload.append(indP)
                }
            }
            collectionView.reloadItems(at: indexPathsToReload)
        }
    }
    
    func populateRealm() {
        //        print("POP")
        //        listCategories = realm.objects(FindList.self)
        photoCategories = realm.objects(HistoryModel.self)
        
    }
    func sortHist() {
        //        print("SORT")
        if let photoCats = photoCategories {
            photoCategories = photoCats.sorted(byKeyPath: "dateCreated", ascending: false)
        }
    }
    
    func getData() {
      
        indexToData.removeAll()
        sectionToDate.removeAll()
        sectionCounts.removeAll()
        
        var arrayOfPaths = [URL]()
        var arrayOfCategoryDates = [Date]()
        var dateToNumber = [Date: Int]()
        
        guard let photoCats = photoCategories else { print("No Cats or Error!"); return }
        
        if photoCats.count == 0 {
            view.addSubview(noPhotosDisplay)
            noPhotosDisplay.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(300)
            }
        }
        for singleHist in photoCats {
            
            let splits = singleHist.filePath.components(separatedBy: "=")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyy"
            
            guard let dateFromString = dateFormatter.date(from: splits[1]) else { print("no date wrong... return"); return}
            if !arrayOfCategoryDates.contains(dateFromString) {
                arrayOfCategoryDates.append(dateFromString)
            }
            
            if !arrayOfCategoryDates.contains(dateFromString) {
                arrayOfCategoryDates.append(dateFromString)
            }
            let finalUrl = folderURL.appendingPathComponent(singleHist.filePath)
            
            if dateToNumber[dateFromString] == nil {
                dateToNumber[dateFromString] = 0
            } else {
                dateToNumber[dateFromString]! += 1
            }
            
            arrayOfPaths.append(finalUrl)
        }
        arrayOfCategoryDates.sort(by: { $0.compare($1) == .orderedDescending})
        
        var count = -1
        for (index, date) in arrayOfCategoryDates.enumerated() {
            sectionCounts.append(0)
            sectionToDate[index] = date
            
            if let numberOfPhotosInDate = dateToNumber[date] {
                for secondIndex in 0...numberOfPhotosInDate {
                    count += 1
                    let indexPath = IndexMatcher()
                    indexPath.section = index
                    indexPath.row = secondIndex
                    sectionCounts[index] += 1
                    
                    let indP = IndexPath(item: secondIndex, section: index)
                    indexPathToIndex[indP] = count
                    indexToIndexPath[count] = indP
                    
                    if let newHistModel = photoCategories?[count] {
                        indexToData[index, default: [HistoryModel]()].append(newHistModel)
                    }
                }
            }
        }
    }
}

extension Date {
    func convertDateToReadableString() -> String {
        
        let todayLoc = NSLocalizedString("todayLoc", comment: "extensionDate def=Today")
        let yesterdayLoc = NSLocalizedString("yesterdayLoc", comment: "extensionDate def=Yesterday")
        
        
        
        /// Initializing a Date object will always return the current date (including time)
        let todaysDate = Date()
        
        guard let yesterday = todaysDate.subtract(days: 1) else { return "2020"}
        
        guard let oneWeekAgo = todaysDate.subtract(days: 7) else { return "2020"}
        guard let yestYesterday = yesterday.subtract(days: 1) else { return "2020"}
        
        /// This will be any date from one week ago to the day before yesterday
        let recently = oneWeekAgo...yestYesterday
        
        /// convert the date into a string, if the date is before yesterday
        let dateFormatter = DateFormatter()
        
        /// If self (the date that you're comparing) is today
        if self.hasSame(.day, as: todaysDate) {
            return todayLoc
            
            /// if self is yesterday
        } else if self.hasSame(.day, as: yesterday) {
            return yesterdayLoc
            
            /// if self is in between one week ago and the day before yesterday
        } else if recently.contains(self) {
            
            /// "EEEE" will display something like "Wednesday" (the weekday)
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: self)
            
            /// self is before one week ago
        } else {
            
            /// displays the date as "January 1, 2020"
            /// the ' ' marks indicate a character that you add (in our case, a comma)
            dateFormatter.dateFormat = "MMMM d',' yyyy"
            return dateFormatter.string(from: self)
        }
        
    }
    
    /// Thanks to Vasily Bodnarchuk: https://stackoverflow.com/a/40654331
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
    
    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        return self.compare(with: date, only: component) == 0
    }
}

extension NewHistoryViewController: ZoomStateChanged, ZoomCached {
    
    
    func cached(cached: Bool, photo: EditableHistoryModel, index: Int) {
        if cached == true {
            cachePhoto(photo: photo, index: index)
        } else { ///UNCACHE
            uncachePhotos(at: [index])
        }
    }
    
    
    func changedState(type: String, index: Int) {
        switch type {
        case "Unheart":
            changeHeart(nowHearted: false, atIndex: index)
        case "Heart":
            changeHeart(nowHearted: true, atIndex: index)
        default:
            print("WRONG DEFAUTL!!!")
        }
    }
    
    func changeHeart(nowHearted: Bool, atIndex: Int) {
        if let photoCats = photoCategories {
            let photo = photoCats[atIndex]
            if let indP = indexToIndexPath[atIndex] {
                do {
                    try realm.write {
                        photo.isHearted = nowHearted
                    }
                } catch {
                    print("ERROR Changing heart!! \(error)")
                }
                getData()
                collectionView.reloadItems(at: [indP])
            }
            
        }
    }
    
}

extension NewHistoryViewController: ZoomDeletedPhoto {
    
    func deletedPhoto(photoIndex: Int) {
        deletePhotoAt(photoIndex: photoIndex)
    }
    func deletePhotoAt(photoIndex: Int) {
        var sectionToDelete = -1
        if let photoCats = photoCategories {
            let photoToDelete = photoCats[photoIndex]
            
            if let indP = indexToIndexPath[photoIndex] {
                let section = indP.section
                
                let photosInSection = indexToData[section]
                
                if photosInSection?.count == 1 {
                    sectionToDelete = section
                }
                let urlString = photoToDelete.filePath
                
                let finalUrl = folderURL.appendingPathComponent(urlString)
                
                let fileManager = FileManager.default
                print("file delete... \(finalUrl)")
                do {
                    try fileManager.removeItem(at: finalUrl)
                } catch {
                    print("Could not delete items: \(error)")
                }
                do {
                    try realm.write {
                        realm.delete(photoToDelete.contents)
                        realm.delete(photoToDelete)
                    }
                } catch {
                    print("ERROR DELETING!! \(error)")
                }
                getData()
                if sectionToDelete >= 0 {
                    let sections = IndexSet([sectionToDelete])
                    collectionView.deleteSections(sections)
                } else {
                    collectionView.deleteItems(at: [indP])
                }
                reloadEdgeItems(modifiedSection: section)
            }
            
        }
    }
    
}




extension NewHistoryViewController: PhotoPageContainerViewControllerDelegate {
    
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        if let indexPath = indexToIndexPath[currentIndex] {
            
            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[selectedIndexPath.section] else { print("NO CELL MODEL"); return }
                let historyModel = hisModel[selectedIndexPath.item]
                if historyModel.isHearted == true {
                    cell.heartView.alpha = 1
                    cell.pinkTintView.alpha = 1
                } else {
                    cell.heartView.alpha = 0
                    cell.pinkTintView.alpha = 0
                }
            }
            selectedIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[indexPath.section] else { print("NO CELL MODEL"); return }
                let historyModel = hisModel[indexPath.item]
                if historyModel.isHearted == true {
                    cell.heartView.alpha = 1
                    cell.pinkTintView.alpha = 1
                } else {
                    cell.heartView.alpha = 0
                    cell.pinkTintView.alpha = 0
                }
            }
            
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
        }
    }
}




extension NewHistoryViewController {
    func cachePhoto(photo: EditableHistoryModel, index: Int) {
        let defaults = UserDefaults.standard
        let existingCacheCount = defaults.integer(forKey: "cacheCountTotal")
        let newCacheCount = existingCacheCount + 1
        
        defaults.set(newCacheCount, forKey: "cacheCountTotal")
        if let photoCats = photoCategories {
            let origPhoto = photoCats[index]
            if let indP = indexToIndexPath[index] {
                do {
                    try realm.write {
                        
                        realm.delete(origPhoto.contents)
                        
                        origPhoto.isDeepSearched = true
                        
                        for cont in photo.contents {
                            
                            let realmContent = SingleHistoryContent()
                            realmContent.text = cont.text
                            realmContent.height = Double(cont.height)
                            realmContent.width = Double(cont.width)
                            realmContent.x = Double(cont.x)
                            realmContent.y = Double(cont.y)
                            
                            origPhoto.contents.append(realmContent)
                        }
                        
                    }
                } catch {
                    print("ERROR Changing heart!! \(error)")
                }
                getData()
                collectionView.reloadItems(at: [indP])
            }
            
        }
    }
}

extension NewHistoryViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        if zoomAnimator.isPresenting == false && zoomAnimator.finishedDismissing == true {
            SwiftEntryKit.dismiss()
            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[selectedIndexPath.section] else { return }
                let historyModel = hisModel[selectedIndexPath.item]
                if historyModel.isHearted == true {
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 1
                        cell.pinkTintView.alpha = 1
                    })
                }
            }
        }
        if let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell {
            
            let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
            
            if cellFrame.minY < self.collectionView.contentInset.top {
                self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
            } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
                self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        self.view.layoutIfNeeded()
        self.collectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        var cellFrame = self.collectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.collectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.collectionView.contentInset.top - cellFrame.minY))
        }
        
        let superCellFrame = self.collectionView.convert(unconvertedFrame, to: nil)
        let cellYDiff = superCellFrame.origin.y - cellFrame.origin.y
        let cellXDiff = superCellFrame.origin.x - cellFrame.origin.x
        
        cellFrame.origin.y += cellYDiff
        cellFrame.origin.x += cellXDiff
        ///works on ipad now
        ///need to fix this, no hardcoded values
        return cellFrame
    }
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        let visibleCells = self.collectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
            
            //Scroll the collectionView to the cell that is currently offscreen
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            self.collectionView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell) else {
                return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
            //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell) else {
                return CGRect(x: screenBounds.midX, y: screenBounds.midY, width: 100.0, height: 100.0)
            }
            //The cell was found successfully
            return guardedCell.frame
        }
    }
}
extension Date {
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let comp = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: comp, to: self)
    }
    
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
}


extension URL {
    func loadImageFromDocumentDirectory() -> UIImage? {
        guard let image = UIImage(contentsOfFile: self.path) else { return nil }
        return image
    }
}

extension NewHistoryViewController {
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        indexToHeader.removeValue(forKey: indexPath.section)
    }
    func modifySection(modifiedSection: Int) {
        if let header = indexToHeader[modifiedSection] {
            if let date = sectionToDate[modifiedSection] {
                let readableDate = date.convertDateToReadableString()
                header.todayLabel.text = readableDate
            }
        }
    }
    func reloadEdgeItems(modifiedSection: Int) {
        if let section = indexToData[modifiedSection] {
            var reloadPaths = [IndexPath]()
            let sectionCount = section.count
            if section.count <= 6 {
                for (index, item) in section.enumerated() {
                    let indP = IndexPath(item: index, section: modifiedSection)
                    reloadPaths.append(indP)
                }
            } else {
                let firstThree = [IndexPath(item: 0, section: modifiedSection), IndexPath(item: 1, section: modifiedSection), IndexPath(item: 2, section: modifiedSection)]
                let last = sectionCount - 1
                let secondToLast = sectionCount - 2
                let thirdToLast = sectionCount - 3
                
                let lastThree = [IndexPath(item: thirdToLast, section: modifiedSection), IndexPath(item: secondToLast, section: modifiedSection), IndexPath(item: last, section: modifiedSection)]
                
                reloadPaths = firstThree + lastThree
                
            }
            if reloadPaths.count >= 1 {
                for path in reloadPaths {
                    if let cell = collectionView.cellForItem(at: path) as? HPhotoCell {
                        let (shouldRound, corners) = calculateCornerRadius(indexPath: path)
                        if shouldRound {
                            UIView.animate(withDuration: 0.3, animations: {
                                cell.layer.cornerRadius = 4
                                cell.layer.maskedCorners = corners
                            })
                        } else {
                            print("NO")
                            UIView.animate(withDuration: 0.3, animations: {
                                cell.layer.cornerRadius = 0
                            })
                        }
                        
                    }
                }
            }
        }
    }
    func calculateCornerRadius(indexPath: IndexPath) -> (Bool, CACornerMask) {
        
        if let section = indexToData[indexPath.section] {
            let totalSectionCount = section.count
            if totalSectionCount <= 3 {
                if totalSectionCount == 1 {
                    return (true, [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                } else if totalSectionCount == 2 {
                    if indexPath.item == 0 {
                        return (true, [.layerMinXMinYCorner, .layerMinXMaxYCorner])
                    } else if indexPath.item == 1 {
                        return (true, [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                    }
                } else { /// Three cells
                    if indexPath.item == 0 {
                        return (true, [.layerMinXMinYCorner, .layerMinXMaxYCorner])
                    } else if indexPath.item == 2 {
                        return (true, [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                    }
                }
            } else {
                
                if indexPath.item <= 2 {
                    switch indexPath.item {
                    case 0:
                        return (true, [.layerMinXMinYCorner])
                    case 2:
                        if totalSectionCount <= 5 {
                            return (true, [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                        } else {
                            return (true, [.layerMaxXMinYCorner])
                        }
                        
                    default:
                        break
                    }
                } else {
                    let lastIndex = totalSectionCount - 1
                    let secondToLastIndex = totalSectionCount - 2
                    let thirdToLastIndex = totalSectionCount - 3
                    
                    if totalSectionCount % 3 == 0 {
                        if indexPath.item == thirdToLastIndex {
                            return (true, [.layerMinXMaxYCorner])
                        } else if indexPath.item == lastIndex {
                            return (true, [.layerMaxXMaxYCorner])
                        }
                    } else if totalSectionCount % 3 == 2 {
                        if indexPath.item == secondToLastIndex {
                            return (true, [.layerMinXMaxYCorner])
                        } else if indexPath.item == lastIndex {
                            return (true, [.layerMaxXMaxYCorner])
                        } else if indexPath.item == thirdToLastIndex {
                            return (true, [.layerMaxXMaxYCorner])
                        }
                    } else {
                        if indexPath.item == lastIndex {
                            return (true, [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
                        } else if indexPath.item == secondToLastIndex {
                            return (true, [.layerMaxXMaxYCorner])
                        }
                    }
                }
            }
        }
        return (false, [])
    }
}
