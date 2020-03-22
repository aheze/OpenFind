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
    
    var photos = [HistoryModel]()
    var resultPhotos = [FindModel]()
    
    
    weak var returnCache: ReturnCache?
//    func changeSearchPhotos(photos: [URL]) {
//        photos = photos
//    }
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 82, right: 0)
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
        
//        welcomeView.anp
        
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
//        cell.titleLabel.text = "sdfsdfsdf"
        
        let model = resultPhotos[indexPath.row]
        
        var urlPath = model.photo.filePath
        urlPath = "\(folderURL)\(urlPath)"
        let finalUrl = URL(string: urlPath)
        
        cell.titleLabel.text = model.photo.dateCreated.convertDateToReadableString()
        
        cell.photoImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.photoImageView.sd_imageTransition = .fade
        cell.photoImageView.sd_setImage(with: finalUrl)
        
        
        
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
        
        fastFind()
        if stringToList.count == 0 {
            
            noResultsLabel.text = "Start by typing or selecting a list..."
            UIView.animate(withDuration: 0.1, animations: {
                self.noResultsLabel.alpha = 1
                self.noResultsLabel.transform = CGAffineTransform.identity
            })
            
        }
        
        
        
    }
    
    func pause(pause: Bool) {
        
        print("recieved pause. \(pause)")
        
    }
    
    
}

extension HistoryFindController {
    func fastFind() {
        var findModels = [FindModel]()
        
//        print(
        for photo in photos {
            print("searching in photo")
            var num = 0
            
            let newMod = FindModel()
            newMod.photo = photo
            
//            var attributedStrings = [NSAttributedString]()
            
            for cont in photo.contents {
//                print("photoCont: \(photo.contents)")
                
//                print("in content")
                let lowercaseContText = cont.text.lowercased()
                let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                
                for match in currentMatchStrings {
                    if lowercaseContText.contains(match) {
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
                            if let parentList = stringToList[match] {
                                switch parentList.descriptionOfList {
                                case "Search Array List +0-109028304798614":
                                        print("Search Array")
                                    newComponent.parentList = currentSearchFindList
                                    newComponent.colors = [highlightColor]
                                case "Shared Lists +0-109028304798614":
                                        print("Shared Lists")
                                    newComponent.parentList = currentListsSharedFindList
                                    newComponent.isSpecialType = "Shared List"
                                case "Shared Text Lists +0-109028304798614":
                                        print("Shared Text Lists")
                                    newComponent.parentList = currentSearchAndListSharedFindList
                                    newComponent.isSpecialType = "Shared Text List"
                                default:
                                        print("normal")
                                    newComponent.parentList = parentList
                                    newComponent.colors = [parentList.iconColorName]
                                }
//                                newMod.components
//                                var finalRange = 0...999
//                                print("indexL \(index), length: \(match.count), totalCount: \(lowercaseContText.count)")
//
//                                let totalCount = lowercaseContText.count
//
//                                if lowercaseContText.count >= 25 {
//                                    let endIndex = index + match.count - 1
//                                    var textRange = index...endIndex
//
//                                    var paddingSpace = 0
//
//                                    let availibleSpace = totalCount - match.count
//
//                                    if availibleSpace % 2 == 0 {
//                                        print("even")
//                                        paddingSpace = availibleSpace / 2
//                                    } else {
//                                        paddingSpace = (availibleSpace - 1) / 2
//                                    }
//
//
//                                    let startInd = index - paddingSpace
//                                    let endInd = index + match.count + paddingSpace
//
//                                    if startInd >= 0 {
//                                        if endInd <= totalCount - 1 {
//
//                                        } else {
//
//                                        }
//                                    } else {
//                                        if endInd <= totalCount - 1 {
//
//                                        } else {
//
//                                        }
//                                    }
//
//
//
//                                } else {
//
//                                }
//                                if let range = lowercaseContText.range(of: match) {
//                                    print("exists")
//                                    print(range)
//                                }
                                
                            } else {
                                print("ERROROROR! NO parent list!")
                            }
                            
                            newMod.components.append(newComponent)
                            
                        }
                    }
                }
                    
                    
                
            }
            
            
            newMod.numberOfMatches = num
            if num >= 1 {
                findModels.append(newMod)
            }
            
        }
        print("FIND COUNT: \(findModels.count)")
        resultPhotos = findModels
        
        
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
            tableView.isHidden = false
            UIView.animate(withDuration: 0.1, animations: {
                self.noResultsLabel.alpha = 0
                self.tableView.alpha = 1
                self.noResultsLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.tableView.transform = CGAffineTransform.identity
            })
        } else {
            print("NO results")
            
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
        tableView.reloadData()
        
        
    }
    
    
}
