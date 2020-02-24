//
//  ToolbarTopCollectionView.swift
//  Find
//
//  Created by Andrew on 1/19/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource {
    func loadListsRealm() {
        
        listCategories = realm.objects(FindList.self)
        listCategories = listCategories!.sorted(byKeyPath: "dateCreated", ascending: false)
        if let lC = listCategories {
            for singleL in lC {
                
                var editList = EditableFindList()
                
                editList.name = singleL.name
                editList.descriptionOfList = singleL.descriptionOfList
                editList.iconImageName = singleL.iconImageName
                editList.iconColorName = singleL.iconColorName
                var contents = [String]()
                for singleCont in singleL.contents {
                    contents.append(singleCont)
                }
                
                editList.contents = contents
                
                editableListCategories.append(editList)
            }
        }
        
        listsCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 100100 {
            return editableListCategories.count
        } else { ///The search bar 100101
            return selectedLists.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 100100 {
            let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
            if let list = listCategories?[indexPath.row] {
                cell.labelText.text = list.name
                cell.backgroundColor = UIColor(hexString: list.iconColorName)
                cell.layer.cornerRadius = 6
                let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
                let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
                
                cell.imageView.image = newImage
            }
            return cell
        } else {
            let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
            if let list = listCategories?[indexPath.row] {
                cell.labelText.text = list.name
                cell.backgroundColor = UIColor(hexString: list.iconColorName)
                cell.layer.cornerRadius = 6
                let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
                let newImage = UIImage(systemName: list.iconImageName, withConfiguration: symbolConfiguration)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
                
                cell.imageView.image = newImage
            }
            return cell
        }
    }
//    func collectionView(_ collectionView: UICollectionView,
//                      layout collectionViewLayout: UICollectionViewLayout,
//                      sizeForItemAt indexPath: IndexPath) -> CGSize {
//       // let cell = listsCollectionView.dequeueReusableCell(withReuseIdentifier: "tooltopCell", for: indexPath) as! ToolbarTopCell
//        //let itemSize = cell.button.frame.size.width
//        return CGSize(width: 120, height: CGFloat(38))
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 100100 {
            print("select cell")
            selectedLists.append(indexPath.item)
            print(selectedLists)
            
            let indexP = IndexPath(item: selectedLists.count - 1, section: 0)
            listViewCollectionView.insertItems(at: [indexP])
            
            editableListCategories.remove(at: indexPath.item)
            listsCollectionView.deleteItems(at: [indexPath])
          //  editableListCategories
            //listsViewWidth.up
        } else {
                
        }
    }
}



class ToolbarTopCell: UICollectionViewCell {
    
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
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
