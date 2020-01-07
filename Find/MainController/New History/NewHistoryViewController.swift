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
protocol UpdateImageDelegate: class {
    func changeImage(image: UIImage)
}

class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
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
    
    
    weak var delegate: UIAdaptivePresentationControllerDelegate?
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var selectButtonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    var selectButtonSelected = true
    var swipedToDismiss = true
    @IBAction func selectPressed(_ sender: UIButton) {
        selectButtonSelected = !selectButtonSelected
        if selectButtonSelected == false {
            print("select")
            
            fadeSelectOptions(fadeOut: "fade in")
        } else { ///Cancel
            print("cancel")
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
            selectButtonLeadingConstraint.constant = CGFloat(-4)
            UIView.animate(withDuration: 0.5, animations: {
                self.deleteButton.alpha = 0
                self.shareButton.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.deleteButton.isHidden = true
                self.shareButton.isHidden = true
            })
            let toImage = UIImage(named: "Select")
            UIView.transition(with: selectButton,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.selectButton.setImage(toImage, for: .normal)
                              },
                              completion: nil)
        case "fade in":
            // Create a basic toast that appears at the top
            var attributes = EKAttributes.bottomFloat
            attributes.entryBackground = .color(color: .white)
            attributes.entranceAnimation = .translation
            attributes.exitAnimation = .translation
            attributes.displayDuration = .infinity
            attributes.positionConstraints.size.height = .constant(value: 50)
            attributes.statusBar = .light
            attributes.lifecycleEvents.willDisappear = {
                if self.swipedToDismiss == true {
                    self.fadeSelectOptions(fadeOut: "fade out")
                    self.swipedToDismiss = false
                    self.selectButtonSelected = !self.selectButtonSelected
                }
                
                
            }
            let customView = HistorySelect()
            SwiftEntryKit.display(entry: customView, using: attributes)
            
            deleteButton.isHidden = false
            shareButton.isHidden = false
            selectButtonLeadingConstraint.constant = CGFloat(4)
            UIView.animate(withDuration: 0.5, animations: {
                self.deleteButton.alpha = 1
                self.shareButton.alpha = 1
                self.view.layoutIfNeeded()
            })
            let toImage = UIImage(named: "Cancel")
            UIView.transition(with: selectButton,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: {
                                self.selectButton.setImage(toImage, for: .normal)
                              },
                              completion: nil)
        case "firstTimeSetup":
            deleteButton.alpha = 0
            deleteButton.isHidden = true
            
            shareButton.alpha = 0
            shareButton.isHidden = true
            
            selectButtonLeadingConstraint.constant = CGFloat(-4)
            view.layoutIfNeeded()
        default:
            print("unknown case, fade")
        }
    }
    
    
    @IBAction func deletePressed(_ sender: UIButton) {
        print("delete")
    }
    
    @IBAction func sharePressed(_ sender: UIButton) {
        print("share")
    }
    
    
    
    
    @IBOutlet weak var blackXButtonView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        fadeSelectOptions(fadeOut: "firstTimeSetup")
        //self.transitioningDelegate = transitionDelegate
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooterId", for: indexPath) as! FooterView
            footerView.clipsToBounds = false
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
extension NewHistoryViewController : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
//    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//    let availableWidth = view.frame.width - paddingSpace
//    let widthPerItem = availableWidth / itemsPerRow
//
//    return CGSize(width: widthPerItem, height: widthPerItem)
    let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 3
    return CGSize(width: itemSize, height: itemSize)
  }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
//  //3
//  func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      insetForSectionAt section: Int) -> UIEdgeInsets {
//    return sectionInsets
//  }
//
//  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }





}

extension NewHistoryViewController {
    func getData() {
        var arrayOfCategoryDates = [Date]()
        var tempDictOfImagePaths = [Date: [URL]]()
        
        //print(folderURL.path)
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            for theFileName in items {
                //print(item)
                //let theFileName = (item as NSString).lastPathComponent
                //print(theFileName)
                //print(folderURL.path)
                let splits = theFileName.split(separator: "=")
                
                let categoryName = String(splits[0])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyy"
                let dateFromString = dateFormatter.date(from: String(splits[0]))!
                
//                    if let image = loadImageFromDocumentDirectory(urlOfFile: folderURL, nameOfImage: theFileName) {
//                        dictOfHists[dateFromString, default: [UIImage]()].append(image)
//                        //tempDictOfImagePaths[dateFromString]?.append(item)
//                    }
                let imagePath = "\(folderURL)/\(theFileName)"
                if !arrayOfCategoryDates.contains(dateFromString) {
                    arrayOfCategoryDates.append(dateFromString)
                }
                if let imageUrl = URL(string: imagePath) {
                    tempDictOfImagePaths[dateFromString, default: [URL]()].append(imageUrl)
                    
                }
                
            }
            
            //print(tempDictOfImagePaths)
        } catch {
            print("error getting photos... \(error)")
        }
       
//        var tempCategories = [Date]()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMddyy"
//        for dict in dictOfHists {
//            let dictDate = dict.key
//            tempCategories.append(dictDate)
//        }
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
                    //print(sectionCounts[index])
                }
            }
            
        }
        //print(dictOfUrls)
        //print(tempCategories)
//        for (index, theDate) in arrayOfCategoryDates.enumerated() {
//            dictOfFormats[index] = theDate
//        }
        //print("how many categories:\(dictOfFormats.count)")
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
