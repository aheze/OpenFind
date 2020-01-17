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
class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
    
    
    //MARK: Realm
    let realm = try! Realm()
    var photoCategories: [IndexMatcher: Results<RealmPhoto>]?
 

    
    
    var selectedIndexPath: IndexPath!
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var sectionToDate : [Int: Date] = [Int: Date]()
    var dateToFilepaths = [Date: [URL]]()
    var dictOfUrls = [IndexMatcher: URL]()
    
    var sectionCounts = [Int]()
    var imageSize = CGSize(width: 0, height: 0)
    
    //let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    //private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 4
    
    //MARK:  Selection Variables
    //var indexPathsThatAreSelected = [IndexPath]()
    var fileUrlsSelected = [URL]()
    var indexPathsSelected = [IndexPath]()
    var selectionMode: Bool = false {
        didSet {
            print("selection mode: \(selectionMode)")
            collectionView.allowsMultipleSelection = selectionMode
            fileUrlsSelected.removeAll()
        }
    }
    var numberOfSelected = 0 {
        didSet {
            changeNumberDelegate?.changeLabel(to: numberOfSelected)
        }
    }
    
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    weak var changeNumberDelegate: ChangeNumberOfSelected?
    
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
            var attributes = EKAttributes.bottomFloat
            attributes.entryBackground = .color(color: .white)
            attributes.entranceAnimation = .translation
            attributes.exitAnimation = .translation
            attributes.displayDuration = .infinity
            attributes.positionConstraints.size.height = .constant(value: 50)
            attributes.statusBar = .light
            attributes.entryInteraction = .absorbTouches
            attributes.lifecycleEvents.willDisappear = {
                
                self.fadeSelectOptions(fadeOut: "fade out")
                self.selectButtonSelected = false
                self.enterSelectMode(entering: false)
            }
            let customView = HistorySelectorView()
            customView.buttonPressedDelegate = self
            changeNumberDelegate = customView 
            //selectionMode = true
            //changeNumberDelegate?.changeLabel(to: 4)
            SwiftEntryKit.display(entry: customView, using: attributes)
            enterSelectMode(entering: true)
            
            selectButton.setTitle("Cancel", for: .normal)
            inBetweenSelect.constant = 5
            selectAll.isHidden = false
            UIView.animate(withDuration: 0.5, animations: {
                self.selectAll.alpha = 1
                self.view.layoutIfNeeded()
            })
            
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
        getData()
        deselectAllItems(deselect: true)
        selectButton.layer.cornerRadius = 4
        selectAll.layer.cornerRadius = 4
        fadeSelectOptions(fadeOut: "firstTimeSetup")
        //self.transitioningDelegate = transitionDelegate
//        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        if let sampleDate = sectionToDate[0] {
            if let sampleImagePath = dateToFilepaths[sampleDate] {
                let newImage = loadImageFromDocumentDirectory(urlOfFile: sampleImagePath.first!)
                imageSize = newImage!.size
            }
        }
        setUpXButton()
    }
    override func present(_ viewControllerToPresent: UIViewController,
                          animated flag: Bool,
                          completion: (() -> Void)? = nil) {
      viewControllerToPresent.modalPresentationStyle = .fullScreen
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
        let newInd = IndexMatcher()
        newInd.section = indexPath.section
        newInd.row = indexPath.row
        let url = dictOfUrls[newInd]
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: url)
        if let photo = photoCategories?[newInd] {
        
        }
//        if photoCategories![newInd]?.isEmpty == true {
//            cell.heartView.alpha = 0
//            cell.addHeart(add: true)
//        }
        //cell.selectMode = selectionMode
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            // Create an action for sharing
            let share = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { action in
                // Show share sheet
            }

            // Create an action for copy
            let rename = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc")) { action in
                // Perform copy
            }

            // Create an action for delete with destructive attributes (highligh in red)
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                // Perform delete
            }

            // Create a UIMenu with all the actions as children
            return UIMenu(title: "", children: [share, rename, delete])
        }
    }
    //MARK: Selection
    func deselectAllItems(deselect: Bool) {
        if deselect == true {
            print("deselc")
            
            for i in 0..<collectionView.numberOfSections {
                for j in 0..<collectionView.numberOfItems(inSection: i) {
                    collectionView.deselectItem(at: IndexPath(row: j, section: i), animated: false)
                }
            }

            fileUrlsSelected.removeAll()
            indexPathsSelected.removeAll()
            numberOfSelected = 0
            
        } else {
            
            print("select")
            var number = 0
            for section in dictOfUrls.values {
                //let url = dictOfUrls[section]
                fileUrlsSelected.append(section)
                //cell.isSelected = true
                number += 1
            }
            for i in 0..<collectionView.numberOfSections {
                for j in 0..<collectionView.numberOfItems(inSection: i) {
                    collectionView.selectItem(at: IndexPath(row: j, section: i), animated: false, scrollPosition: [])
                }
            }
            numberOfSelected = number
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did")
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
//        cell.isHighlighted = true
        if selectionMode == true {
            print("seleeeect")
            
            let indexMatcher = IndexMatcher()
            indexMatcher.section = indexPath.section
            indexMatcher.row = indexPath.item
            if let filePath = dictOfUrls[indexMatcher] {
                fileUrlsSelected.append(filePath)
            }
            
            indexPathsSelected.append(indexPath)
            numberOfSelected += 1
                
        } else {
            print("false")
            collectionView.deselectItem(at: indexPath, animated: true)
            
            let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
            self.selectedIndexPath = indexPath
            mainContentVC.transitioningDelegate = mainContentVC.transitionController
            mainContentVC.transitionController.fromDelegate = self
            mainContentVC.transitionController.toDelegate = mainContentVC
            mainContentVC.delegate = self
            mainContentVC.currentIndex = indexPath.item
            mainContentVC.currentSection = indexPath.section
            //print(imageSize)
            mainContentVC.photoSize = imageSize
            
            if let date = sectionToDate[indexPath.section] {
                mainContentVC.photoPaths = dateToFilepaths[date]!
            }
            // mainContentVC.photos = photos
            print("_____")
            //print(dateToFilepaths)
            self.present(mainContentVC, animated: true)
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("deselecting at indexpath")
        if selectionMode == true {
            
            print("del")
            let indexMatcher = IndexMatcher()
            indexMatcher.section = indexPath.section
            indexMatcher.row = indexPath.item
            if let filePath = dictOfUrls[indexMatcher] {
                fileUrlsSelected.remove(object: filePath)
            }
            numberOfSelected -= 1
            //changeNumberDelegate?.changeLabel(to: numberOfSelected)
            
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

extension NewHistoryViewController: ButtonPressed {
    func floatButtonPressed(button: String) {
        print("button delegate")
        switch button {
            
        case "test":
            print("delegate test worked")
            
        case "find":
            print("find pressed delegate")
        case "heart":
            print("heart pressed delegate")
        case "delete":
            print("delete pressed delegate")
        case "share":
            print("share pressed delegate")
            
            
        default: print("unknown, bad string")
        }
    }
    
    
}


extension NewHistoryViewController {
    func getData() {
        var arrayOfCategoryDates = [Date]()
        var tempDictOfImagePaths = [Date: [URL]]()
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            for theFileName in items {
                let splits = theFileName.split(separator: "=")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyy"
                let dateFromString = dateFormatter.date(from: String(splits[0]))!
                let imagePath = "\(folderURL)/\(theFileName)"
                if !arrayOfCategoryDates.contains(dateFromString) {
                    arrayOfCategoryDates.append(dateFromString)
                }
                if let imageUrl = URL(string: imagePath) {
                    tempDictOfImagePaths[dateFromString, default: [URL]()].append(imageUrl)
                }
            }
        } catch {
            print("error getting photos... \(error)")
        }
        arrayOfCategoryDates.sort(by: { $0.compare($1) == .orderedDescending})
        
        for (index, date) in arrayOfCategoryDates.enumerated() {
            sectionCounts.append(0)
            sectionToDate[index] = date
            if let arrayOfImageUrls = tempDictOfImagePaths[date] {
                for (secondIndex, individualUrl) in arrayOfImageUrls.enumerated() {
                    var indexPath = IndexMatcher()
                    indexPath.section = index
                    indexPath.row = secondIndex
                    sectionCounts[index] += 1
                    dictOfUrls[indexPath] = individualUrl
                    
                    dateToFilepaths[date, default: [URL]()].append(individualUrl)
                    
                    do {
                        var photos = try Realm().objects(RealmPhoto.self)
                        let photo = photoCategories![indexPath]
                        
                    } catch {
                        print(error)
                    }
                    
                    
                    
                }
            }
            
        }
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
        cellFrame.origin.y += 40
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
