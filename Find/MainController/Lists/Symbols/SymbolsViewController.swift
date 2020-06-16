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


class SymbolsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReceiveIcon, ScrolledToIcons {
    
    func scrolledHere() {
        print("scrolled here, \(currentSelectedIndex)")
        collectionView.scrollToItem(at: currentSelectedIndex, at: .centeredVertically, animated: true)
    }
    
    
    func receiveIcon(name: String) {
        print("icon recieved: \(name)")
        //print(name)
        populateSymbols()
        
        selectedIconName = name
    }
    
 
//    let realm = try! Realm()
//    var recentSymbols: Results<RecentSymbol>?
//    var hasRecent = false /// If there are recent lists, this becomes 1.
    
//    var recentLists = [String]()
    
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
    
//    sectionToCount[0] = techList.count
//    sectionToCount[1] = weatherList.count
//    sectionToCount[2] = speechList.count
//    sectionToCount[3] = natureAndHealthList.count
//    sectionToCount[4] = currencyList.count
//    sectionToCount[5] = mathList.count
//    sectionToCount[6] = numbersList.count
    var referenceArray: [String] = ["Tech", "Weather", "Speech", "Nature", "Currency", "Math", "Numbers"]
    
    var indexpathToSymbol = [IndexPath: String]()
    //var sectionToCategory = [Int: String]()
    var sectionToCount = [Int: Int]()
    
    private let sectionInsets = UIEdgeInsets(top: 4.0,
                                             left: 4.0,
                                             bottom: 4.0,
                                             right: 4.0)
    
    weak var iconDelegate: GetIconInfo?
    
    var selectedIconName = "square.grid.2x2"
    
//    func updateInfo() {
//        //print("sdkfhskdf shdf sdsdf")
//        print("icon:::: \(selectedIconName)")
////        iconDelegate?.returnNewIcon(iconName: selectedIconName)
//        //print("sdkfhskdf shdf sdsdf 123")
//    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dictOfSymbols = [IndexMatcher: String]()
    
   // @IBAction func segmentedControl(_ sender: Any) {
    //}
   // @IBOutlet weak var segmentContainer: UIView!
    
    var sfSymbolArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSymbols()
//        getData()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        populateIndexSym()
        highlightSelectedSymbol()
//        populateDict()
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentSelectedIndex != indexPath {
            print("curr: \(indexPath)")
            
            
            if let cell = collectionView.cellForItem(at: currentSelectedIndex) as? SymbolCell {
                cell.overlayView.alpha = 0
//                print("LET")
            } else {
//                print("NONE")
            }
//            collectionView.reloadItems(at: [currentSelectedIndex])
//            collectionView.deselectItem(at: currentSelectedIndex, animated: false)
            currentSelectedIndex = indexPath
            
//            if let cell = collectionView.cellForItem(at: indexPath) as? SymbolCell {
//                cell.overlayView.alpha = 0
//                print("LET")
//            } else {
//                print("NONE")
//            }
            selectedIconName = indexpathToSymbol[indexPath] ?? "square.grid.2x2"
            iconDelegate?.returnNewIcon(iconName: selectedIconName)
            
            
            collectionView.reloadItems(at: [indexPath])
            
        } else {
//            print("not current")
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
        //return sfSymbolArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolCellID", for: indexPath) as! SymbolCell
        cell.overlayView.layer.cornerRadius = 4
        
        if currentSelectedIndex == indexPath {
//            print("True, \(indexPath)")
            cell.overlayView.alpha = 1
        } else {
//            print("False, \(indexPath)")
            cell.overlayView.alpha = 0
        }
        
        //var name = ""
    
        if let name = indexpathToSymbol[indexPath] {
            cell.name = name
        } else {
//            print("no! \(indexPath)")
        }
        //cell.backgroundColor = UIColor.gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(5)
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow) - 4
        print(widthPerItem)
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 45)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "symbolsSectionHeader", for: indexPath) as! SymbolsSectionHeader
        //headerView.todayLabel.text = "Text: \(indexPath.section)"
        var sectionName = ""
        sectionName = referenceArray[indexPath.section]
        headerView.nameLabel.text = sectionName
      
        //let date = sectionToDate[indexPath.section]!
       // let readableDate = convertDateToReadableString(theDate: date)
        //headerView.todayLabel.text = readableDate
        //headerView.clipsToBounds = false
        return headerView
    }

}


class SymbolCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
//    var overlayView = UIView()
    
    @IBOutlet weak var overlayView: UIView!
    var name = "" {
        didSet {
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
                    let newImage = UIImage(systemName: self.name, withConfiguration: symbolConfiguration)?.withTintColor(UIColor(named: "PureBlack") ?? .black, renderingMode: .alwaysOriginal)
                    self.imageView.image = newImage
//                    let length = self.contentView.frame.size.width
//                    self.widthConstraint.constant = length
//                    self.heightConstraint.constant = length
                   // self.imageView.contentMode = .scaleAspectFit
                }
            }
        }
    }
//    override var isSelected: Bool {
//        didSet {
//            if (isSelected) {
//                let length = self.contentView.frame.size.width
//                overlayView.alpha = 1
//
//                //var newView = UIView()
////                overlayView.frame = (CGRect(x: 0, y: 0, width: length, height: length))
////                overlayView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
////                overlayView.layer.cornerRadius = 10
////                //overlayView.tag = 010101
////                contentView.insertSubview(overlayView, at: 0)
//
//            } else {
//                overlayView.alpha = 0
//               // if let newView = contentView.viewWithTag(010101) {
////                    overlayView.removeFromSuperview()
//               // }
//            }
//        }
//    }
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
                    //print(collectionView.numberOfItems(inSection: i))
                    //print("CYCLE")
                    let indP = IndexPath(row: j, section: i)
                    var name = ""
                    switch i {
                    case 0:
        //                print("0")
                        name = techList[j]
                    case 1:
        //                print("1")
                        name = weatherList[j]
                    case 2:
        //                 print("2")
                        name = speechList[j]
                    case 3:
        //                print("3")
                        name = natureAndHealthList[j]
                    case 4:
        //                print("4")
                        name = currencyList[j]
                    case 5:
        //                print("5")
                        name = mathList[j]
                    case 6:
        //                print("6")
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

        print("NAME:::")
        print(name)
        print(firstOccurance)
        let indP = IndexPath(item: firstOccurance.1, section: firstOccurance.0)
        collectionView.selectItem(at: indP, animated: false, scrollPosition: .centeredVertically)
        currentSelectedIndex = indP
       // collectionView.scrollToItem(at: indP, at: .centeredVertically, animated: true)
    }
}
