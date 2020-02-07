//
//  ToolbarTopCollectionView.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func loadListsRealm() {
        listCategories = realm.objects(FindList.self)
        listsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listCategories?.count ?? 0
    }
//    func save(list: FindList) {
//        do {
//            try realm.write {
//                realm.add(list)
//            }
//        } catch {
//            print("Error saving category \(error)")
//        }
//
//        listsCollectionView.reloadData()
//
//    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
        let title = listCategories?[indexPath.row].name
        cell.button.setTitle(title, for: .normal)
        cell.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        cell.layer.cornerRadius = 6
          
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
        let itemSize = cell.button.frame.size.width
        return CGSize(width: 120, height: CGFloat(24))
    }
}

class ToolbarTopCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        //frame.size.width = ceil(size.width)
//        frame.size.height = 24
//        print("ashdaksd")
//        print(size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
//    }
    
    
}
