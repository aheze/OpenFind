//
//  CachingCancelController.swift
//  Find
//
//  Created by Zheng on 3/16/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SwiftEntryKit

//protocol InjectCachedPhotos: class {
//    func injectCachedPhotos(photos: [EditableHistoryModel])
//}
class CachingCancelController: UIViewController {
    
    
    
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var cancelImageView: UIImageView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
       
    @IBAction func keepPressed(_ sender: Any) {
    }
       
    @IBAction func discardPressed(_ sender: Any) {
        SwiftEntryKit.dismiss()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        var attributes = EKAttributes.centerFloat
        attributes.displayDuration = .infinity
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.screenBackground = .color(color: EKColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3802521008)))
        attributes.entryBackground = .color(color: .white)
        attributes.screenInteraction = .absorbTouches
        attributes.positionConstraints.size.height = .constant(value: UIScreen.main.bounds.size.height - CGFloat(300))
        attributes.scroll = .enabled(swipeable: false, pullbackAnimation: .jolt)
//            attributes.lifecycleEvents.willDisappear = {
//
//
//
//            }
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let cacheController = storyboard.instantiateViewController(withIdentifier: "CachingViewController") as! CachingViewController
   
        cacheController.folderURL = folderURL
        cacheController.photos = totalPhotos
//        cacheController.alreadyCached = cachedPhotos
        cacheController.isResuming = true
        
        
        cacheController.view.layer.cornerRadius = 10
//            print("DAJFSDFSODFIODF: \(folderURL)")
        SwiftEntryKit.display(entry: cacheController, using: attributes)
    }
    
    
    var totalPhotos = [EditableHistoryModel]()
//    var cachedPhotos = [EditableHistoryModel]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
//    weak var injectPhotos: InjectCachedPhotos?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        
        var count = 0
        for photo in totalPhotos {
            if photo.isDeepSearched {
                count += 1
            }
        }
        
        var newLabel = ""
        if count == 1 {
            newLabel = """
            1 photo has already been cached.
            Would you like to keep its cache?
            """
        } else {
            newLabel = """
            \(count) photos have already been cached.
            Would you like to keep their caches?
            """
        }
        cancelLabel.text = newLabel
        
        
    }
    
    
}
extension CachingCancelController {
    func setUpViews() {
        
        cancelImageView.layer.cornerRadius = 4
//        cancelImageView.layer.masksToBounds = true
//        cancelImageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        
        keepButton.layer.cornerRadius = 6
        discardButton.layer.cornerRadius = 6
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        
        
        
    }
}
