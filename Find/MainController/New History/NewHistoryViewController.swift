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
    
    
    //MARK: Realm
    let realm = try! Realm()
    var photoCategories: Results<HistoryModel>?
    //MARK: Realm Converter
    
    var indexNumber = 0
    func indexmatcherToInt(indexMatcher: IndexMatcher) -> Int {
        indexNumber += 1
        return indexNumber
    }
//    var photoCategories: [IndexMatcher: Results<RealmPhoto>]?
//    var photoCategories = [IndexMatcher: ]
    var highlightColor = "00aeef"
    
    var aboutToBeCached = [HistoryModel]()
//    var reloadingHearts
    
    var indexToHeader = [Int: TitleSupplementaryView]()

//    var presentingCache = false
    
    //MARK: Finding
//    var shouldDismissSEK = true
    var selectedIndexPath: IndexPath!
//    var isPresentingState = false
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var sectionToDate: [Int: Date] = [Int: Date]()
//    var dateToFilepaths = [Date: [URL]]()
//    var dictOfUrls = [IndexMatcher: URL]()
    
    var indexToData = [Int: [HistoryModel]]()
    var indexPathToIndex = [IndexPath: Int]()
    var indexToIndexPath = [Int: IndexPath]()
    
    var sectionCounts = [Int]()
    var imageSize = CGSize(width: 0, height: 0)
    
    //let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    //private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private let itemsPerRow: CGFloat = 4
    
    //MARK:  Selection Variables
    //var indexPathsThatAreSelected = [IndexPath]()
//    var fileUrlsSelected = [URL]()
    var shouldCache = true
    var shouldHeart = true
    var indexPathsSelected = [IndexPath]() {
        didSet {
//            print("SETTTUTUTOUTOUOUTOUT")
            checkForHearts()
            
            if indexPathsSelected.count == 0 {
//                print("ZERO!!!")
                changeFloatDelegate?.changeFloat(to: "Disable")
            } else {
//                print("NOT ZERO>>>")
                changeFloatDelegate?.changeFloat(to: "Enable")
            }
        }

    }
    //MARK: Share
//    var locationOfShareButton = CGRect(x: 0, y: 0, width: 100, height: 100)
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
            
            if let singleItem = itemToEdit?[item.item] {///Not very clear but ok
                
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
//            var shouldHeart = true
        if selectedNotHeartCount >= selectedHeartCount {
            shouldHeart = true
            changeFloatDelegate?.changeFloat(to: "Unfill Heart")
        } else {
            changeFloatDelegate?.changeFloat(to: "Fill Heart")
            shouldHeart = false
        }
        
//        if selectedNotCacheCount >= selectedCacheCount {
//            shouldCache = true
//            changeFloatDelegate?.changeFloat(to: "NotCached")
//        } else {
//            changeFloatDelegate?.changeFloat(to: "Cached")
//            shouldCache = false
//        }
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
    
   // @IBOutlet weak var selectIndicator: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var selectAll: UIButton!
    var deselectAll = false
    
    @IBOutlet weak var inBetweenSelect: NSLayoutConstraint!
    var selectButtonSelected = false
    var swipedToDismiss = true
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
//        deselectAll = !deselectAll
        if deselectAll == false { //Select All cells, change label to opposite
            deselectAll = true
            print("select all")
            selectAll.setTitle("Deselect All", for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: false)
        } else {
            print("deselect all")
            deselectAll = false
            selectAll.setTitle("Select All", for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: true)
        }
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
//        selectButtonSelected = !selectButtonSelected ///First time press, will be true
        print("PRESSED____________")
        if selectButtonSelected == false {
            selectButtonSelected = true
            collectionView.allowsMultipleSelection = true
//            selectionMode = true
            print("select")
//            swipedToDismiss = true
            fadeSelectOptions(fadeOut: "fade in")
            
        } else { ///Cancel will now be Select
            
            print("COUNT: \(indexPathsSelected.count)")
            
            
            selectButtonSelected = false
            SwiftEntryKit.dismiss()
            fadeSelectOptions(fadeOut: "fade out")
            collectionView.allowsMultipleSelection = false
            
            
            print("cancel")
            
            //selectButtonSelected = true
//            swipedToDismiss = false
//            fadeSelectOptions(fadeOut: "fade out")
           
            
            
//            indexPathsSelected.removeAll()
//            swipedToDismiss = true
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
            print("fade out")
            if selectButtonSelected == false {
        //            if swipedToDismiss == false {
        //                SwiftEntryKit.dismiss()
        //            }
                print("COUNT: \(indexPathsSelected.count)")
                deselectAllItems(deselect: true)
    //            enterSelectMode(entering: false)
                deselectAll = false
                UIView.transition(with: selectButton, duration: 0.08, options: .transitionCrossDissolve, animations: {
                  self.selectButton.setTitle("Select", for: .normal)
                }, completion: { _ in
                    UIView.transition(with: self.selectAll, duration: 0.1, options: .transitionCrossDissolve, animations: {
                      self.selectAll.setTitle("Select All", for: .normal)
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
//                selectButtonSelected = false
                
            }
            
        case "fade in":
            // Create a basic toast that appears at the top
            
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
                
                
                //let font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.light)
                let contentView = UIView()
                contentView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                contentView.layer.cornerRadius = 8
                let subTitle = UILabel()
                subTitle.text = "No Photos Taken Yet!"
                subTitle.textColor = UIColor.white
                contentView.addSubview(subTitle)
                subTitle.snp.makeConstraints { (make) in
                    make.center.equalToSuperview()
                }
                
                
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
//                attributes.lifecycleEvents.willDisappear = {
////                    if self.shouldDismissSEK == true {
//                        self.fadeSelectOptions(fadeOut: "fade out")
////                        self.selectButtonSelected = false
////                        self.enterSelectMode(entering: false)
////                    }
//                }
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
                //selectionMode = true
                //changeNumberDelegate?.changeLabel(to: 4)
                SwiftEntryKit.display(entry: customView, using: attributes)
//                enterSelectMode(entering: true)
                print("fade insfdfsdf")
                
                changeFloatDelegate?.changeFloat(to: "Disable")
                selectButton.setTitle("Done", for: .normal)
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
//            shouldDeselectIfDismissed = true
            selectButtonSelected = false
//            print("firstTime")
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
                
                
//                let urlString = "\(folderURL)\(samplePhoto.filePath)"
//                if let newURL = URL(string: urlString) {
//                    if let newImage = newURL.loadImageFromDocumentDirectory() {
//                        imageSize = newImage.size
//                    }
//                }
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
            attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                SwiftEntryKit.display(entry: vc, using: attributes)
            })
            
        }
//        collectionView.layoutIfNeeded()
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        if viewControllerToPresent.title == "PhotoPageContainerViewController" {
//            print("Photo Page Con")
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        } else {
//        print("normal")
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
        
        
        print("give")
        if popup == "Keep" {
            let alertView = SPAlertView(title: "Kept cached photos!", message: "Tap to dismiss", preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
        } else if popup == "Finished" {
            let alertView = SPAlertView(title: "Caching done!", message: "Tap to dismiss", preset: SPAlertPreset.done)
            alertView.duration = 4
            alertView.present()
            
        }
        
        print("give photos: \(photos)")
        if let photoCats = photoCategories {
            
            for currentPhoto in photoCats {
                for cachedPhoto in photos {
                    
                    if currentPhoto.dateCreated == cachedPhoto.dateCreated {
                        do {
                            try realm.write {
                                currentPhoto.isDeepSearched = cachedPhoto.isDeepSearched
//                                currentPhoto.contents.removeAll()
                                
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
//            getData()
            collectionView.reloadData()
            
            print("PHOTO CATS: \(photoCats)")
            photoCategories = photoCats
        }
    }
    
    
    
}


extension NewHistoryViewController : UICollectionViewDelegateFlowLayout {
  //1
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
//        attributes.lifecycleEvents.willDisappear = {
//                self.fadeSelectOptions(fadeOut: "fade out")
//        }
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
        print("button delegate")
        var tempPhotos = [HistoryModel]()
        var deleteFromSections = [Int: Int]()
        var filePaths = [URL]()
        
        var sectionsTouched = [Int]()
        
        var alreadyCached = 0
//        var shouldCache = true
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
//                guard let finalUrl = URL(string: "\(folderURL)\(urlString)") else { print("Invalid File name"); return }
                if photo.isDeepSearched == true {
                    alreadyCached += 1
                }
                filePaths.append(finalUrl)
                tempPhotos.append(photo)
            }
        }
//        if alreadyCached == tempPhotos.count {
//            shouldCache = false
//        }
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
            print("INDEX COUNT: \(indexPathsSelected.count)")
//            var titleMessage = ""
       
            
            var titleMessage = ""
            var finishMessage = ""
            if indexPathsSelected.count == 1 {
                titleMessage = "Delete photo?"
                finishMessage = "Photo deleted!"
            } else if indexPathsSelected.count == photoCategories?.count {
                titleMessage = "Delete ALL photos?!"
                finishMessage = "All photos deleted!"
            } else {
                titleMessage = "Delete \(indexPathsSelected.count) photos?"
                finishMessage = "\(indexPathsSelected.count) photos deleted!"
            }
            
            let alert = UIAlertController(title: titleMessage, message: "This action can't be undone.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive, handler: { _ in
                
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
                
    //            print("CONTS: \(contents)")
                
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
//                for section in sectionsToDelete {
//
//                }
                tempIntSelected.removeAll()
                
                let alertView = SPAlertView(title: finishMessage, message: "Tap to dismiss", preset: SPAlertPreset.done)
                alertView.duration = 2.6
                alertView.present()
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
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
                attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(300))
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
//                        var newContents = [SingleHistoryContent]()
//                        for content in singleItem.contents {
//                            newContents.append(content)
//                        }
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
//                print("O CACHE")
                var arrayOfUncache = [Int]()
                for indexP in indexPathsSelected {
                    if let index = indexPathToIndex[indexP] {
                        arrayOfUncache.append(index)
                    }
                }
//                var message = ""
//                if arrayOfUncache.count == 1 {
//                    message = "1 cache!"
//                } else {
//                    message = "\(arrayOfUncache.count) caches!"
//                }
                var titleMessage = ""
                var finishMessage = ""
                if arrayOfUncache.count == 1 {
                    titleMessage = "Clear this photo's cache?"
                    finishMessage = "Cache cleared!"
                } else if arrayOfUncache.count == photoCategories?.count {
                    titleMessage = "Clear ENTIRE cache?!"
                    finishMessage = "Entire cache cleared!"
                } else {
                    titleMessage = "Clear \(arrayOfUncache.count) photos' caches?"
                    finishMessage = "\(arrayOfUncache.count) caches deleted!"
                }
                
                let alert = UIAlertController(title: titleMessage, message: "Caching again will take a while...", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Clear", style: UIAlertAction.Style.destructive, handler: { _ in
                    self.uncachePhotos(at: arrayOfUncache)
                    let alertView = SPAlertView(title: finishMessage, message: "Tap to dismiss", preset: SPAlertPreset.done)
                    alertView.duration = 2.6
                    alertView.present()
                    
                    self.selectButtonSelected = false
                    self.fadeSelectOptions(fadeOut: "fade out")
                    SwiftEntryKit.dismiss()
                    self.collectionView.allowsMultipleSelection = false
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
//        case "help":
//            print("help")
//            self.selectButtonSelected = false
//            self.fadeSelectOptions(fadeOut: "fade out")
//            self.collectionView.allowsMultipleSelection = false
        case "share":
            print("share")
//            var arrayOfPhotos = [UIImage]()
//            var arrayOfModels = [EditableHistoryModel]()
            var arrayOfUrlStrings = [String]()
            for indexP in indexPathsSelected {
                let bigItem = indexToData[indexP.section]
                if let photo = bigItem?[indexP.item] {
//                    arrayOfModels.append(photo)
//                    let photoUrl = folderURL.appendingPathComponent(photo.filePath)
//                    if let photoToAppend = photoUrl.loadImageFromDocumentDirectory() {
//                        arrayOfPhotos.append(photoToAppend)
//                    }
//                    let newHistModel = EditableHistoryModel()
//                    newHistModel.filePath = photo.filePath
//                    arrayOfModels.append(newHistModel)
                    arrayOfUrlStrings.append(photo.filePath)
                }
            }
//            shareData(arrayOfPhotos)
            shareData(arrayOfUrlStrings)
            
            
        default: print("unknown, bad string")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToHistoryFind":
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
            print("PHOTOARR: \(modelArray)")
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
//    var itemProvidersForActivityItemsConfiguration: [NSItemProvider] {
//        ret
//    }
    
    func shareData(_ dataToShare: [String]) {
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            print("hpne:")
            SwiftEntryKit.dismiss()
        default:
            print("other")
        }
        var objects = [HistorySharing]()
        for url in dataToShare {
            let shareObject = HistorySharing(filePath: url, folderURL: folderURL)
            objects.append(shareObject)
        }
//        let shareObject = HistorySharing(imageModels: dataToShare, folderURL: folderURL)
//        print("share: \(shareObject.item)")
//        let activityViewController = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
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
                print("phonte represent:")
                self.rePresentFloat()
            default:
                print("other")
            }
            
        }
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 42, height: 42)
            popoverController.sourceView = tempShareView
//            popoverController.permittedArrowDirections = .up
        }
        present(tempController, animated: true) { [weak tempController] in
            tempController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
extension NewHistoryViewController {
    
    func uncachePhotos(at: [Int]) {
        
        if let photoCats = photoCategories {
//            let deleteContents = [SingleHistoryContent]()
            for index in at {
                let realmPhoto = photoCats[index]
                do {
                    try realm.write {
                        realm.delete(realmPhoto.contents)
                        realmPhoto.isDeepSearched = false
                    }
                } catch {
                    print("ERROR Changing CACHEHHE!! \(error)")
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
        
//        let fm = FileManager.default
//        do {
//            let paths = try fm.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
//          for path in paths
//          {
//            print("path: \(path)")
////            let finalP = "\(folderURL)/\(path)"
////            print("final: \(finalP)")
//            try fm.removeItem(at: path)
//          }
//        } catch {
//          print(error.localizedDescription)
//        }
//        try! realm.write {
//            realm.deleteAll()
//        }
        
        indexToData.removeAll()
        sectionToDate.removeAll()
        sectionCounts.removeAll()
        
        var arrayOfPaths = [URL]()
        var arrayOfCategoryDates = [Date]()
//        var tempDictOfImagePaths = [Date: [URL]]()
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
//            print("file path: \(singleHi st.filePath)")
//            print("Splits: \(splits)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyy"

            guard let dateFromString = dateFormatter.date(from: splits[1]) else { print("no date wrong... return"); return}
            if !arrayOfCategoryDates.contains(dateFromString) {
                arrayOfCategoryDates.append(dateFromString)
            }
            
//            let imagePath = "\(folderURL)/\(singleHist.filePath)"
            if !arrayOfCategoryDates.contains(dateFromString) {
                arrayOfCategoryDates.append(dateFromString)
            }
            let finalUrl = folderURL.appendingPathComponent(singleHist.filePath)
//            if let imageUrl = URL(string: imagePath) {
//                tempDictOfImagePaths[dateFromString, default: [URL]()].append(imageUrl)
            if dateToNumber[dateFromString] == nil {
                dateToNumber[dateFromString] = 0
            } else {
                dateToNumber[dateFromString]! += 1
            }
//                arrayOfPaths.append(imageUrl)
            arrayOfPaths.append(finalUrl)
//            }
        }
        arrayOfCategoryDates.sort(by: { $0.compare($1) == .orderedDescending})
//        arrayOfPaths.sort(by: { $0.compare($1) == .orderedDescending})
        
        var count = -1
        for (index, date) in arrayOfCategoryDates.enumerated() {
            sectionCounts.append(0)
            sectionToDate[index] = date
            
            if let numberOfPhotosInDate = dateToNumber[date] {
                print("NUM PO: \(numberOfPhotosInDate)")
                for secondIndex in 0...numberOfPhotosInDate {
                    count += 1
                    let indexPath = IndexMatcher()
                    indexPath.section = index
                    indexPath.row = secondIndex
                    sectionCounts[index] += 1
                    
                    let indP = IndexPath(item: secondIndex, section: index)
                    indexPathToIndex[indP] = count
                    indexToIndexPath[count] = indP
//                    dictOfUrls[indexPath] = individualUrl
                    
                    if let newHistModel = photoCategories?[count] {
                        indexToData[index, default: [HistoryModel]()].append(newHistModel)
//                        print("HIST MODE: \(newHistModel)")
                    }

                }
            }

        }
        print("histDataCount: \(indexToData.count)")
    }
}

extension Date {
    func convertDateToReadableString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        let todaysDate = Date()
        let todaysDateAsString = dateFormatter.string(from: todaysDate)
        let yesterday = todaysDate.subtract(days: 1)
        let yesterdaysDateAsString = dateFormatter.string(from: yesterday!)
        
        let oneWeekAgo = todaysDate.subtract(days: 7)
        let yestYesterday = yesterday?.subtract(days: 1)
        let range = oneWeekAgo!...yestYesterday!
        
        let stringDate = dateFormatter.string(from: self)
        
        if stringDate == todaysDateAsString {
            return "Today"
        } else if stringDate == yesterdaysDateAsString {
            return "Yesterday"
        } else {
            if range.contains(self) {
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: self)
            } else {
                dateFormatter.dateFormat = "MMMM d',' yyyy"
                return dateFormatter.string(from: self)
            }
        }
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
        print("DELEting!")
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
//                guard let finalUrl = URL(string: "\(folderURL)\(urlString)") else { print("Invalid File name"); return }
                
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
                    print("ERROR DELETIN!! \(error)")
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
        print("select path")
//        self.selectedIndexPath = IndexPath(row: currentIndex, section: currentSection)
//        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
//
        if let indexPath = indexToIndexPath[currentIndex] {
            
            if let cell = collectionView.cellForItem(at: selectedIndexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[selectedIndexPath.section] else { print("NO CELL MODEL"); return }
                let historyModel = hisModel[selectedIndexPath.item]
                if historyModel.isHearted == true {
//                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 1
                        cell.pinkTintView.alpha = 1
//                    })
                } else {
//                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 0
                        cell.pinkTintView.alpha = 0
//                    })
                }
            }
            selectedIndexPath = indexPath
            
            if let cell = collectionView.cellForItem(at: indexPath) as? HPhotoCell {
                guard let hisModel = self.indexToData[indexPath.section] else { print("NO CELL MODEL"); return }
                let historyModel = hisModel[indexPath.item]
                if historyModel.isHearted == true {
//                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 1
                        cell.pinkTintView.alpha = 1
//                    })
                } else {
//                    UIView.animate(withDuration: 0.2, animations: {
                        cell.heartView.alpha = 0
                        cell.pinkTintView.alpha = 0
//                    })
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
//            print("RECIEVE CACHE!!")
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
                guard let hisModel = self.indexToData[selectedIndexPath.section] else { print("NO CELL MODELReturn"); return }
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
        print("cellframe: \(cellFrame)")
        
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
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.imageView
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
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
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
            return guardedCell.frame
        }
        //Otherwise the cell should be visible
        else {
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
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
//        let sections = collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader)
//        for section in sections {
////            section.
////            let nd = section.ind
//            if let header = section as? TitleSupplementaryView {
////                header.todayLabel.text =
//                if let date = sectionToDate[modifiedSection] {
//                    let readableDate = date.convertDateToReadableString()
//                    header.todayLabel.text = readableDate
//                }
//            }
//        }
    }
    func reloadEdgeItems(modifiedSection: Int) {
        if let section = indexToData[modifiedSection] {
            var reloadPaths = [IndexPath]()
            let sectionCount = section.count
            print("SEC COUNT: \(sectionCount)")
            if section.count <= 6 {
                print("6 under")
                for (index, item) in section.enumerated() {
                    print("sec: \(item), ind: \(index)")
                    let indP = IndexPath(item: index, section: modifiedSection)
                    reloadPaths.append(indP)
                }
            } else {
                print("Else")
                let firstThree = [IndexPath(item: 0, section: modifiedSection), IndexPath(item: 1, section: modifiedSection), IndexPath(item: 2, section: modifiedSection)]
                let last = sectionCount - 1
                let secondToLast = sectionCount - 2
                let thirdToLast = sectionCount - 3
                
                let lastThree = [IndexPath(item: thirdToLast, section: modifiedSection), IndexPath(item: secondToLast, section: modifiedSection), IndexPath(item: last, section: modifiedSection)]
                
                reloadPaths = firstThree + lastThree
                
            }
            if reloadPaths.count >= 1 {
                print("MORE THAN !")
//                collectionView.reloadItems(at: reloadPaths)
                for path in reloadPaths {
                    print("path...")
                    if let cell = collectionView.cellForItem(at: path) as? HPhotoCell {
                        let (shouldRound, corners) = calculateCornerRadius(indexPath: path)
                        if shouldRound {
                            print("Round")
//                            cell.layer.maskedCorners = []
                            UIView.animate(withDuration: 0.3, animations: {
                                cell.layer.cornerRadius = 4
                                cell.layer.maskedCorners = corners
//                                cell.layoutIfNeeded()
                            })
                        } else {
                            print("NO")
                            UIView.animate(withDuration: 0.3, animations: {
                                cell.layer.cornerRadius = 0
//                                cell.layoutIfNeeded()
                            })
                        }
                        
                    }
                }
            }
        }
    }
    func calculateCornerRadius(indexPath: IndexPath) -> (Bool, CACornerMask) {
        
        
//        print("start___")
//    view.layer.maskedCorners
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
//        print("EXIT")
        return (false, [])
    }
}
