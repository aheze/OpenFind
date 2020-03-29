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
import Vision

protocol ReturnCache: class {
    func returnHistCache(cachedImages: HistoryModel)
}

protocol EditedFindBar: class {
    func updateTerms(stringToListR: [String: EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String: [CGColor]])
}
protocol ChangeFindBar: class {
    func change(type: String)
    func giveLists(lists: [EditableFindList], searchText: String)
}

class HistoryFindController: UIViewController, UISearchBarDelegate {
    
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var imageSize = CGSize(width: 0, height: 0)
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningHeightC: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    var showedWarningAlready = false
    
    
    @IBOutlet weak var progressHeightC: NSLayoutConstraint!
    
    var statusOk = true
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "ocrFindQueue")
    let dispatchSemaphore = DispatchSemaphore(value: 0)
    var ocrPassCount = 0
    var ocrSearching = false
    
    
//    var sekSwitchedToPreview = false
    
    var savedSelectedLists = [EditableFindList]()
    var savedTextfieldText = ""
    
    
    weak var editedFindbar: EditedFindBar?
    weak var changeFindbar: ChangeFindBar?
    
    var shouldAllowPressRow = true
    
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
//        print("help")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let helpViewController = storyboard.instantiateViewController(withIdentifier: "DefaultHelpController") as! DefaultHelpController
        helpViewController.title = "Find Help"
        let navigationController = UINavigationController(rootViewController: helpViewController)
        navigationController.view.backgroundColor = UIColor.clear
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.6823529412, blue: 0.937254902, alpha: 1)
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.view.layer.cornerRadius = 10
        UINavigationBar.appearance().barTintColor = .black
        helpViewController.edgesForExtendedLayout = []
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(100))
        attributes.lifecycleEvents.willDisappear = {
            
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
//            customView.selectedLists = self.savedSelectedLists
            customView.returnTerms = self
            
            self.changeFindbar = customView
            SwiftEntryKit.display(entry: customView, using: attributes)
            
            self.changeFindbar?.giveLists(lists: self.savedSelectedLists, searchText: self.savedTextfieldText)
            
            
        }
        
        changeFindbar?.change(type: "GetLists")
        
        SwiftEntryKit.display(entry: navigationController, using: attributes)
    }
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var histCenterC: NSLayoutConstraint!
    
    let deviceSize = UIScreen.main.bounds.size
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        statusOk = false
        if let pvc = self.presentationController {
            pvc.delegate?.presentationControllerDidDismiss?(pvc)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var findFromHistoryLabel: UILabel!
    
    var numberOfFindRequests = 0

    var allCached = false
//    var highlightColor = "00aeef"
    var matchToColors = [String: [CGColor]]()
    var highlightColor = "00aeef"
    
    var currentMatchStrings = [String]()
//    var currentMatchArray = [String]()
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var stringToList = [String: EditableFindList]()
    
    var photos = [EditableHistoryModel]()
    var resultPhotos = [FindModel]()
    var resultHeights = [CGFloat]()
    
    var ocrResultPhotos = [FindModel]()
    
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
        
        self.changeFindbar = customView
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
//            print("PHOTO: \(photo)")
            
            
            if photo.isDeepSearched == true {
                cachedCount += 1
//                print("photo.contnet: \(photo.contents)")
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
        warningView.alpha = 0
        warningView.layer.cornerRadius = 6
        warningView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        warningLabel.alpha = 0
        progressView.alpha = 0
        
        
    }
}
extension HistoryFindController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("nummmm")
        return resultPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        cell.baseView.layer.cornerRadius = 6
        cell.baseView.clipsToBounds = true
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
        cell.photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.photoImageView.sd_imageTransition = .fade
        cell.photoImageView.sd_setImage(with: finalUrl)
        
        
     // you should ensure layout
        cell.textView.layoutManager.ensureLayout(for: cell.textView.textContainer)
        
        var rects = [CGRect]()
//        print("MATCH TO COLORS: \(matchToColors)")
        print("------Ranges: \(model.descriptionMatchRanges)")
        cell.drawingView.subviews.forEach({ $0.removeFromSuperview() })
        for range in model.descriptionMatchRanges {
            print("range: \(range.descriptionRange)")
            
//            let start = cell.textView.positionFromPosition(cell.textView.beginningOfDocument, offset: range.location)
            guard let first = range.descriptionRange.first else { print("NO START!"); continue }
            guard let last = range.descriptionRange.last else { print("NO end!"); continue }
            guard let start = cell.textView.position(from: cell.textView.beginningOfDocument, offset: first) else { print("ERROR!! Start"); continue }
            // text position of the end of the range
//            let end = cell.textView.positionFromPosition(start, offset: range.length)!
            guard let end = cell.textView.position(from: cell.textView.beginningOfDocument, offset: last) else { print("ERROR!! End"); continue }

            // text range of the range
//            let tRange = cell.textView.textRangeFromPosition(start, toPosition: end)

            if let textRange = cell.textView.textRange(from: start, to: end) {
            // here it is!
                let rect = cell.textView.firstRect(for: textRange)
                rects.append(rect)
                
                let newHighlight = addHighlight(text: range.text, rect: rect)
                cell.drawingView.addSubview(newHighlight)
                
                
            }
        }
        
        
        
        print("TEXT: \(model.descriptionText), RECTS: \(rects)----")
        
        
        
        
        
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.selectedIndexPath = indexPath
        
        if shouldAllowPressRow == true && ocrSearching == false {
            let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:
                "PhotoPageContainerViewController") as! PhotoPageContainerViewController
            mainContentVC.title = "PhotoPageContainerViewController"
            
            mainContentVC.transitioningDelegate = mainContentVC.transitionController
            mainContentVC.transitionController.fromDelegate = self
            mainContentVC.transitionController.toDelegate = mainContentVC
            mainContentVC.delegate = self
            
            mainContentVC.currentIndex = indexPath.item
    //        mainContentVC.currentSection = indexPath.section
            mainContentVC.photoSize = imageSize
            
            mainContentVC.folderURL = folderURL
            self.editedFindbar = mainContentVC
            
            mainContentVC.matchToColors = matchToColors
            mainContentVC.cameFromFind = true
            mainContentVC.findModels = resultPhotos
    //        mainContentVC.photoModels = modelArray
    //        mainContentVC.photoPaths = photoPaths
    //        SwiftEntryKit.dismiss()
            changeFindbar?.change(type: "GetLists")
            SwiftEntryKit.dismiss()
            self.present(mainContentVC, animated: true)
//            SwiftEntryKit.dismiss()
            
        } else {
            showWarning(show: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return resultPhotos[indexPath.row].descriptionHeight
    }
    func showWarning(show: Bool) {
        if show == true {
            if showedWarningAlready == false {
                showedWarningAlready = true
                warningHeightC.constant = 32
                progressHeightC.constant = 10
                UIView.animate(withDuration: 0.5, animations: {
    //                self.prog
                    self.warningView.alpha = 1
                    self.warningLabel.alpha = 1
//                    self.progressView.transform = self.progressView.transform.scaledBy(x: 1, y: 20)
                    self.view.layoutIfNeeded()
                })
            }
        } else {
            showedWarningAlready = false
            warningHeightC.constant = 6
            progressHeightC.constant = 2
            UIView.animate(withDuration: 0.5, animations: {
                self.progressView.alpha = 0
                self.warningView.alpha = 0
                self.warningLabel.alpha = 0
//                self.progressView.transform = CGAffineTransform.identity
                self.view.layoutIfNeeded()
            })
        }
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
    func pressedReturn() {
//        shouldAllowPressRow = false
        
        ocrFind()
        changeFindbar?.change(type: "Disable")
    }
    
    func triedToEdit() {
        showWarning(show: true)
    }
    
    func hereAreCurrentLists(currentSelected: [EditableFindList], currentText: String) {
        print("GAVE!! \(currentSelected)")
        savedSelectedLists = currentSelected
        savedTextfieldText = currentText
    }
}

extension HistoryFindController {
    func fastFind() {
        
        if numberOfFindRequests == 0 {
//            self.tableView.isUserInteractionEnabled = false
            self.shouldAllowPressRow = false
            UIView.animate(withDuration: 0.2, animations: {
                self.tableView.alpha = 0.5
            })
        }
        
        numberOfFindRequests += 1
        
        
    
        
        activityIndicator.startAnimating()
        histCenterC.constant = 13
        UIView.animate(withDuration: 0.12, animations: {
            self.view.layoutIfNeeded()
        })
        DispatchQueue.global(qos: .background).async {
//            print("1")
            var findModels = [FindModel]()
    //        var heights = [CGFloat]()
            
    //        print(
            for photo in self.photos {
                print("searching in photo")
                var num = 0
                
                let newMod = FindModel()
                newMod.photo = photo
                
                var descriptionOfPhoto = ""
    //            var descStrings = [String]()
    //            var compMatches = [ArrayOfMatchesInComp]()
                var compMatches = [String: [ArrayOfMatchesInComp]]() ///COMPONENT to ranges
                
                
                ///Cycle through each block of text. Each cont may be a line long.
                for cont in photo.contents {
//                    print("CONT: \(cont.x)")
    //                let compRange = ArrayOfMatchesInComp()
                    
//                    var matchRanges = [ClosedRange<Int>]()
                    
                    var matchRanges = [ArrayOfMatchesInComp]()
    //                print("photoCont: \(photo.contents)")
    //                print("in content")
                    var hasMatch = false
                    
                    let lowercaseContText = cont.text.lowercased()
                    let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                    for match in self.currentMatchStrings {
                        if lowercaseContText.contains(match) {
                            hasMatch = true
                            let finalW = individualCharacterWidth * CGFloat(match.count)
                            let indicies = lowercaseContText.indicesOf(string: match)
                            
                            for index in indicies {
                                num += 1
                                let addedWidth = individualCharacterWidth * CGFloat(index)
                                let finalX = CGFloat(cont.x) + addedWidth
                                let newComponent = Component()
                                
                                newComponent.x = finalX
                                newComponent.y = CGFloat(cont.y) - (CGFloat(cont.height))
                                newComponent.width = finalW
//                                print("WIDT: \(finalW + 12)")
                                newComponent.height = CGFloat(cont.height)
                                newComponent.text = match
    //                            newComponent.changed = false
//                                if let parentList = self.stringToList[match] {
//                                    switch parentList.descriptionOfList {
//                                    case "Search Array List +0-109028304798614":
////                                            print("Search Array")
//                                            newComponent.parentList = self.currentSearchFindList
//                                            newComponent.colors = [self.highlightColor]
//                                    case "Shared Lists +0-109028304798614":
////                                            print("Shared Lists")
//                                            newComponent.parentList = self.currentListsSharedFindList
//                                        newComponent.isSpecialType = "Shared List"
//                                    case "Shared Text Lists +0-109028304798614":
////                                            print("Shared Text Lists")
//                                            newComponent.parentList = self.currentSearchAndListSharedFindList
//                                        newComponent.isSpecialType = "Shared Text List"
//                                    default:
////                                            print("normal")
//                                        newComponent.parentList = parentList
//                                        newComponent.colors = [parentList.iconColorName]
//                                    }
//                                } else {
//                                    print("ERROROROR! NO parent list!")
//                                }
                                
                                newMod.components.append(newComponent)
                                
                                let newRangeObject = ArrayOfMatchesInComp()
                                newRangeObject.descriptionRange = index...index + match.count
                                newRangeObject.text = match
                                matchRanges.append(newRangeObject)
    //                            textToRanges[cont.text, default: [ClosedRange<Int>]()].append(index...index + match.count)
                                
                            }
                            
                            
                            
                        }
                    }
                        
                    if hasMatch == true {
    //                    descStrings.append(cont.text)
    //                    compRange.stringToRanges = index...index + match.count
    //                    compRange.stringToRanges = textToRanges
//                        print("COMOPP: \(matchRanges)")
    //                    compMatches.append(matchRanges)
                        compMatches[cont.text] = matchRanges
                        
                    }
                
                    
                }
                
                var finalRangesObjects = [ArrayOfMatchesInComp]()
                if num >= 1 {
                    var existingCount = 0
                    for (index, comp) in compMatches.enumerated() {
                        if index <= 2 {
                            
                            
                            
    //                        let thisCompString = comp.stringToRanges.first?.key
                            
                            
                            let thisCompString = comp.key
                            
                            if descriptionOfPhoto == "" {
                                existingCount += 3
                                descriptionOfPhoto.append("...\(thisCompString)...")
                            } else {
                                existingCount += 4
                                descriptionOfPhoto.append("\n...\(thisCompString)...")
                            }
                            
                            for compRange in comp.value {
                                let newStart = existingCount + (compRange.descriptionRange.first ?? 0)
                                let newEnd = existingCount + (compRange.descriptionRange.last ?? 1)
                                let newRange = newStart...newEnd
                                
                                let matchObject = ArrayOfMatchesInComp()
                                matchObject.descriptionRange = newRange
                                matchObject.text = compRange.text
                                
                                
                                finalRangesObjects.append(matchObject)
//                                finalRanges.append(newRange)
//                                let newRangeObject = ArrayOfMatchesInComp()
//                                newRangeObject.descriptionRange = newRange
//                                newRangeObject.text = comp.
                            }
                            let addedLength = 3 + thisCompString.count
                            existingCount += addedLength
                            
                            
                            
                            
//                            let newRance =
                            
    //                        for matchCont in comp {
    //
    //                        }
    //                        de
    //                        let componentString = comp.
                            
                        }
                    }
                    
                    findModels.append(newMod)
                }
                
//                print("RANGES: \(finalRanges)")
                
                
//                newMod.descriptionMatchRanges = finalRanges
                
//                for range in finalRanges {
//                    let newRangeObject = ArrayOfMatchesInComp()
//                    newRangeObject.descriptionRange = range
//                    newRangeObject.text
//                }
                newMod.descriptionMatchRanges = finalRangesObjects
                newMod.numberOfMatches = num
                newMod.descriptionText = descriptionOfPhoto
                let totalWidth = self.deviceSize.width
                let finalWidth = totalWidth - 146
                let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
                let finalHeight = height + 70
                newMod.descriptionHeight = finalHeight
                
            }
//            print("FIND COUNT: \(findModels.count)")
            self.resultPhotos = findModels
            
            DispatchQueue.main.async {
                
                self.numberOfFindRequests -= 1
            
                if self.numberOfFindRequests == 0 {
                    self.activityIndicator.stopAnimating()
                    self.histCenterC.constant = 0
                    UIView.animate(withDuration: 0.12, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
//                    self.tableView.isUserInteractionEnabled = true
                    self.shouldAllowPressRow = true
                    
                    if findModels.count >= 1 {
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
        print("TRANSS END????")
        if zoomAnimator.isPresenting == false && zoomAnimator.finishedDismissing == true {
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
    //            customView.selectedLists = self.savedSelectedLists
            customView.returnTerms = self
            
            self.changeFindbar = customView
            SwiftEntryKit.display(entry: customView, using: attributes)
            
            self.changeFindbar?.giveLists(lists: self.savedSelectedLists, searchText: self.savedTextfieldText)
            
            print("TRANSITION ENDED")
        }
//        let cell = self.tableView.cellForItem(at: self.selectedIndexPath) as! HistoryFindCell
        guard let cell = self.tableView.cellForRow(at: self.selectedIndexPath) as? HistoryFindCell else { print("NO CELL!!!"); return }
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


extension HistoryFindController {
    func addHighlight(text: String, rect: CGRect) -> UIView {
        var newOrigRect = rect
        newOrigRect.origin.x -= 1
        newOrigRect.origin.y -= 1
        newOrigRect.size.width += 2
        newOrigRect.size.height += 2
        
        let newView = UIView(frame: CGRect(x: newOrigRect.origin.x, y: newOrigRect.origin.y, width: newOrigRect.size.width, height: newOrigRect.size.height))
//        print("text to color... text: \(text)")
        guard let colors = matchToColors[text] else { print("NO COLORS!"); return newView}
        
//        let viewToReturn = UIView()
//        DispatchQueue.main.async {
            
        let layer = CAShapeLayer()
        layer.frame = CGRect(x: 0, y: 0, width: newOrigRect.size.width, height: newOrigRect.size.height)
        layer.cornerRadius = rect.size.height / 3.5
            
        let newLayer = CAShapeLayer()
        newLayer.bounds = layer.frame
        newLayer.path = UIBezierPath(roundedRect: layer.frame, cornerRadius: newOrigRect.size.height / 3.5).cgPath
        newLayer.lineWidth = 2
//        newLayer.lineCap = .round
            
            
//            var newFillColor = UIColor()
        if colors.count > 1 {
//                print("shared list")
            var newRect = layer.frame
            newRect.origin.x += 1
            newRect.origin.y += 1
            layer.frame.origin.x -= 1
            layer.frame.origin.y -= 1
            layer.frame.size.width += 2
            layer.frame.size.height += 2
            newLayer.path = UIBezierPath(roundedRect: newRect, cornerRadius: newOrigRect.size.height / 4.5).cgPath
            
            let gradient = CAGradientLayer()
            gradient.frame = layer.bounds
//                if let gradientColors = self.matchToColors[component.text] {
            gradient.colors = colors
            if let firstColor = colors.first {
                layer.backgroundColor = UIColor(cgColor: firstColor).withAlphaComponent(0.3).cgColor
            }
//                }
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            gradient.mask = newLayer
            newLayer.fillColor = UIColor.clear.cgColor
            newLayer.strokeColor = UIColor.black.cgColor
            layer.addSublayer(gradient)
            
        } else {
//            newLayer.fillColor = UIColor(hexString: highlightColor).withAlphaComponent(0.3).cgColor
//            newLayer.strokeColor = UIColor(hexString: highlightColor).cgColor
            layer.addSublayer(newLayer)
            if let firstColor = colors.first {
                newLayer.fillColor = firstColor.copy(alpha: 0.3)
                newLayer.strokeColor = firstColor
                layer.addSublayer(newLayer)
            }
        }
            
            
//            self.mainContentView.addSubview(newView)
            
            newView.layer.addSublayer(layer)
            newView.clipsToBounds = false
            let x = newLayer.bounds.size.width / 2
            let y = newLayer.bounds.size.height / 2
            newLayer.position = CGPoint(x: x, y: y)
            
            return newView
//        }
    }
}

extension HistoryFindController {
    func ocrFind() {
        ocrSearching = true
        
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.histCenterC.constant = 13
            UIView.animate(withDuration: 0.12, animations: {
                self.view.layoutIfNeeded()
                self.progressView.alpha = 1
                self.progressView.setProgress(Float(0), animated: true)
            })
        }
        
        dispatchQueue.async {
            self.ocrPassCount = 0
//            var number = 0
            for photo in self.photos {
                if self.statusOk == true {
                    
    //                number += 1
    //                    print("num: \(number)")
    //                    let indP = IndexPath(item: number - 1, section: 0)
                    
                    self.dispatchGroup.enter()
                    
                    
                    
    //                print("OCR: \(self.ocrPassCount)")
                    guard let photoUrl = URL(string: "\(self.folderURL)\(photo.filePath)") else { print("WRONG URL!!!!"); return }
                    
                    let request = VNRecognizeTextRequest { request, error in
                        self.handleFastDetectedText(request: request, error: error, photo: photo)
                    }
                    
                    var customFindArray = [String]()
                    for findWord in self.stringToList.keys {
                        customFindArray.append(findWord)
                        customFindArray.append(findWord.lowercased())
                        customFindArray.append(findWord.uppercased())
                        customFindArray.append(findWord.capitalizingFirstLetter())
                    }
                    
                    request.customWords = customFindArray
                    
                    
                    request.recognitionLevel = .fast
                    request.recognitionLanguages = ["en_GB"]
                    let imageRequestHandler = VNImageRequestHandler(url: photoUrl, orientation: .up)
                    
    //                request.progressHandler = { (request, value, error) in
    ////                    print("Progress: \(value)")
    //                }
                    do {
                        try imageRequestHandler.perform([request])
                    } catch let error {
        //                self.busyFastFinding = false
                        print("Error: \(error)")
                    }
                    
                    self.dispatchSemaphore.wait()
                } else {
                    break
                }
               
            }
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            self.ocrSearching = false
//            self.
            DispatchQueue.main.async {
                self.showWarning(show: false)
                self.tableView.reloadData()
            }
            
            self.changeFindbar?.change(type: "Enable")
            print("Finished all requests.")
            
            self.finishOCR()
            
            
//            self.finishOCR()
//            fastFind()
//            ocrfini
        }
        
    }
    func handleFastDetectedText(request: VNRequest?, error: Error?, photo: EditableHistoryModel) {
        
        
        self.ocrPassCount += 1
        DispatchQueue.main.async {
//            print("HPOSO COUNT: \(self.photos.count)")
            let individualProgress = CGFloat(self.ocrPassCount) / CGFloat(self.photos.count)
//            print("IND PROGR: \(individualProgress)")
            UIView.animate(withDuration: 0.6, animations: {
                self.progressView.setProgress(Float(individualProgress), animated: true)
            })
        }
        
       
        guard let results = request?.results, results.count > 0 else {
            print("no results")
//                alreadyCachedPhotos.append(newCachedPhoto)
            dispatchSemaphore.signal()
            dispatchGroup.leave()
            
            return
        }

        var contents = [EditableSingleHistoryContent]()
        
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    
                    let origX = observation.boundingBox.origin.x
                    let origY = 1 - observation.boundingBox.minY
                    let origWidth = observation.boundingBox.width
                    let origHeight = observation.boundingBox.height
                    
                    let singleContent = EditableSingleHistoryContent()
                    singleContent.text = text.string
                    singleContent.x = origX
                    singleContent.y = origY
                    singleContent.width = origWidth
                    singleContent.height = origHeight
                    contents.append(singleContent)
                }
            }
        }
        
        let newMod = FindModel()
        
        var compMatches = [String: [ArrayOfMatchesInComp]]()
        var numberOfMatches = 0
        
        var findComponents = [Component]()
        for cont in contents {
            var matchRanges = [ArrayOfMatchesInComp]()
            var hasMatch = false
            
            let lowercaseContText = cont.text.lowercased()
            
            let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
            for match in self.currentMatchStrings {
                if lowercaseContText.contains(match) {
//                    print("MATCH!! \(match), in: \(cont.text)")
                    hasMatch = true
                    let finalW = individualCharacterWidth * CGFloat(match.count)
                    let indicies = lowercaseContText.indicesOf(string: match)
                    
                    for index in indicies {
                        numberOfMatches += 1
                        let addedWidth = individualCharacterWidth * CGFloat(index)
                        let finalX = CGFloat(cont.x) + addedWidth
                        
                        let newComponent = Component()
                        
                        newComponent.x = finalX
                        newComponent.y = CGFloat(cont.y) - (CGFloat(cont.height))
                        newComponent.width = finalW
                        newComponent.height = CGFloat(cont.height)
                        newComponent.text = match
                        
                        findComponents.append(newComponent)
                        
                        let newRangeObject = ArrayOfMatchesInComp()
                        newRangeObject.descriptionRange = index...index + match.count
                        newRangeObject.text = match
                        matchRanges.append(newRangeObject)
                        
                    }
                    
                    
                    
                }
            }
                
            if hasMatch == true {
                compMatches[cont.text] = matchRanges
            }
        }
        var descriptionOfPhoto = ""
        var finalRangesObjects = [ArrayOfMatchesInComp]()
        
        if numberOfMatches >= 1 {
            var existingCount = 0
            for (index, comp) in compMatches.enumerated() {
                if index <= 2 {
                    let thisCompString = comp.key
                    
                    if descriptionOfPhoto == "" {
                        existingCount += 3
                        descriptionOfPhoto.append("...\(thisCompString)...")
                    } else {
                        existingCount += 4
                        descriptionOfPhoto.append("\n...\(thisCompString)...")
                    }
                    for compRange in comp.value {
                        let newStart = existingCount + (compRange.descriptionRange.first ?? 0)
                        let newEnd = existingCount + (compRange.descriptionRange.last ?? 1)
                        let newRange = newStart...newEnd
                        
                        let matchObject = ArrayOfMatchesInComp()
                        matchObject.descriptionRange = newRange
                        matchObject.text = compRange.text
                        
                        finalRangesObjects.append(matchObject)
                    }
                    let addedLength = 3 + thisCompString.count
                    existingCount += addedLength
                }
            }
            
            var foundSamePhoto = false
            for existingModel in self.resultPhotos {
                if photo.dateCreated == existingModel.photo.dateCreated {
                    foundSamePhoto = true
                    var componentsToAdd = [Component]()
                    var newMatchesNumber = 0
                    
                    for newFindMatch in findComponents {
                        var smallestDist = CGFloat(999)
                        for findMatch in existingModel.components {
                            
                            let point1 = CGPoint(x: findMatch.x, y: findMatch.y)
                            let point2 = CGPoint(x: newFindMatch.x, y: newFindMatch.y)
                            let pointDistance = relativeDistance(point1, point2)
                            
//                                print("OLD: \(point1), new: \(point2)")
                            if pointDistance < smallestDist {
                                smallestDist = pointDistance
                            }
                            
                        }
//                            print("SMALL DIST: \(smallestDist)")
                        if smallestDist >= 0.008 { ///Bigger, so add it
                            componentsToAdd.append(newFindMatch)
                            newMatchesNumber += 1
                        }
                        
                    }
                    
                    existingModel.components += componentsToAdd
                    existingModel.numberOfMatches += newMatchesNumber
                    print("ADD MATCHES: \(newMatchesNumber)")
//                    for cont in conte
//                    existingModel.photo.contents.append(contents)
                }
            }
            
            if foundSamePhoto == false {
                let totalWidth = self.deviceSize.width
                let finalWidth = totalWidth - 146
                let height = descriptionOfPhoto.heightWithConstrainedWidth(width: finalWidth, font: UIFont.systemFont(ofSize: 14))
                let finalHeight = height + 70
                
                newMod.photo = photo
                newMod.descriptionMatchRanges = finalRangesObjects
                newMod.numberOfMatches = numberOfMatches
                newMod.descriptionText = descriptionOfPhoto
                newMod.descriptionHeight = finalHeight
                
                newMod.components = findComponents
                
                resultPhotos.append(newMod)
                
            }
            
            
        }
        
        
        
        
//        newCachedPhoto.contents = contents
        
//            alreadyCachedPhotos.append(newCachedPhoto)
        dispatchSemaphore.signal()
        dispatchGroup.leave()
    }
    
    func finishOCR() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.histCenterC.constant = 0
            UIView.animate(withDuration: 0.12, animations: {
                self.view.layoutIfNeeded()
            })
            
//                    self.tableView.isUserInteractionEnabled = true
            self.shouldAllowPressRow = true
            
            if self.resultPhotos.count >= 1 {
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
                self.noResultsLabel.text = "No results found."
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


extension HistoryFindController {
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
    func relativeDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(xDist * xDist + yDist * yDist)
    }
}
