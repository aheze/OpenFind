//
//  HCollectionViewController.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//
import UIKit

class NewHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var dictOfHists = Dictionary<Date, Array<UIImage>>()
    var dictOfFormats : [Int: Date] = [Int: Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        collectionView.alwaysBounceVertical = true
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionHeaderId", for: indexPath) as! TitleSupplementaryView
            //headerView.todayLabel.text = "Text: \(indexPath.section)"
            let date = dictOfFormats[indexPath.section]!
            let readableDate = convertDateToReadableString(theDate: date)
            headerView.todayLabel.text = readableDate
            return headerView

        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "sectionFooterId", for: indexPath) as! FooterView
            footerView.clipsToBounds = false
            return footerView

        default:
            assert(false, "Unexpected element kind")
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dictOfFormats.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let date = dictOfFormats[section]!
        let photos = dictOfHists[date]!
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hPhotoId", for: indexPath) as! HPhotoCell
        let date = dictOfFormats[indexPath.section]
        let photos = dictOfHists[date!]
        //cell.imageView.image = photos![indexPath.item]
        //cell.imageView.translatesAutoresizingMaskIntoConstraints = false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        ///I can't change the spacing of the columns... it is stuck at 4.
        let itemsPerRow = CGFloat(4)
        let paddingSpace = CGFloat(4) * (itemsPerRow - 1) ///4 points, the dividers for each column
        let availibleWidth = collectionView.frame.width - paddingSpace
        //availibleWidth -= (itemsPerRow - 1) * 2 ///   Three spacers (there are 4 photos per row for iPhone), each 2 points.
        let widthPerItem = availibleWidth / itemsPerRow
        let size = CGSize(width: widthPerItem, height: widthPerItem)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //return sectionInsets
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4 ///horizontal line spacing, also 2 points, just like the availibleWidth
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.section)
        print(indexPath.item)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
}





extension NewHistoryViewController {
    func getData() {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            for item in items {
                let theFileName = (item as NSString).lastPathComponent
                let splits = theFileName.split(separator: "=")
                
                let categoryName = String(splits[0])
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyy"
                let dateFromString = dateFormatter.date(from: String(splits[0]))!
                
                if theFileName.contains(categoryName) {
                    if let image = loadImageFromDocumentDirectory(urlOfFile: folderURL, nameOfImage: theFileName) {
                        dictOfHists[dateFromString, default: [UIImage]()].append(image)
                    }
                }
            }
        } catch {
            print("error getting photos... \(error)")
        }
       
        var tempCategories = [Date]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        for dict in dictOfHists {
            let dictDate = dict.key
            tempCategories.append(dictDate)
        }
        tempCategories.sort(by: { $0.compare($1) == .orderedDescending})
        //print(tempCategories)
        for (index, theDate) in tempCategories.enumerated() {
            dictOfFormats[index] = theDate
        }
        print("how many categories:\(dictOfFormats.count)")
    }
    
    func loadImageFromDocumentDirectory(urlOfFile: URL,nameOfImage : String) -> UIImage? {
        let imageURL = urlOfFile.appendingPathComponent("\(nameOfImage)")
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
        return image
    }
    
    
    func convertDateToReadableString(theDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        let todaysDate = Date()
        let todaysDateAsString = dateFormatter.string(from: todaysDate)
        let yesterday = todaysDate.subtract(days: 1)
        let yesterdaysDateAsString = dateFormatter.string(from: yesterday!)
        
        let oneWeekAgo = todaysDate.subtract(days: 7)
        let yestYesterday = yesterday?.subtract(days: 1)
        let range = oneWeekAgo!...yestYesterday!
        
        let stringDate = dateFormatter.string(from: theDate)
        
        if stringDate == todaysDateAsString {
            return "Today"
        } else if stringDate == yesterdaysDateAsString {
            return "Yesterday"
        } else {
            if range.contains(theDate) {
                dateFormatter.dateFormat = "EEEE"
                return dateFormatter.string(from: theDate)
            } else {
                dateFormatter.dateFormat = "MMMM d',' yyyy"
                return dateFormatter.string(from: theDate)
            }
        }
    }
    
}

extension NSLayoutConstraint {
//debug constraints
    override public var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
