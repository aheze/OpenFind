//
//  SymbolsViewController.swift
//  Find
//
//  Created by Andrew on 2/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import RealmSwift


protocol GetIconInfo: class {
    func returnNewIcon(iconName: String)
}


class SymbolsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReturnIconNow {
 
    
  
    weak var iconDelegate: GetIconInfo?
    
    var selectedIconName = "square.grid.2x2"
    
    func updateInfo() {
        //print("sdkfhskdf shdf sdsdf")
        iconDelegate?.returnNewIcon(iconName: selectedIconName)
        //print("sdkfhskdf shdf sdsdf 123")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func segmentedControl(_ sender: Any) {
    }
    @IBOutlet weak var segmentContainer: UIView!
    
    var sfSymbolArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSymbolArray()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sfSymbolArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolCellID", for: indexPath) as! SymbolCell
        
        
        let name = sfSymbolArray[indexPath.item]
//        let newImage = UIImage(systemName: name, withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        cell.name = name
        
        //cell.imageView.image = newImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = (collectionView.frame.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)) / 8
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


class SymbolCell: UICollectionViewCell {
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var name = "" {
        didSet {
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
                                let newImage = UIImage(systemName: self.name, withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
                                self.imageView.image = newImage
                    
                }
            }
        }
    }
   // weak var imageView: UIImageView!

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        let imageV = UIImageView()
//        self.contentView.addSubview(imageV)
//        imageV.snp.makeConstraints { (make) in
//            make.edges.equalToSuperview()
//        }
//        self.imageView = imageV
//
//        self.imageView.contentMode = .scaleAspectFit
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
//protocol NewListMade: class {
//    func madeNewList(name: String, description: String, contents: String, imageName: String, imageColor: String)
//}


