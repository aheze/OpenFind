//
//  HCollectionViewController.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit
import SDWebImage
import SwiftEntryKit
import RealmSwift
import SPAlert

protocol UpdateImageDelegate: class {
    func changeImage(image: UIImage)
}
protocol ChangeNumberOfSelected: class {
    func changeLabel(to: Int)
}
protocol ChangeAttributes: class {
    func changeFloat(to: String)
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
//    var photoCategories: [IndexMatcher: Results<RealmPhoto>]?
//    var photoCategories = [IndexMatcher: ]
 
    
    var aboutToBeCached = [HistoryModel]()

//    var presentingCache = false
    
    //MARK: Finding
//    var shouldDismissSEK = true
    var selectedIndexPath: IndexPath!
    
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
    
//    var shouldDeselectIfDismissed = true
//    var selectionMode: Bool = false {
//        didSet {
//            print("selection mode: \(selectionMode)")
//            collectionView.allowsMultipleSelection = selectionMode
//            indexPathsSelected.removeAll()
////            fileUrlsSelected.removeAll()
//        }
//    }
    
    func checkForHearts() {
        var selectedHeartCount = 0
            var selectedNotHeartCount = 0
            for item in indexPathsSelected {
                let itemToEdit = indexToData[item.section]
                
                if let singleItem = itemToEdit?[item.item] {///Not very clear but ok
                    
                    if singleItem.isHearted == true {
                        selectedHeartCount += 1
                    } else {
                        selectedNotHeartCount += 1
                    }
                }
            }
//            var shouldHeart = true
            if selectedNotHeartCount >= selectedHeartCount {
//                shouldHeart = false
                shouldHeart = true
                changeFloatDelegate?.changeFloat(to: "Unfill Heart")
            } else {
                changeFloatDelegate?.changeFloat(to: "Fill Heart")
                shouldHeart = false
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
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
//                attributes.lifecycleEvents.willDisappear = {
////                    if self.shouldDismissSEK == true {
//                        self.fadeSelectOptions(fadeOut: "fade out")
////                        self.selectButtonSelected = false
////                        self.enterSelectMode(entering: false)
////                    }
//                }
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
    
    @IBOutlet weak var blackXButtonView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        populateRealm()
        sortHist()
        getData()
//        clearHistoryImages()
        
        selectButton.layer.cornerRadius = 6
        selectAll.layer.cornerRadius = 6
        fadeSelectOptions(fadeOut: "firstTimeSetup")
        deselectAllItems(deselect: true)
        
//        changeFloatDelegate?.changeFloat(to: "Disable")
//        indexPathsSelected.removeAll()
        //self.transitioningDelegate = transitionDelegate
//        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        layout?.sectionHeadersPinToVisibleBounds = true
//        print("asd")
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 82, right: 16)
        
//        print("asdcontent")
        if photoCategories?.count ?? 0 > 0 {
            if let samplePath = photoCategories?[0] {
//                print("asdsample")
                let urlString = "\(folderURL)\(samplePath.filePath)"
                if let newURL = URL(string: urlString) {
                    if let newImage = newURL.loadImageFromDocumentDirectory() {
                        imageSize = newImage.size
                    }
                }
            }
        }
//        if let sampleDate = sectionToDate[0] {
//            if let sampleImagePath = dateToFilepaths[sampleDate] {
//                if let newImage = loadImageFromDocumentDirectory(urlOfFile: sampleImagePath.first!) {
//                    imageSize = newImage.size
//                }
//            }
//        }
        setUpXButton()
        
        indexPathsSelected.removeAll()
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
        if viewControllerToPresent.title == "PhotoPageContainerViewController" {
            print("Photo Page Con")
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        } else {
        print("normal")
        }
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 4)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeaderId", for: indexPath) as! TitleSupplementaryView
            //headerView.todayLabel.text = "Text: \(indexPath.section)"
            let date = sectionToDate[indexPath.section]!
            
            let readableDate = date.convertDateToReadableString()
            headerView.todayLabel.text = readableDate
            headerView.clipsToBounds = false
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooterId", for: indexPath) as! FooterView
            footerView.clipsToBounds = false
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }
    }
    //MARK: Realm Converter
    
    var indexNumber = 0
    func indexmatcherToInt(indexMatcher: IndexMatcher) -> Int {
        indexNumber += 1
        return indexNumber
        
    }
    func setUpXButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackXPress(_:)))
        blackXButtonView.addGestureRecognizer(tap)
        blackXButtonView.isUserInteractionEnabled = true
    }
    @objc func handleBlackXPress(_ sender: UITapGestureRecognizer? = nil) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        SwiftEntryKit.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionCounts.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionCounts[section]
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
        
        if let hisModel = indexToData[indexPath.section] {
//            print("YES PATH")
            let historyModel = hisModel[indexPath.item]
            
            var urlPath = historyModel.filePath
            urlPath = "\(folderURL)\(urlPath)"
            let finalUrl = URL(string: urlPath)
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.imageView.sd_imageTransition = .fade
            cell.imageView.sd_setImage(with: finalUrl)
            
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
            
//            print("CELL (\(indexPath)) IS SELECTed: \(cell.isSelected)")
            if indexPathsSelected.contains(indexPath) {
//                print("contains select")
                UIView.animate(withDuration: 0.1, animations: {
                    
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    cell.highlightView.alpha = 1
                    cell.checkmarkView.alpha = 1
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
//                print("contains DEselect")
                UIView.animate(withDuration: 0.1, animations: {
//                    cell.isSelected = false
                    collectionView.deselectItem(at: indexPath, animated: false)
                    cell.highlightView.alpha = 0
                    cell.checkmarkView.alpha = 0
                    cell.transform = CGAffineTransform.identity
                })
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { suggestedActions in
            // Create an action for sharing
//            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
//                // Show share sheet
//            }

            // Create an action for copy
            let heart = UIAction(title: "Heart", image: UIImage(systemName: "heart")) { action in
                // Perform copy
            }

            // Create an action for delete with destructive attributes (highligh in red)
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
            }

                    // Empty menu for demonstration purposes
                return UIMenu(title: "asdf", children: [ heart, delete])
            
            
    
            // Create a UIMenu with all the actions as children
            
        }
    }
    //MARK: Selection
    func deselectAllItems(deselect: Bool) {
        if deselect == true {
            numberOfSelected = 0
            var reloadPaths = [IndexPath]()
            for indexP in indexPathsSelected {
//                print("indPPP")
                
//                let indexPath = IndexPath(item: indexP, section: 0)
//                print("indexP deselect: \(indexP)")
                collectionView.deselectItem(at: indexP, animated: false)
                if let cell = collectionView.cellForItem(at: indexP) as? HPhotoCell {
                    UIView.animate(withDuration: 0.1, animations: {
                        cell.highlightView.alpha = 0
                        cell.checkmarkView.alpha = 0
                        cell.transform = CGAffineTransform.identity
                    })
                } else {
                    reloadPaths.append(indexP)
    //                collectionView.reloadItems(at: [indexPath])
//                    print("Not visible")
                }
                
            }
            collectionView.reloadItems(at: reloadPaths)
            indexPathsSelected.removeAll()
//            print("deselc!!!")
//            print(indexPathsSelected)
        } else {
            
//            print("select")
            var num = 0
            var reloadPaths = [IndexPath]()
            for i in 0..<collectionView.numberOfSections {
                for j in 0..<collectionView.numberOfItems(inSection: i) {
                    num += 1
                    let indP = IndexPath(row: j, section: i)
                    
    //                let indexPath = IndexPath(item: indexP, section: 0)
//                    print("indexP select: \(indP)")
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
    //                        print("Not visible")
                        }
                    }
                    
                }
            }
            collectionView.reloadItems(at: reloadPaths)
            numberOfSelected = num
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("did")
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
//        cell.isHighlighted = true
        if selectButtonSelected == true {
//            print("seleeeect")
            if !indexPathsSelected.contains(indexPath) {
                print("Doesnt conatin \(indexPath)")
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
//            print("false")
            collectionView.deselectItem(at: indexPath, animated: true)
            
            print("SELECTJL")
            
            
            if let currentIndex = indexPathToIndex[indexPath] {
                
                
                let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
                                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
                mainContentVC.title = "PhotoPageContainerViewController"
                self.selectedIndexPath = indexPath
                mainContentVC.transitioningDelegate = mainContentVC.transitionController
                mainContentVC.transitionController.fromDelegate = self
                mainContentVC.transitionController.toDelegate = mainContentVC
                mainContentVC.delegate = self
                mainContentVC.currentIndex = currentIndex
    //            print("seleect: CURRENT INDEX: \(indexPath.item)")
    //            mainContentVC.currentSection = indexPath.section
                mainContentVC.photoSize = imageSize
                mainContentVC.cameFromFind = false
                mainContentVC.folderURL = folderURL
                mainContentVC.deletedPhoto = self
                
                
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
        //                                    realmContent.
        //                                    realnContent.
                            newHistModel.contents.append(realmContent)
                        }
                        modelArray.append(newHistModel)
                    }
                    mainContentVC.photoModels = modelArray
                }
                
                // mainContentVC.photos = photos
    //            print("_____")
                //print(dateToFilepaths)
                self.present(mainContentVC, animated: true)
            }
            
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselecting at indexpath")
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

extension NewHistoryViewController: ReturnCachedPhotos {
    func giveCachedPhotos(photos: [EditableHistoryModel], popup: String) {
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
//                        print("EQUALS")
                        do {
                            try realm.write {
                                currentPhoto.isDeepSearched = cachedPhoto.isDeepSearched
                                currentPhoto.contents.removeAll()
                                for cont in cachedPhoto.contents {
                                    let realmContent = SingleHistoryContent()
                                    realmContent.text = cont.text
                                    realmContent.height = Double(cont.height)
                                    realmContent.width = Double(cont.width)
                                    realmContent.x = Double(cont.x)
                                    realmContent.y = Double(cont.y)
//                                    realmContent.
//                                    realnContent.
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
        
        var alreadyCached = 0
        var shouldCache = true
        var sectionsToDelete = [Int]()
        for selected in indexPathsSelected {
            let section = selected.section
            if deleteFromSections[section] == nil {
                deleteFromSections[section] = 1
            } else {
                deleteFromSections[section]! += 1
            }
            if let photoCat = indexToData[selected.section] {
                let photo = photoCat[selected.item]
                let urlString = photo.filePath
                guard let finalUrl = URL(string: "\(folderURL)\(urlString)") else { print("Invalid File name"); return }
                if photo.isDeepSearched == true {
                    alreadyCached += 1
                }
                filePaths.append(finalUrl)
                tempPhotos.append(photo)
            }
        }
        if alreadyCached == tempPhotos.count {
            shouldCache = false
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
            var selectedHeartCount = 0
            var selectedNotHeartCount = 0
            for item in indexPathsSelected {
                let itemToEdit = indexToData[item.section]
                
                if let singleItem = itemToEdit?[item.item] {///Not very clear but ok
                    
                    if singleItem.isHearted == true {
                        selectedHeartCount += 1
                    } else {
                        selectedNotHeartCount += 1
                    }
                }
            }
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
            var titleMessage = ""
            if indexPathsSelected.count == 1 {
                titleMessage = "Delete photo?"
            } else {
                if indexPathsSelected.count == photoCategories?.count {
                    titleMessage = "Delete ALL photos?!"
                } else {
                    titleMessage = "Delete \(indexPathsSelected.count) photos?"
                }
                
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
                tempIntSelected.removeAll()
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
                        var newContents = [SingleHistoryContent]()
                        for content in singleItem.contents {
                            newContents.append(content)
                        }
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
                let alertView = SPAlertView(title: "Done caching!", message: "All selected photos were already cached", preset: SPAlertPreset.done)
                alertView.duration = 2.6
                alertView.present()
                
                selectButtonSelected = false
                fadeSelectOptions(fadeOut: "fade out")
                SwiftEntryKit.dismiss()
                collectionView.allowsMultipleSelection = false
            }
            
        default: print("unknown, bad string")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToHistoryFind":
            segue.destination.presentationController?.delegate = self
            let destinationVC = segue.destination as! HistoryFindController
            
//            var arrayOfFinds
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
    //                                    realmContent.
    //                                    realnContent.
                        newHistModel.contents.append(realmContent)
                    }
//                    for cont in singleItem.contents {
//                        newHistModel.contents.append(cont)
//                    }
                    
                    modelArray.append(newHistModel)
                }
            }
            destinationVC.folderURL = folderURL
            destinationVC.photos = modelArray
            print("PHOTOARR: \(modelArray)")
            modelArray.forEach { (edit) in
                print(edit.contents)
            }
            
            
            var tempPhotos = [HistoryModel]()
            var deleteFromSections = [Int: Int]()
            var filePaths = [URL]()
            
//            var alreadyCached = 0
//            var shouldCache = true
//            var sectionsToDelete = [Int]()
            for selected in indexPathsSelected {
//                let section = selected.section
//                if deleteFromSections[section] == nil {
//                    deleteFromSections[section] = 1
//                } else {
//                    deleteFromSections[section]! += 1
//                }
                if let photoCat = indexToData[selected.section] {
                    let photo = photoCat[selected.item]
                    tempPhotos.append(photo)
                }
            }
            
            
//            changeSearchPhotos = destinationVC
            print("going to find hist")
        default:
            print("BAD PATH SEGUE ID")
        }
    }
    
}


extension NewHistoryViewController {

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
        
//        try! realm.write {
//            realm.deleteAll()
//        }
        
        indexToData.removeAll()
        sectionToDate.removeAll()
        sectionCounts.removeAll()
        
        var arrayOfPaths = [URL]()
        var arrayOfCategoryDates = [Date]()
        var tempDictOfImagePaths = [Date: [URL]]()
        
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
            
            let imagePath = "\(folderURL)/\(singleHist.filePath)"
            if !arrayOfCategoryDates.contains(dateFromString) {
                arrayOfCategoryDates.append(dateFromString)
            }
            if let imageUrl = URL(string: imagePath) {
                tempDictOfImagePaths[dateFromString, default: [URL]()].append(imageUrl)
                arrayOfPaths.append(imageUrl)
            }
        }
        arrayOfCategoryDates.sort(by: { $0.compare($1) == .orderedDescending})
//        arrayOfPaths.sort(by: { $0.compare($1) == .orderedDescending})
        
        var count = -1
        for (index, date) in arrayOfCategoryDates.enumerated() {
            sectionCounts.append(0)
            sectionToDate[index] = date
            
            if let arrayOfImageUrls = tempDictOfImagePaths[date] {
                for (secondIndex, individualUrl) in arrayOfImageUrls.enumerated() {
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
//        print("URL COUNT: \(dictOfUrls.count)")
    }
    
//    func loadImageFromDocumentDirectory(urlOfFile: URL) -> UIImage? {
//        guard let image = UIImage(contentsOfFile: urlOfFile.path) else { return nil }
//        return image
//    }
    
    
    func convertDateToReadableString(theDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        let todaysDate = Date()
        let todaysDateAsString = dateFormatter.string(from: todaysDate)
        let yesterday = todaysDate.subtract(days: 1)
        let yesterdaysDateAsString = dateFormatter.string(from: yesterday!)
        
        let oneWeekAgo = todaysDate.subtract(days: 7)
        let yestYesterday = yesterday?.subtract(days: 1)
        let range = oneWeekAgo!...yestYesterday!
        
        let stringDate = dateFormatter.string(from: theDate)
        
        if stringDate == todaysDateAsString {
            return "Today"
        } else if stringDate == yesterdaysDateAsString {
            return "Yesterday"
        } else {
            if range.contains(theDate) {
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: theDate)
            } else {
                dateFormatter.dateFormat = "MMMM d',' yyyy"
                return dateFormatter.string(from: theDate)
            }
        }
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

extension NewHistoryViewController: ZoomDeletedPhoto {
    
    func deletedPhoto(photoIndex: Int) {
        print("DELEting!")
        var sectionToDelete = -1
        if let photoCats = photoCategories {
            let photoToDelete = photoCats[photoIndex]
            
            if let indP = indexToIndexPath[photoIndex] {
                let section = indP.section
                let photosInSection = indexToData[section]
                
                if photosInSection?.count == 1 {
                    sectionToDelete = section
                }
                
                var contents = [SingleHistoryContent]()
                for content in photoToDelete.contents {
                    contents.append(content)
                }
                
                do {
                    try realm.write {
                        realm.delete(contents)
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
            self.selectedIndexPath = indexPath
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
        }
    }
}

extension NewHistoryViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
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
        
        let heightDiff = UIScreen.main.bounds.size.height - view.bounds.size.height
        print("height diff: \(heightDiff)")
        cellFrame.origin.y += heightDiff
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
