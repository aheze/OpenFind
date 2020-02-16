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


class SymbolsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReturnIconNow, ReceiveIcon {
    
    func receiveIcon(name: String) {
        print("icon recieved")
    }
    
 
    let realm = try! Realm()
    var recentSymbols: Results<RecentSymbol>?
    var hasRecent = false /// If there are recent lists, this becomes 1.
    
//    var recentLists = [String]()
    var weatherList = [String]()
    var natureAndHealthList = [String]()
    var numbersList = [String]()
    var mathList = [String]()
    var currencyList = [String]()
    var techList = [String]()
    var speechList = [String]()
    
    var currentSelectedIndex = IndexPath()
    
    var numOfSecs = 0
    var numOfItemsInSec = [Int : Int]()
    
    var referenceArray: [String] = ["Weather", "Nature and Health", "Numbers", "Math", "Currency", "Tech", "Speech"]
    
    var indexpathToSymbol = [IndexPath: String]()
    //var sectionToCategory = [Int: String]()
    var sectionToCount = [Int: Int]()
    
    private let sectionInsets = UIEdgeInsets(top: 4.0,
                                             left: 4.0,
                                             bottom: 4.0,
                                             right: 4.0)
    
    weak var iconDelegate: GetIconInfo?
    
    var selectedIconName = "square.grid.2x2"
    
    func updateInfo() {
        //print("sdkfhskdf shdf sdsdf")
        print("icon:::: \(selectedIconName)")
        iconDelegate?.returnNewIcon(iconName: selectedIconName)
        //print("sdkfhskdf shdf sdsdf 123")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dictOfSymbols = [IndexMatcher: String]()
    
   // @IBAction func segmentedControl(_ sender: Any) {
    //}
   // @IBOutlet weak var segmentContainer: UIView!
    
    var sfSymbolArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateSymbols()
        getData()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout // casting is required because UICollectionViewLayout doesn't offer header pin. Its feature of UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        populateIndexSym()
//        populateDict()
        
    }
    func getData() {
        recentSymbols = realm.objects(RecentSymbol.self)
        if let recentS = recentSymbols, recentS.count >= 1 {
            hasRecent = true
            referenceArray.insert("Recent", at: 0)
        }
        
        
        //sortLists()
       // collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentSelectedIndex != indexPath {
            print("curr")
            collectionView.deselectItem(at: currentSelectedIndex, animated: false)
            currentSelectedIndex = indexPath
            selectedIconName = indexpathToSymbol[indexPath] ?? "square.grid.2x2"
        } else {
            print("not current")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if hasRecent == true {
            return 8
        } else {
            return 7
        }
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
        
        //var name = ""
    
        if let name = indexpathToSymbol[indexPath] {
            cell.name = name
        } else {
            print("no! \(indexPath)")
        }
        //cell.backgroundColor = UIColor.gray
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(5)
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        //print(widthPerItem)
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
    
    var overlayView = UIView()
    
    var name = "" {
        didSet {
            DispatchQueue.global(qos: .background).async {
                DispatchQueue.main.async {
                    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 55, weight: .semibold)
                    let newImage = UIImage(systemName: self.name, withConfiguration: symbolConfiguration)?.withTintColor(.black, renderingMode: .alwaysOriginal)
                    self.imageView.image = newImage
//                    let length = self.contentView.frame.size.width
//                    self.widthConstraint.constant = length
//                    self.heightConstraint.constant = length
                   // self.imageView.contentMode = .scaleAspectFit
                }
            }
        }
    }
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                let length = self.contentView.frame.size.width
                
                //var newView = UIView()
                overlayView.frame = (CGRect(x: 0, y: 0, width: length, height: length))
                overlayView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                overlayView.layer.cornerRadius = 10
                overlayView.tag = 010101
                contentView.insertSubview(overlayView, at: 0)
                
            } else {
               // if let newView = contentView.viewWithTag(010101) {
                    overlayView.removeFromSuperview()
               // }
            }
        }
    }
}

extension SymbolsViewController {
    func populateIndexSym() {
        
        if (hasRecent) {
            
            sectionToCount[0] = recentSymbols?.count
            sectionToCount[1] = weatherList.count
            sectionToCount[2] = natureAndHealthList.count
            sectionToCount[3] = numbersList.count
            sectionToCount[4] = mathList.count
            sectionToCount[5] = currencyList.count
            sectionToCount[6] = techList.count
            sectionToCount[7] = speechList.count
            
            if hasRecent == true {
               // return 8
            } else {
               // return 7
            }
            
            for i in sectionToCount.keys {
                if let count = sectionToCount[i] {
                    for j in 0..<count {
                        let indP = IndexPath(row: j, section: i)
                        var name = ""
                        switch i {
                        case 0:
                            name = recentSymbols?[j].name ?? "asdasd"
                        case 1:
            //                print("0")
                            name = weatherList[j]
                        case 2:
            //                print("1")
                            name = natureAndHealthList[j]
                        case 3:
            //                 print("2")
                            name = numbersList[j]
                        case 4:
            //                print("3")
                            name = mathList[j]
                        case 5:
            //                print("4")
                            name = currencyList[j]
                        case 6:
            //                print("5")
                            name = techList[j]
                        case 7:
            //                print("6")
                            name = speechList[j]
                        default:
                            print("weird error NOT tempInt (is 0)")
                        }
                        indexpathToSymbol[indP] = name
                    }
                }
            }
            

        } else {
            sectionToCount[0] = weatherList.count
            sectionToCount[1] = natureAndHealthList.count
            sectionToCount[2] = numbersList.count
            sectionToCount[3] = mathList.count
            sectionToCount[4] = currencyList.count
            sectionToCount[5] = techList.count
            sectionToCount[6] = speechList.count
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
                            name = weatherList[j]
                        case 1:
            //                print("1")
                            name = natureAndHealthList[j]
                        case 2:
            //                 print("2")
                            name = numbersList[j]
                        case 3:
            //                print("3")
                            name = mathList[j]
                        case 4:
            //                print("4")
                            name = currencyList[j]
                        case 5:
            //                print("5")
                            name = techList[j]
                        case 6:
            //                print("6")
                            name = speechList[j]
                        default:
                            print("weird error NOT tempInt (is 0)")
                        }
                        indexpathToSymbol[indP] = name
                    }
                }
            }
        }
        //print(indexpathToSymbol)
        collectionView.reloadData()
    }
    
}

