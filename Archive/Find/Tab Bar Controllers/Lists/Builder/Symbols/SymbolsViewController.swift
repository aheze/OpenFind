//
//  SymbolsViewController.swift
//  Find
//
//  Created by Andrew on 2/7/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

protocol GetIconInfo: class {
    func returnNewIcon(iconName: String)
}

class SymbolsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func scrolledHere() {
        collectionView.scrollToItem(at: currentSelectedIndex, at: .centeredVertically, animated: true)
    }
    
    func receiveIcon(name: String) {
        populateSymbols()
        selectedIconName = name
    }
 
    var techList = [String]()
    var weatherList = [String]()
    var natureAndHealthList = [String]()
    var numbersList = [String]()
    var mathList = [String]()
    var currencyList = [String]()
    var speechList = [String]()
    
    var currentSelectedIndex = IndexPath()
    
    var numOfSecs = 0
    var numOfItemsInSec = [Int: Int]()
    
    let techLoc = NSLocalizedString("techLoc", comment: "SymbolsViewController def=Tech")
    let weatherLoc = NSLocalizedString("weatherLoc", comment: "SymbolsViewController def=Weather")
    let speechLoc = NSLocalizedString("speechLoc", comment: "SymbolsViewController def=Speech")
    let natureLoc = NSLocalizedString("natureLoc", comment: "SymbolsViewController def=Nature")
    let currencyLoc = NSLocalizedString("currencyLoc", comment: "SymbolsViewController def=Currency")
    let mathLoc = NSLocalizedString("mathLoc", comment: "SymbolsViewController def=Math")
    let numbersLoc = NSLocalizedString("numbersLoc", comment: "SymbolsViewController def=Numbers")
    
    lazy var referenceArray: [String] = [techLoc, weatherLoc, speechLoc, natureLoc, currencyLoc, mathLoc, numbersLoc]
    
    var indexPathToSymbol = [IndexPath: String]()
    var sectionToCount = [Int: Int]()
    
    let spacing = CGFloat(8)
    let sectionInsets = UIEdgeInsets(top: 16,
                                     left: 16,
                                     bottom: 16,
                                     right: 16)
    
    weak var iconDelegate: GetIconInfo?
    
    var selectedIconName = "square.grid.2x2"
    
    @IBOutlet var collectionView: UICollectionView!
    
    var iconColor: UIColor = .label
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSymbols()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        populateIndexSym()
        highlightSelectedSymbol()
        
        collectionView.isAccessibilityElement = false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelectedIndex = indexPath
        
        if let cell = collectionView.cellForItem(at: indexPath) as? SymbolCell {
            cell.overlayView.alpha = 1
            cell.imageView.accessibilityTraits = [.image, .selected]
        }
        
        selectedIconName = indexPathToSymbol[indexPath] ?? "square.grid.2x2"
        iconDelegate?.returnNewIcon(iconName: selectedIconName)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: currentSelectedIndex) as? SymbolCell {
            cell.overlayView.alpha = 0
            cell.imageView.accessibilityTraits = .image
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 7
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionToCount[section] ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolCellID", for: indexPath) as! SymbolCell
        cell.overlayView.layer.cornerRadius = 4
        
        cell.imageView.isAccessibilityElement = true
        
        if currentSelectedIndex == indexPath {
            cell.overlayView.alpha = 1
            cell.imageView.accessibilityTraits = [.image, .selected]
        } else {
            cell.overlayView.alpha = 0
            cell.imageView.accessibilityTraits = .image
        }
        
        if let name = indexPathToSymbol[indexPath] {
            let image = UIImage(systemName: name)
            cell.imageView.image = image
            cell.imageView.accessibilityLabel = name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let itemsPerRow = CGFloat(8)
        
        let interItemSpacing = spacing * (itemsPerRow - 1)
        let edgeSpacing = sectionInsets.left * 2
        
        let availableWidth = collectionView.frame.width - interItemSpacing - edgeSpacing
        let widthPerItem = (availableWidth / itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "symbolsSectionHeader", for: indexPath) as! SymbolsSectionHeader
        var sectionName = ""
        sectionName = referenceArray[indexPath.section]
        
        headerView.nameLabel.text = sectionName
        
        headerView.isAccessibilityElement = true
        headerView.accessibilityLabel = sectionName
        headerView.accessibilityTraits = [.staticText, .header]
        return headerView
    }
}

class SymbolCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var overlayView: UIView!
}

extension SymbolsViewController {
    func populateIndexSym() {
        sectionToCount[0] = techList.count
        sectionToCount[1] = weatherList.count
        sectionToCount[2] = speechList.count
        sectionToCount[3] = natureAndHealthList.count
        sectionToCount[4] = currencyList.count
        sectionToCount[5] = mathList.count
        sectionToCount[6] = numbersList.count

        for i in sectionToCount.keys {
            if let count = sectionToCount[i] {
                for j in 0..<count {
                    let indP = IndexPath(row: j, section: i)
                    var name = ""
                    switch i {
                    case 0:
                        name = techList[j]
                    case 1:
                        name = weatherList[j]
                    case 2:
                        name = speechList[j]
                    case 3:
                        name = natureAndHealthList[j]
                    case 4:
                        name = currencyList[j]
                    case 5:
                        name = mathList[j]
                    case 6:
                        name = numbersList[j]
                    default:
                        break
                    }
                    indexPathToSymbol[indP] = name
                }
            }
        }
        collectionView.reloadData()
    }
}

extension SymbolsViewController {
    func highlightSelectedSymbol() {
        let arrays = [techList, weatherList, speechList, natureAndHealthList, currencyList, mathList, numbersList]
        let indexPath = loopOverArrays(arrays: arrays, lookFor: selectedIconName)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        currentSelectedIndex = indexPath
    }
    
    func loopOverArrays(arrays: [[String]], lookFor: String) -> IndexPath {
        var indexPath: IndexPath?
        for (arrayIndex, array) in arrays.enumerated() {
            if let indexFound = loopOverArray(array: array, lookFor: lookFor) {
                indexPath = IndexPath(item: indexFound, section: arrayIndex)
                break
            }
        }
        return indexPath ?? IndexPath(item: 0, section: 0)
    }
    
    func loopOverArray(array: [String], lookFor: String) -> Int? {
        var firstIndex: Int?
        for (index, iconName) in array.enumerated() {
            if iconName == lookFor {
                firstIndex = index
                break
            }
        }
        return firstIndex
    }
}
