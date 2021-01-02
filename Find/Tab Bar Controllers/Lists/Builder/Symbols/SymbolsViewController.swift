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
        print("scrolled here, \(currentSelectedIndex)")
        collectionView.scrollToItem(at: currentSelectedIndex, at: .centeredVertically, animated: true)
    }
    
    
    func receiveIcon(name: String) {
        print("icon recieved: \(name)")
        
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
    var numOfItemsInSec = [Int : Int]()
    
    let techLoc = NSLocalizedString("techLoc", comment: "SymbolsViewController def=Tech")
    let weatherLoc = NSLocalizedString("weatherLoc", comment: "SymbolsViewController def=Weather")
    let speechLoc = NSLocalizedString("speechLoc", comment: "SymbolsViewController def=Speech")
    let natureLoc = NSLocalizedString("natureLoc", comment: "SymbolsViewController def=Nature")
    let currencyLoc = NSLocalizedString("currencyLoc", comment: "SymbolsViewController def=Currency")
    let mathLoc = NSLocalizedString("mathLoc", comment: "SymbolsViewController def=Math")
    let numbersLoc = NSLocalizedString("numbersLoc", comment: "SymbolsViewController def=Numbers")
    
//    var referenceArrays: [String] = ["Tech", "Weather", "Speech", "Nature", "Currency", "Math", "Numbers"]
    lazy var referenceArray: [String] = [techLoc, weatherLoc, speechLoc, natureLoc, currencyLoc, mathLoc, numbersLoc]
    
    var indexpathToSymbol = [IndexPath: String]()
    var sectionToCount = [Int: Int]()
    
    private let sectionInsets = UIEdgeInsets(top: 16,
                                             left: 16,
                                             bottom: 16,
                                             right: 16)
    
    weak var iconDelegate: GetIconInfo?
    
    var selectedIconName = "square.grid.2x2"
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dictOfSymbols = [IndexMatcher: String]()
    
    var sfSymbolArray: [String] = [String]()
    var iconColor: UIColor = UIColor.label
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSymbols()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        populateIndexSym()
        highlightSelectedSymbol()
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentSelectedIndex != indexPath {
            
            if let cell = collectionView.cellForItem(at: currentSelectedIndex) as? SymbolCell {
                cell.overlayView.alpha = 0
            }
            
            currentSelectedIndex = indexPath
            
            selectedIconName = indexpathToSymbol[indexPath] ?? "square.grid.2x2"
            iconDelegate?.returnNewIcon(iconName: selectedIconName)
            
            collectionView.reloadItems(at: [indexPath])
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
        
        if currentSelectedIndex == indexPath {
            cell.overlayView.alpha = 1
        } else {
            cell.overlayView.alpha = 0
        }
        
        
        if let name = indexpathToSymbol[indexPath] {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            
            let image = UIImage(systemName: name, withConfiguration: symbolConfiguration)
            let configuredImage = image?.withTintColor(iconColor, renderingMode: .alwaysOriginal)
            cell.imageView.image = configuredImage
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(8)
        
        let availableWidth = collectionView.frame.width - (sectionInsets.left * (itemsPerRow + 1))
        let widthPerItem = (availableWidth / itemsPerRow)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 45)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "symbolsSectionHeader", for: indexPath) as! SymbolsSectionHeader
        var sectionName = ""
        sectionName = referenceArray[indexPath.section]
        
        headerView.nameLabel.text = sectionName
        return headerView
    }

}


class SymbolCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
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
        //print("we: \(weatherList.count)")
        for i in sectionToCount.keys {
            //print("assasd")
            print(collectionView.numberOfSections)
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
                        print("weird error NOT tempInt (is 0)")
                    }
                    indexpathToSymbol[indP] = name
                }
            }
        }
        collectionView.reloadData()
    }
    
}

extension SymbolsViewController {
    func highlightSelectedSymbol() {
        var firstOccurance: (Int, Int) = (-1, -1)
        var hasFound = false
        let name = selectedIconName
        for (index, weather) in techList.enumerated() {
            if weather == name {
                firstOccurance = (0, index)
                hasFound = true
            }
        }
        if !(hasFound) {
            for (index, nat) in weatherList.enumerated() {
//                print(nat)
                if nat == name {
                    firstOccurance = (1, index)
                }
            }
        }
        if !(hasFound) { for (index, num) in speechList.enumerated() { if num == name { firstOccurance = (2, index) } } }
        if !(hasFound) { for (index, mat) in natureAndHealthList.enumerated() { if mat == name { firstOccurance = (3, index) } } }
        if !(hasFound) { for (index, cur) in currencyList.enumerated() { if cur == name { firstOccurance = (4, index) } } }
        if !(hasFound) { for (index, tec) in mathList.enumerated() { if tec == name { firstOccurance = (5, index) } } }
        if !(hasFound) { for (index, spe) in numbersList.enumerated() { if spe == name { firstOccurance = (6, index) } } }

        let indP = IndexPath(item: firstOccurance.1, section: firstOccurance.0)
        collectionView.selectItem(at: indP, animated: false, scrollPosition: .centeredVertically)
        currentSelectedIndex = indP
    }
}
