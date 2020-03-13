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
    

    
    var photos = [HistoryModel]()

    weak var returnCache: ReturnCache?
//    func changeSearchPhotos(photos: [URL]) {
//        photos = photos
//    }
    
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
        attributes.scroll = .disabled
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
    }
}
extension HistoryFindController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HFindCell", for: indexPath) as! HistoryFindCell
        
        return cell
//        dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
    }
}

extension HistoryFindController: ReturnSortedTerms {
    func returnTerms(stringToListR: [String : EditableFindList], currentSearchFindListR: EditableFindList, currentListsSharedFindListR: EditableFindList, currentSearchAndListSharedFindListR: EditableFindList, currentMatchStringsR: [String], matchToColorsR: [String : [CGColor]]) {
        print("RECIEVED TERMS")
    }
    
    func pause(pause: Bool) {
        
        print("recieved pause. \(pause)")
        
    }
    
    
}
