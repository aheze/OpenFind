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
class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
    
    
    //MARK: Realm
    let realm = try! Realm()
    var photoCategories: Results<HistoryModel>?
//    var photoCategories: [IndexMatcher: Results<RealmPhoto>]?
//    var photoCategories = [IndexMatcher: ]
 

//    var presentingCache = false
    
    //MARK: Finding
    var shouldDismissSEK = true
    var selectedIndexPath: IndexPath!
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var sectionToDate: [Int: Date] = [Int: Date]()
//    var dateToFilepaths = [Date: [URL]]()
//    var dictOfUrls = [IndexMatcher: URL]()
    
    var indexToData = [Int: [HistoryModel]]()
    
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
            print("SETTTUTUTOUTOUOUTOUT")
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
    }
    var selectionMode: Bool = false {
        didSet {
            print("selection mode: \(selectionMode)")
            collectionView.allowsMultipleSelection = selectionMode
            indexPathsSelected.removeAll()
//            fileUrlsSelected.removeAll()
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
   // @IBOutlet weak var selectIndicator: UIImageView!
    
    @IBOutlet weak var selectButton: UIButton!
    
    @IBOutlet weak var selectAll: UIButton!
    var deselectAll = true
    
    @IBOutlet weak var inBetweenSelect: NSLayoutConstraint!
    var selectButtonSelected = false ///False means is Select, true = Cancel
    var swipedToDismiss = true
    
    @IBAction func selectAllPressed(_ sender: UIButton) {
        deselectAll = !deselectAll
        if deselectAll == false { //Select All cells, change label to opposite
            print("select all")
            selectAll.setTitle("Deselect All", for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: false)
        } else {
            print("deselect all")
            selectAll.setTitle("Select All", for: .normal)
            UIView.animate(withDuration: 0.09, animations: {
                self.view.layoutIfNeeded()
            })
            deselectAllItems(deselect: true)
        }
    }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        selectButtonSelected = !selectButtonSelected ///First time press, will be true
        if selectButtonSelected == true {
            print("select")
            fadeSelectOptions(fadeOut: "fade in")
        } else { ///Cancel will now be Select
            print("cancel")
            //selectButtonSelected = true
            swipedToDismiss = false
            fadeSelectOptions(fadeOut: "fade out")
            swipedToDismiss = true
        }
    }
    
    func fadeSelectOptions(fadeOut: String) {
        switch fadeOut {
        case "fade out":
            if swipedToDismiss == false {
                SwiftEntryKit.dismiss()
            }
            deselectAll = true
            UIView.transition(with: selectButton, duration: 0.1, options: .transitionCrossDissolve, animations: {
              self.selectButton.setTitle("Select", for: .normal)
            }, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                UIView.transition(with: self.selectAll, duration: 0.1, options: .transitionCrossDissolve, animations: {
                  self.selectAll.setTitle("Select All", for: .normal)
                }, completion: nil)
            })
            
            inBetweenSelect.constant = -5
            selectAll.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
                self.selectAll.alpha = 0
            }) { _ in
                self.selectAll.isHidden = true
            }
            deselectAllItems(deselect: true)
            
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
                attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
                attributes.lifecycleEvents.willDisappear = {
                    if self.shouldDismissSEK == true {
                        self.fadeSelectOptions(fadeOut: "fade out")
                        self.selectButtonSelected = false
                        self.enterSelectMode(entering: false)
                    }
                }
                let customView = HistorySelectorView()
                customView.buttonPressedDelegate = self
                
                
                changeFloatDelegate = customView
                changeNumberDelegate = customView
                //selectionMode = true
                //changeNumberDelegate?.changeLabel(to: 4)
                SwiftEntryKit.display(entry: customView, using: attributes)
                enterSelectMode(entering: true)
                
                selectButton.setTitle("Done", for: .normal)
                inBetweenSelect.constant = 5
                selectAll.isHidden = false
                UIView.animate(withDuration: 0.5, animations: {
                    self.selectAll.alpha = 1
                    self.view.layoutIfNeeded()
                })
            }
            
        case "firstTimeSetup":
            selectAll.alpha = 0
            selectAll.isHidden = true
            print("firstTime")
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
        
        
        
        deselectAllItems(deselect: true)
        
        selectButton.layer.cornerRadius = 6
        selectAll.layer.cornerRadius = 6
        fadeSelectOptions(fadeOut: "firstTimeSetup")
        //self.transitioningDelegate = transitionDelegate
//        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        layout?.sectionHeadersPinToVisibleBounds = true
        print("asd")
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        
        print("asdcontent")
        if photoCategories?.count ?? 0 > 0 {
            if let samplePath = photoCategories?[0] {
                print("asdsample")
                let urlString = "\(folderURL)\(samplePath.filePath)"
                if let newURL = URL(string: urlString) {
                    if let newImage = loadImageFromDocumentDirectory(urlOfFile: newURL) {
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
            
            let readableDate = convertDateToReadableString(theDate: date)
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
            print("YES PATH")
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
            
            print("CELL (\(indexPath)) IS SELECTed: \(cell.isSelected)")
            if indexPathsSelected.contains(indexPath) {
                print("contains select")
                UIView.animate(withDuration: 0.1, animations: {
                    
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    cell.highlightView.alpha = 1
                    cell.checkmarkView.alpha = 1
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            } else {
                print("contains DEselect")
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
//            print("deselcccccc")
            
//            for i in 0..<collectionView.numberOfSections {
//                for j in 0..<collectionView.numberOfItems(inSection: i) {
//                    collectionView.deselectItem(at: IndexPath(row: j, section: i), animated: false)
//                }
//            }

//            fileUrlsSelected.removeAll()
            
            numberOfSelected = 0
            var reloadPaths = [IndexPath]()
            for indexP in indexPathsSelected {
                
                
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
                    print("Not visible")
                }
                
            }
            collectionView.reloadItems(at: reloadPaths)
            indexPathsSelected.removeAll()
        } else {
            
            print("select")
            var num = 0
            var reloadPaths = [IndexPath]()
            for i in 0..<collectionView.numberOfSections {
                for j in 0..<collectionView.numberOfItems(inSection: i) {
                    num += 1
                    let indP = IndexPath(row: j, section: i)
                    
    //                let indexPath = IndexPath(item: indexP, section: 0)
                    print("indexP select: \(indP)")
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
                        print("Not visible")
                    }
                    
                }
            }
            collectionView.reloadItems(at: reloadPaths)
            numberOfSelected = num
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did")
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
//        cell.isHighlighted = true
        if selectionMode == true {
            print("seleeeect")
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
            print("false")
            collectionView.deselectItem(at: indexPath, animated: true)
            
            let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
            mainContentVC.title = "PhotoPageContainerViewController"
            self.selectedIndexPath = indexPath
            mainContentVC.transitioningDelegate = mainContentVC.transitionController
            mainContentVC.transitionController.fromDelegate = self
            mainContentVC.transitionController.toDelegate = mainContentVC
            mainContentVC.delegate = self
            mainContentVC.currentIndex = indexPath.item
            mainContentVC.currentSection = indexPath.section
            //print(imageSize)
            mainContentVC.photoSize = imageSize
            
//            if let date = sectionToDate[indexPath.section] {
//                mainContentVC.photoPaths = dateToFilepaths[date]!
//            }
            var photoPaths = [URL]()
            if let hisModel = indexToData[indexPath.section] {
                print("YES PATH Select indexpath select transition push")
//                let historyModel = hisModel[indexPath.item]
                
                for historyModel in hisModel {
                    var urlPath = historyModel.filePath
                    urlPath = "\(folderURL)\(urlPath)"
                    if let finalUrl = URL(string: urlPath) {
                        photoPaths.append(finalUrl)
//                        fileUrlsSelected.append(finalUrl)
                    }
                }
                
            }
             mainContentVC.photoPaths = photoPaths
            
            // mainContentVC.photos = photos
            print("_____")
            //print(dateToFilepaths)
            self.present(mainContentVC, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselecting at indexpath")
        if selectionMode == true {
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
        print("Did Dismissss")
        shouldDismissSEK = true
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size.height = .constant(value: 50)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
        attributes.lifecycleEvents.willDisappear = {
            if self.shouldDismissSEK == true {
                self.fadeSelectOptions(fadeOut: "fade out")
                self.selectButtonSelected = false
                self.enterSelectMode(entering: false)
            }
        }
        let customView = HistorySelectorView()
        customView.buttonPressedDelegate = self
        
        
        changeFloatDelegate = customView
        changeNumberDelegate = customView
        //selectionMode = true
        //changeNumberDelegate?.changeLabel(to: 4)
        
        SwiftEntryKit.display(entry: customView, using: attributes)
//        enterSelectMode(entering: true)
        changeNumberDelegate?.changeLabel(to: numberOfSelected)
//        selectButton.setTitle("Done", for: .normal)
//        inBetweenSelect.constant = 5
//        selectAll.isHidden = false
//        UIView.animate(withDuration: 0.5, animations: {
//            self.selectAll.alpha = 1
//            self.view.layoutIfNeeded()
//        })
//        if cancelTimer != nil {
//            cancelTimer!.invalidate()
//            cancelTimer = nil
//        }
//        SwiftEntryKit.dismiss()
//        currentMatchStrings.append(newSearchTextField.text ?? "")
//        sortSearchTerms()
//        startVideo(finish: "end")
//       // listsCollectionView.reloadData()
//        loadListsRealm()
    }
    
}


extension NewHistoryViewController: ButtonPressed {
    func floatButtonPressed(button: String) {
        print("button delegate")
        var tempPhotos = [HistoryModel]()
        var deleteFromSections = [Int: Int]()
        var filePaths = [URL]()
        
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
//                print("URL: \(finalUrl)")
                filePaths.append(finalUrl)
                tempPhotos.append(photo)
            }
        }
//        print(sectionCounts)
//        print(deleteFromSections)
        for section in deleteFromSections {
            if sectionCounts[section.key] == section.value {
//                print("WHOLE SECTION")
                sectionsToDelete.append(section.key)
            }
        }
//        print("delete sections: \(sectionsToDelete)")
        switch button {
            
        case "test":
            print("delegate test worked")
        case "find":
            print("find pressed delegate")
            shouldDismissSEK = false
            SwiftEntryKit.dismiss()
            performSegue(withIdentifier: "goToHistoryFind", sender: self)
        case "heart":
            print("heart pressed delegate")
            
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
//            if selectedHeartCount >= selectedNotHeartCount {
//                shouldHeart = false
//            }
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
            SwiftEntryKit.dismiss()
//            collectionView.reloadItems(at: indexPathsSelected)
        case "delete":
            do {
                try realm.write {
                    realm.delete(tempPhotos)
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
            print("Before COLL COUNT: \(photoCategories?.count)")
            getData()
            if sectionsToDelete.count == 0 {
//                print("0000)))")
                collectionView.performBatchUpdates({
                    print("COLL COUNT: \(photoCategories?.count)")
                    print("SEL INDEX PATHS : \(indexPathsSelected)")
                    self.collectionView.deleteItems(at: indexPathsSelected)
                })
                
            } else {
                collectionView.performBatchUpdates({
                    let sections = IndexSet(sectionsToDelete)
                    self.collectionView.deleteSections(sections)
                })
            }
            
           
            indexPathsSelected.removeAll()
            SwiftEntryKit.dismiss()
//            fadeSelectOptions(fadeOut: "fade out")
//            selectButtonSelected = false
//            enterSelectMode(entering: false)
            
            
//            print("delete pressed delegate")
        case "cache":
            print("cache pressed delegate")
            var attributes = EKAttributes.centerFloat
            attributes.displayDuration = .infinity
            attributes.entryInteraction = .absorbTouches
            attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
            attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
            attributes.entryBackground = .color(color: .white)
            attributes.screenInteraction = .absorbTouches
            attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(300))
//            attributes.lifecycleEvents.willDisappear = {
//
//
//
//            }
           
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
            
//            var tempPhotos = [HistoryModel]()
            
            var editablePhotoArray = [EditableHistoryModel]()
            for item in indexPathsSelected {
                let itemToEdit = indexToData[item.section]
                if let singleItem = itemToEdit?[item.item] {
//                    tempPhotos.append(singleItem)
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
            
            
            
            cacheController.view.layer.cornerRadius = 10
            print("DAJFSDFSODFIODF: \(folderURL)")
            SwiftEntryKit.display(entry: cacheController, using: attributes)
            
        default: print("unknown, bad string")
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToHistoryFind":
            segue.destination.presentationController?.delegate = self
            let destinationVC = segue.destination as! HistoryFindController
            
//            var arrayOfFinds
            var modelArray = [HistoryModel]()
            for indexPath in indexPathsSelected {
                let itemToEdit = indexToData[indexPath.section]
                if let singleItem = itemToEdit?[indexPath.item] {
                    modelArray.append(singleItem)
                }
            }
            destinationVC.photos = modelArray
//            changeSearchPhotos = destinationVC
            print("going to find hist")
        default:
            print("BAD PATH SEGUE ID")
        }
    }
    
}


extension NewHistoryViewController {

    func populateRealm() {
        print("POP")
//        listCategories = realm.objects(FindList.self)
        photoCategories = realm.objects(HistoryModel.self)
        
    }
    func sortHist() {
        print("SORT")
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
//                    dictOfUrls[indexPath] = individualUrl
                    
                    if let newHistModel = photoCategories?[count] {
                        indexToData[index, default: [HistoryModel]()].append(newHistModel)
                        
                    }

                }
            }

        }
        print("histDataCount: \(indexToData.count)")
//        print("URL COUNT: \(dictOfUrls.count)")
    }
    
    func loadImageFromDocumentDirectory(urlOfFile: URL) -> UIImage? {
        guard let image = UIImage(contentsOfFile: urlOfFile.path) else { return nil }
        return image
    }
    
    
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

extension NewHistoryViewController: PhotoPageContainerViewControllerDelegate {
 
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int, sectionDidUpdate currentSection: Int) {
        print("sdfhjk")
        self.selectedIndexPath = IndexPath(row: currentIndex, section: currentSection)
        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension NewHistoryViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = self.collectionView.cellForItem(at: self.selectedIndexPath) as! HPhotoCell
        
        let cellFrame = self.collectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.collectionView.contentInset.top {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.collectionView.contentInset.bottom {
            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
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
