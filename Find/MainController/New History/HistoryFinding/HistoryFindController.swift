//
//  HistoryFindController.swift
//  Find
//
//  Created by Zheng on 3/8/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol ReturnCache: class {
    func returnHistCache(cachedImages: HistoryModel)
}
class HistoryFindController: UIViewController, UISearchBarDelegate {
    
    
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
          tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
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
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.4, radius: 10, offset: .zero))
        
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        
        let customView = FindBar()
        
        customView.returnTerms = self
        SwiftEntryKit.display(entry: customView, using: attributes)
        
        helpButton.layer.cornerRadius = 6
        doneButton.layer.cornerRadius = 6
        
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
        tableView.isHidden = true
//        welcomeView.anp
        
    }
}
extension HistoryFindController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        cell.baseView.layer.cornerRadius = 4
        cell.baseView.clipsToBounds = true
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
    
    
    
}

extension HistoryFindController: ReturnSortedTerms {
    func returnTerms(stringToListR: [String : EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String : [CGColor]]) {
//        print("RECIEVED TERMS")
        
        
        stringToList = stringToListR
        currentSearchFindList = currentSearchFindListR
        currentListsSharedFindList = currentListsSharedFindListR
        currentSearchAndListSharedFindList = currentSearchAndListSharedFindListR
        currentMatchStrings = currentMatchStringsR
        matchToColors = matchToColorsR
        
        fastFind()
        
    }
    
    func pause(pause: Bool) {
        
        print("recieved pause. \(pause)")
        
    }
    
    
}

extension HistoryFindController {
    func fastFind() {
        for photo in photos {
            print("searching in photo")
            let newMod = FindModel()
            for cont in photo.contents {
//                print("in content")
                let lowercaseContText = cont.text.lowercased()
                let individualCharacterWidth = CGFloat(cont.width) / CGFloat(lowercaseContText.count)
                
                for match in currentMatchStrings {
                    if lowercaseContText.contains(match) {
                        print("contains match: \(match), text: \(lowercaseContText)")
                        let finalW = individualCharacterWidth * CGFloat(match.count)
                        let indicies = lowercaseContText.indicesOf(string: match)
                        for index in indicies {
                            
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
                            
                                
                                
                            } else {
                                print("ERROROROR! NO parent list!")
                            }
                            
                        }
                    }
                }
                    
                    
                
            }
        }
    }
}
