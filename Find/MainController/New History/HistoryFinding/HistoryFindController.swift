//
//  HistoryFindController.swift
//  Find
//
//  Created by Zheng on 3/8/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SDWebImage

protocol ReturnCache: class {
    func returnHistCache(cachedImages: HistoryModel)
}
class HistoryFindController: UIViewController, UISearchBarDelegate {
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var imageSize = CGSize(width: 0, height: 0)
    
    @IBOutlet weak var noResultsLabel: UILabel!
    
    @IBOutlet var welcomeView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var welcomeCacheButton: UIButton!
    @IBAction func welcomeCacheButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var welcomeImageButton: UIButton!
    @IBAction func welcomeImageButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helpButton: UIButton!
    @IBAction func helpButtonPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var histCenterC: NSLayoutConstraint!
    
    let deviceSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    var allCached = false
    var highlightColor = "00aeef"
    var matchToColors = [String: [CGColor]]()
    
    var currentMatchStrings = [String]()
//    var currentMatchArray = [String]()
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var stringToList = [String: EditableFindList]()
    
    var photos = [EditableHistoryModel]()
    var resultPhotos = [FindModel]()
    var resultHeights = [CGFloat]()
    
    var selectedIndexPath: IndexPath!
    
    weak var returnCache: ReturnCache?
//    func changeSearchPhotos(photos: [URL]) {
//        photos = photos
//    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 82, right: 0)
    }
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if viewControllerToPresent.title == "PhotoPageContainerViewController" {
            viewControllerToPresent.modalPresentationStyle = .fullScreen
        }
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var attributes = EKAttributes.bottomFloat
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .translation
        attributes.exitAnimation = .translation
        attributes.displayDuration = .infinity
        attributes.positionConstraints.size.height = .constant(value: 60)
        attributes.statusBar = .light
        attributes.entryInteraction = .absorbTouches
//        attributes.scroll = .disabled
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
        attributes.roundCorners = .all(radius: 5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.35, radius: 6, offset: .zero))
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        let customView = FindBar()
        
        customView.returnTerms = self
        SwiftEntryKit.display(entry: customView, using: attributes)
        
//        helpButton.layer.cornerRadius = 6
//        doneButton.layer.cornerRadius = 6
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
//        tableView.sele
        
        let superViewWidth = view.frame.size.width
        welcomeView.frame = CGRect(x: 0, y: 150, width: superViewWidth, height: 275)
        view.addSubview(welcomeView)
        
//        let origText = "All selected photos have already been cached! Search results will appear immediately."
        
        var cachedCount = 0
        for photo in photos {
            print("PHOTO: \(photo)")
            if photo.isDeepSearched == true {
                cachedCount += 1
                print("photo.contnet: \(photo.contents)")
            }
        }
        if cachedCount == photos.count {
            allCached = true
            welcomeImageButton.setImage(UIImage(named: "AllCached"), for: .normal) 
            welcomeCacheButton.setTitle("Learn more", for: .normal)
            welcomeLabel.text = "All selected photos have already been cached! Search results will appear immediately."
        } else {
            allCached = false
            welcomeImageButton.setImage(UIImage(named: "NotAllCached"), for: .normal)
            welcomeLabel.text = "Not all photos have been cached, so search results will not appear immediately. Press Cache to cache the remaining photos."
            welcomeCacheButton.setTitle("Cache", for: .normal)
        }
        welcomeCacheButton.layer.cornerRadius = 6
        
//        tableView.isHidden = true
        tableView.alpha = 0
        tableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        noResultsLabel.alpha = 0
        self.noResultsLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        activityIndicator.hidesWhenStopped = true

        if photos.count > 0 {
           let samplePath = photos[0]
//                print("asdsample")
            let urlString = "\(folderURL)\(samplePath.filePath)"
            if let newURL = URL(string: urlString) {
                if let newImage = newURL.loadImageFromDocumentDirectory() {
                    imageSize = newImage.size
                }
            }
            
        }
        
    }
}
extension HistoryFindController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nummmm")
        return resultPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        cell.baseView.layer.cornerRadius = 6
        cell.baseView.clipsToBounds = true
//        cell.textView.isScrollEnabled = false
//        
//        
//        let fixedWidth = cell.textView.frame.size.width
//        let newSize = cell.textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
////        let finalWidth = max(newSize.width, fixedWidth)
//        let finalHeight = newSize.height
//        
//        cell.textFieldHeightC.constant = finalHeight
//        cell.titleLabel.text = "sdfsdfsdf"
        
        let model = resultPhotos[indexPath.row]
        
        var urlPath = model.photo.filePath
        urlPath = "\(folderURL)\(urlPath)"
        let finalUrl = URL(string: urlPath)
        
        var numberText = ""
        if model.numberOfMatches == 1 {
            numberText = "\(model.numberOfMatches) match"
        } else {
            numberText = "\(model.numberOfMatches) matches"
        }
        cell.titleLabel.text = "\(model.photo.dateCreated.convertDateToReadableString()) | \(numberText)"
        cell.textView.text = model.descriptionText
//        cell.layoutIfNeeded()
        
        
        print("TEXT: \(model.descriptionText)")
        
        cell.photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.photoImageView.sd_imageTransition = .fade
        cell.photoImageView.sd_setImage(with: finalUrl)
        
        
        
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
                    
        let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
            "PhotoPageContainerViewController") as! PhotoPageContainerViewController
        mainContentVC.title = "PhotoPageContainerViewController"
        self.selectedIndexPath = indexPath
        mainContentVC.transitioningDelegate = mainContentVC.transitionController
        mainContentVC.transitionController.fromDelegate = self
        mainContentVC.transitionController.toDelegate = mainContentVC
        mainContentVC.delegate = self
        mainContentVC.currentIndex = indexPath.item
//        mainContentVC.currentSection = indexPath.section
        mainContentVC.photoSize = imageSize
        
//        var photoPaths = [URL]()
//        if let hisModel = indexToData[indexPath.section] {
//    //                print("YES PATH Select indexpath select transition push")
//    //                let historyModel = hisModel[indexPath.item]
//
//            for historyModel in hisModel {
//                var urlPath = historyModel.filePath
//                urlPath = "\(folderURL)\(urlPath)"
//                if let finalUrl = URL(string: urlPath) {
//                    photoPaths.append(finalUrl)
//    //                        fileUrlsSelected.append(finalUrl)
//                }
//            }
//
//        }
        mainContentVC.folderURL = folderURL
                
        var modelArray = [EditableHistoryModel]()
        for photo in photos {
                
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
//                    for cont in singleItem.contents {
//                        newHistModel.contents.append(cont)
//                    }
            
            modelArray.append(newHistModel)
        }
        
        mainContentVC.cameFromFind = true
        mainContentVC.findModels = resultPhotos
//        mainContentVC.photoModels = modelArray
//        mainContentVC.photoPaths = photoPaths
        SwiftEntryKit.dismiss()
        self.present(mainContentVC, animated: true)
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return resultPhotos[indexPath.row].descriptionHeight
    }
    
}

extension HistoryFindController: ReturnSortedTerms {
    
    func startedEditing(start: Bool) {
//        UIView.animate(withDuration: 0.1, animations: {
//            self.welcomeView.alpha = 0
//        }) { _ in
//            self.welcomeView.removeFromSuperview()
//        }
        if resultPhotos.count == 0 {
            
            if start == true {
                if stringToList.count == 0 {
                    tableView.isHidden = false
                    tableView.alpha = 0

                    noResultsLabel.text = "Start by typing or selecting a list..."
                    UIView.animate(withDuration: 0.1, animations: {
                        self.welcomeView.alpha = 0
//                        self.tableView.alpha = 1
                        self.noResultsLabel.alpha = 1
                        self.noResultsLabel.transform = CGAffineTransform.identity
                    }) { _ in
                        self.welcomeView.removeFromSuperview()
                    }
                    print("Start editing")
                }
                
                

            } else {
//
                print("ENDDD")
                print("COUNT:: \(stringToList.count)")
                print("list: \(stringToList)")
                if stringToList.count == 0 {
                    let superViewWidth = view.frame.size.width
                    welcomeView.frame = CGRect(x: 0, y: 150, width: superViewWidth, height: 275)
                    view.addSubview(welcomeView)
    //                let superViewWidth = view.frame.size.width
    //                welcomeView.frame = CGRect(x: 0, y: 150, width: superViewWidth, height: 275)
    //                view.addSubview(welcomeView)
    //
                    UIView.animate(withDuration: 0.1, animations: {
                        self.welcomeView.alpha = 1
                        self.tableView.alpha = 0
                        self.noResultsLabel.alpha = 0
                        self.noResultsLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    }) { _ in
                        self.tableView.isHidden = true
                    }
                }
            }
        }
    }
    
    func returnTerms(stringToListR: [String : EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String : [CGColor]]) {
//        print("RECIEVED TERMS")
        
        
        stringToList = stringToListR
        currentSearchFindList = currentSearchFindListR
        currentListsSharedFindList = currentListsSharedFindListR
        currentSearchAndListSharedFindList = currentSearchAndListSharedFindListR
        currentMatchStrings = currentMatchStringsR
        matchToColors = matchToColorsR
        
        print("terms")
        
        
        if stringToList.count == 0 {
            
            noResultsLabel.text = "Start by typing or selecting a list..."
            UIView.animate(withDuration: 0.1, animations: {
                self.noResultsLabel.alpha = 1
                self.noResultsLabel.transform = CGAffineTransform.identity
                self.tableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.tableView.alpha = 0
            }) { _ in
                self.tableView.isHidden = true
            }
            resultPhotos.removeAll()
            tableView.reloadData()
            
        } else {
            fastFind()
        }
        
        
        
    }
    
    func pause(pause: Bool) {
        
        print("recieved pause. \(pause)")
        
    }
    
    
}

extension HistoryFindController {
    func fastFind() {
        
        activityIndicator.startAnimating()
        histCenterC.constant = 13
        UIView.animate(withDuration: 0.12, animations: {
            self.view.layoutIfNeeded()
        })
        DispatchQueue.global(qos: .background).async {
            print("1")
            var findModels = [FindModel]()
            print("2")
    //        var heights = [CGFloat]()
            
    //        print(
            for photo in self.photos {
                print("3")
                print("searching in photo")
                var num = 0
                
                let newMod = FindModel()
                print("4")
                newMod.photo = photo
                
                var descriptionOfPhoto = ""
    //            var descStrings = [String]()
    //            var compMatches = [ArrayOfMatchesInComp]()
                var compMatches = [String: [ClosedRange<Int>]]() ///COMPONENT to ranges
                
                
                ///Cycle through each block of text. Each cont may be a line long.
                for cont in photo.contents {
                    print("5")
    //                let compRange = ArrayOfMatchesInComp()
                    
                    var matchRanges = [ClosedRange<Int>]()
    //                print("photoCont: \(photo.contents)")
    //                print("in content")
                    var hasMatch = false
                    
                    let lowercaseContText = cont.text.lowercased()
                    let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                    for match in self.currentMatchStrings {
                        print("6")
                        if lowercaseContText.contains(match) {
                            hasMatch = true
                            print("contains match: \(match), text: \(lowercaseContText)")
                            let finalW = individualCharacterWidth * CGFloat(match.count)
                            let indicies = lowercaseContText.indicesOf(string: match)
                            
                            for index in indicies {
                                num += 1
                                let addedWidth = individualCharacterWidth * CGFloat(index)
                                let finalX = CGFloat(cont.x) + addedWidth
                                let newComponent = Component()
                                
                                newComponent.x = finalX - 6
                                newComponent.y = CGFloat(cont.y) - (CGFloat(cont.height) + 3)
                                newComponent.width = finalW + 12
                                newComponent.height = CGFloat(cont.height) + 6
                                newComponent.text = match
    //                            newComponent.changed = false
                                if let parentList = self.stringToList[match] {
                                    switch parentList.descriptionOfList {
                                    case "Search Array List +0-109028304798614":
                                            print("Search Array")
                                            newComponent.parentList = self.currentSearchFindList
                                            newComponent.colors = [self.highlightColor]
                                    case "Shared Lists +0-109028304798614":
                                            print("Shared Lists")
                                            newComponent.parentList = self.currentListsSharedFindList
                                        newComponent.isSpecialType = "Shared List"
                                    case "Shared Text Lists +0-109028304798614":
                                            print("Shared Text Lists")
                                            newComponent.parentList = self.currentSearchAndListSharedFindList
                                        newComponent.isSpecialType = "Shared Text List"
                                    default:
                                            print("normal")
                                        newComponent.parentList = parentList
                                        newComponent.colors = [parentList.iconColorName]
                                    }
                                } else {
                                    print("ERROROROR! NO parent list!")
                                }
                                
                                newMod.components.append(newComponent)
                                matchRanges.append(index...index + match.count)
    //                            textToRanges[cont.text, default: [ClosedRange<Int>]()].append(index...index + match.count)
                                
                            }
                            
                            
                            
                        }
                    }
                        
                    if hasMatch == true {
    //                    descStrings.append(cont.text)
    //                    compRange.stringToRanges = index...index + match.count
    //                    compRange.stringToRanges = textToRanges
                        print("COMOPP: \(matchRanges)")
    //                    compMatches.append(matchRanges)
                        compMatches[cont.text] = matchRanges
                        
                    }
                
                    
                }
                if num >= 1 {
                    
                    for (index, comp) in compMatches.enumerated() {
                        if index <= 2 {
    //                        let thisCompString = comp.stringToRanges.first?.key
                            let thisCompString = comp.key
                            
                            if descriptionOfPhoto == "" {
                                descriptionOfPhoto.append("...\(thisCompString)...")
                            } else {
                                descriptionOfPhoto.append("\n...\(thisCompString)...")
                            }
                            
    //                        for matchCont in comp {
    //
    //                        }
    //                        de
    //                        let componentString = comp.
                            
                        }
                    }
                    
                    findModels.append(newMod)
                }
                
                newMod.numberOfMatches = num
                newMod.descriptionText = descriptionOfPhoto
                let totalWidth = self.deviceSize.width
                let finalWidth = totalWidth - 146
                let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
                let finalHeight = height + 70
                newMod.descriptionHeight = finalHeight
                
            }
            print("FIND COUNT: \(findModels.count)")
            self.resultPhotos = findModels
            
            DispatchQueue.main.async {
            
                self.activityIndicator.stopAnimating()
                self.histCenterC.constant = 0
                UIView.animate(withDuration: 0.12, animations: {
                    self.view.layoutIfNeeded()
                })
                
                
                if findModels.count >= 1 {
        //            tableView.isHidden = false
        //            tableView.alpha = 0
        //
        //            UIView.animate(withDuration: 0.08, animations: {
        //                self.welcomeView.alpha = 0
        //                self.tableView.alpha = 1
        //            }) { _ in
        //                self.welcomeView.removeFromSuperview()
        //            }
        //            print("MORE")
                    self.tableView.isHidden = false
                    UIView.animate(withDuration: 0.1, animations: {
                        self.noResultsLabel.alpha = 0
                        self.tableView.alpha = 1
                        self.noResultsLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                        self.tableView.transform = CGAffineTransform.identity
                    })
                } else {
                    print("NO results")
//                    if
                    self.noResultsLabel.text = "No results found in cache. Press Search on the keyboard to continue."
                    UIView.animate(withDuration: 0.1, animations: {
                        self.noResultsLabel.alpha = 1
                        self.tableView.alpha = 0
                        self.noResultsLabel.transform = CGAffineTransform.identity
                        self.tableView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    }) { _ in
                        self.tableView.isHidden = true
                    }
                }
                
                
                
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    
}



extension HistoryFindController: PhotoPageContainerViewControllerDelegate {
 
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
//        print("sdfhjk")
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
//        self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
        self.tableView.scrollToRow(at: self.selectedIndexPath, at: .middle, animated: false)
    }
}

extension HistoryFindController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
//        let cell = self.tableView.cellForItem(at: self.selectedIndexPath) as! HistoryFindCell
        let cell = self.tableView.cellForRow(at: self.selectedIndexPath) as! HistoryFindCell
        let cellFrame = self.tableView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.tableView.contentInset.top {
//            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
            self.tableView.scrollToRow(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.tableView.contentInset.bottom {
//            self.collectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
            self.tableView.scrollToRow(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        self.view.layoutIfNeeded()
        self.tableView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        var cellFrame = self.tableView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.tableView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.tableView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.tableView.contentInset.top - cellFrame.minY))
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
        if let visibleCells = self.tableView.indexPathsForVisibleRows {
        
            //If the current indexPath is not visible in the collectionView,
            //scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(self.selectedIndexPath) {
               
                //Scroll the collectionView to the current selectedIndexPath which is offscreen
                self.tableView.scrollToRow(at: self.selectedIndexPath, at: .middle, animated: false)
                
                //Reload the items at the newly visible indexPaths
                self.tableView.reloadRows(at: visibleCells, with: .none)
                self.tableView.layoutIfNeeded()
                
                //Guard against nil values
    //            guard let guardedCell = (self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell) else {
    //                //Return a default UIImageView
    //                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
    //            }
                guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            }
            else {
                
                //Guard against nil return values
    //            guard let guardedCell = self.collectionView.cellForItem(at: self.selectedIndexPath) as? HPhotoCell else {
    //                //Return a default UIImageView
    //                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
    //            }
                guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                    return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
                }
                //The PhotoCollectionViewCell was found in the collectionView, return the image
                return guardedCell.photoImageView
            }
        } else {
            self.tableView.scrollToRow(at: self.selectedIndexPath, at: .middle, animated: false)
                        //Reload the items at the newly visible indexPaths
            //            self.tableView.reloadItems(at: visibleCells)
            if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            self.tableView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            
            return guardedCell.photoImageView
        }
        
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the
    //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
    func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
        
        //Get the currently visible cells from the collectionView
        if let visibleCells = self.tableView.indexPathsForVisibleRows {
            
            
            //If the current indexPath is not visible in the collectionView,
            //scroll the collectionView to the cell to prevent it from returning a nil value
            if !visibleCells.contains(self.selectedIndexPath) {
                
                //Scroll the collectionView to the cell that is currently offscreen
    //            self.tableView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
                self.tableView.scrollToRow(at: self.selectedIndexPath, at: .middle, animated: false)
                //Reload the items at the newly visible indexPaths
    //            self.tableView.reloadItems(at: visibleCells)
                if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                    self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
                }
                
                self.tableView.layoutIfNeeded()
                
                //Prevent the collectionView from returning a nil value
                guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
                }
                
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
            //Otherwise the cell should be visible
            else {
                //Prevent the collectionView from returning a nil value
                guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                    return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
                }
                //The cell was found successfully
//                return guardedCell.frame
                var cellFrame = guardedCell.frame
                cellFrame.origin.x += 16
                cellFrame.origin.y += 6
                cellFrame.size.width = 100
                cellFrame.size.height -= 12
                
                return cellFrame
            }
        } else {
            self.tableView.scrollToRow(at: self.selectedIndexPath, at: .middle, animated: false)
                        //Reload the items at the newly visible indexPaths
            //            self.tableView.reloadItems(at: visibleCells)
            if let newlyVisibleCells = self.tableView?.indexPathsForVisibleRows {
                self.tableView.reloadRows(at: newlyVisibleCells, with: .none)
            }
            self.tableView.layoutIfNeeded()
            
            //Prevent the collectionView from returning a nil value
            guard let guardedCell = (self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell) else {
                return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
            }
            
//            return guardedCell.frame
            var cellFrame = guardedCell.frame
            cellFrame.origin.x += 16
            cellFrame.origin.y += 6
            cellFrame.size.width = 100
            cellFrame.size.height -= 12
            
            return cellFrame
        }
    }
}
