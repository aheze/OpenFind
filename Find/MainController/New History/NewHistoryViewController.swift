//
//  HCollectionViewController.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit

protocol UpdateImageDelegate: class {
    func changeImage(image: UIImage)
}

class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    //let transitionDelegate: UIViewControllerTransitioningDelegate = ZoomTransitionController()
    
    var selectedIndexPath: IndexPath!
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var dictOfHists = Dictionary<Date, Array<UIImage>>()
    var dictOfFormats : [Int: Date] = [Int: Date]()
    
    let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    //weak var imageDelegate: UpdateImageDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var blackXButtonView: UIImageView!
    //static let sectionHeaderElementKind = "section-header-element-kind"
    
    //static let sectionFooterElementKind = "section-footer-element-kind"

    //var dataSource: UICollectionViewDiffableDataSource<Int, Int>! = nil
    //var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        //self.transitioningDelegate = transitionDelegate
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
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
            let date = dictOfFormats[indexPath.section]!
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
//    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
//
//    }
    func setUpXButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleBlackXPress(_:)))
        blackXButtonView.addGestureRecognizer(tap)
        blackXButtonView.isUserInteractionEnabled = true
    }
    @objc func handleBlackXPress(_ sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dictOfFormats.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = dictOfFormats[section]!
        let photos = dictOfHists[date]!
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
        let date = dictOfFormats[indexPath.section]
        let photos = dictOfHists[date!]
        cell.imageView.image = photos![indexPath.item]
        //cell.backgroundColor = UIColor(named: "YellowNow")
        cell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        ///MAYBE DON'T USE
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(4)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        var availibleWidth = collectionView.frame.width - paddingSpace
        availibleWidth -= (itemsPerRow - 1) * 2 ///   Three spacers (there are 4 photos per row for iPhone), each 2 points.
        let widthPerItem = availibleWidth / itemsPerRow
        let size = CGSize(width: widthPerItem, height: widthPerItem)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 ///horizontal line spacing, also 2 points, just like the availibleWidth
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        //self.performSegue(withIdentifier: "goToFullScreen", sender: self)
        ///let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FullScreenViewController")
        
        ///beta
        let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoPageContainerViewController")
        
        let drawerContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BottomSheetViewController")
        let pulleyController = PulleyViewController(contentViewController: mainContentVC, drawerViewController: drawerContentVC)
        //mainContentVC.imageToBeDisplayed = UIImage()
        let date = dictOfFormats[indexPath.section]!
        let photos = dictOfHists[date]!
        //let photo = photos[indexPath.item]
        //imageDelegate?.changeImage(image: photo)
        //guard let vc = pulleyController.primaryContentViewController as? FullScreenViewController else { return }
        guard let vc = pulleyController.primaryContentViewController as? PhotoPageContainerViewController
            else { return }
        //nav?.delegate = vc.transitionController
        //vc.transitioningDelegate = transitionDelegate
        //vc.transitioningDelegate = self
        //vc.modalPresentationStyle = .fullScreen
        pulleyController.transitioningDelegate = vc.transitionController ///YES! It worked!
        
        
        vc.transitionController.fromDelegate = self
        vc.transitionController.toDelegate = vc
        vc.delegate = self
        print("1")
        self.selectedIndexPath = indexPath
        print("2")
        vc.currentIndex = indexPath.item
        print("3")
        vc.photos = photos
        print("photos...")
        //vc.modalPresentationStyle = .fullScreen
        //vc.imageView.image = photo
        
        self.present(pulleyController, animated: true)
        
    }
}

extension NewHistoryViewController {
    func getData() {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            for item in items {
                let theFileName = (item as NSString).lastPathComponent
                let splits = theFileName.split(separator: "=")
                
                let categoryName = String(splits[0])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyy"
                let dateFromString = dateFormatter.date(from: String(splits[0]))!
                
                if theFileName.contains(categoryName) {
                    if let image = loadImageFromDocumentDirectory(urlOfFile: folderURL, nameOfImage: theFileName) {
                        dictOfHists[dateFromString, default: [UIImage]()].append(image)
                    }
                }
            }
        } catch {
            print("error getting photos... \(error)")
        }
       
        var tempCategories = [Date]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        for dict in dictOfHists {
            let dictDate = dict.key
            tempCategories.append(dictDate)
        }
        tempCategories.sort(by: { $0.compare($1) == .orderedDescending})
        //print(tempCategories)
        for (index, theDate) in tempCategories.enumerated() {
            dictOfFormats[index] = theDate
        }
        print("how many categories:\(dictOfFormats.count)")
    }
    
    func loadImageFromDocumentDirectory(urlOfFile: URL,nameOfImage : String) -> UIImage? {
        let imageURL = urlOfFile.appendingPathComponent("\(nameOfImage)")
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
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
 
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
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
