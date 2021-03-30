//
//  ColorsViewController.swift
//  Find
//
//  Created by Andrew on 2/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol GetColorInfo: class {
    func returnNewColor(colorName: String)
}

class ColorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let spacing = CGFloat(6)
    let sectionInsets = UIEdgeInsets(top: 16,
                                             left: 16,
                                             bottom: 16,
                                             right: 16)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// remove similar color
        if colorName == "#f6b93b" {
            colorName = "#f7b731"
        }
        if let row = colorArray.firstIndex(of: colorName) {
            let indP = IndexPath(item: row, section: 0)
            selectedPath = row
            collectionView.selectItem(at: indP, animated: false, scrollPosition: .centeredVertically)
            collectionView.contentInset = sectionInsets
        }
        
        collectionView.isAccessibilityElement = false
    }
    
    var colorName = "#579f2b"
    var selectedPath = -1
    
    weak var colorDelegate: GetColorInfo?
    
    /// removed "#f6b93b"
    let colorArray: [String] = [
        "#eb2f06", "#e55039", "#f7b731", "#fed330", "#78e08f",
        "#fc5c65", "#fa8231", "#b8e994", "#2bcbba",
        "#ff6348", "#b71540", "#00aeef", "579f2b", "#778ca3",
        "#e84393", "#a55eea", "#5352ed", "#70a1ff", "#40739e",
        "#45aaf2", "#2d98da", "#d1d8e0", "#4b6584", "#0a3d62"
    ]

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorName = colorArray[indexPath.item]
        colorDelegate?.returnNewColor(colorName: colorName)
        selectedPath = indexPath.item
        
        if let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            colorCell.checkMarkView.alpha = 1
            colorCell.contentView.accessibilityTraits = .selected
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCell {
            colorCell.checkMarkView.alpha = 0
            colorCell.contentView.accessibilityTraits = .none
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! ColorCell
        
        let color = UIColor(hexString: colorArray[indexPath.item])
        
        cell.contentView.backgroundColor = color
        cell.contentView.layer.cornerRadius = 6
        
        if selectedPath == indexPath.item {
            cell.checkMarkView.alpha = 1
            cell.contentView.accessibilityTraits = .selected
        } else {
            cell.checkMarkView.alpha = 0
            cell.contentView.accessibilityTraits = .none
        }
        
        let colorDescription = colorArray[indexPath.item].getDescription()
        
        let colorString = AccessibilityText(text: "\(colorDescription.0)\n", isRaised: false)
        let pitchTitle = AccessibilityText(text: "Pitch", isRaised: true)
        let pitchString = AccessibilityText(text: "\(colorDescription.1)", isRaised: false, customPitch: colorDescription.1)
        let accessibilityLabel = UIAccessibility.makeAttributedText([colorString, pitchTitle, pitchString])
        
        cell.contentView.isAccessibilityElement = true
        cell.contentView.accessibilityAttributedLabel = accessibilityLabel
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.bounds.width
        let itemsPerRow = Int(totalWidth / 60)
        
        let interItemSpacing = spacing * (CGFloat(itemsPerRow) - 1)
        let edgeSpacing = sectionInsets.left * 2
        
        let availableWidth = collectionView.frame.width - interItemSpacing - edgeSpacing
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var checkMarkView: UIImageView!
}
