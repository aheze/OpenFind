//
//  CachingViewController.swift
//  Find
//
//  Created by Zheng on 3/12/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftEntryKit

protocol ReturnCachedPhotos: class {
    
    func giveCachedPhotos(photos: HistoryModel)
}
class CachingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    var photos = [HistoryModel]()
    var cachePhotos = [HistoryModel]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    
    @IBOutlet weak var numberCachedLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("dismiss?")
    }
    
    @IBOutlet weak var machineView: UIView!
    
    
    @IBOutlet weak var collectionSuperview: UIView!
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("load")
        print(photos.count)
        cancelButton.layer.cornerRadius = 6
        machineView.layer.cornerRadius = 4
        collectionView.contentInset.top = collectionSuperview.frame.size.height
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cacheCellid", for: indexPath) as! CacheCell
        let historyModel = photos[indexPath.item]
//        let historyModel = hisModel[indexPath.item]
        
        var filePath = historyModel.filePath
        let urlPath = "\(folderURL)\(filePath)"
        print(urlPath)
        
        let finalUrl = URL(string: urlPath)
        cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imageView.sd_imageTransition = .fade
        cell.imageView.sd_setImage(with: finalUrl)
        
        return cell
    }
    
    
}

extension CachingViewController : UICollectionViewDelegateFlowLayout {
  //1
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right)) / 3
    return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
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
