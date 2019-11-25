//
//  HistoryTableViewCell.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

protocol UpdateValueDelegate: class {
    func changeValue(height: CGFloat, row: Int)
}

///The tableview cell which contains the collection view,
///the Date extension for adding and subtracting,
///getCategories,
///loadImageFromDocuentDirectory,
///convertToReadableString
class HistoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: UpdateValueDelegate?
    
    //var historyFormats: HistoryFormat = HistoryFormat()
    var row: Int = 0///checked
    //var itemCount = 0///checked
    var photoArray : [UIImage]? = [UIImage]()///checked
    var date : Date = Date() {///checked
        didSet {
            print("date: \(date), row: \(row)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyy"
            stringDate = dateFormatter.string(from: date)
            convertDateToReadableString(theDate: date)
            //getCategories()
        }
    }
    var testNumber = 0
    var stringDate = "" ///checked
    //var size = CGSize(width: 1, height: 1)
    ///fixed
    //var heightOfCell : CGFloat!
   /// fixed
   // var fileURL : URL = URL(fileURLWithPath: "")
    ///fixed

    ///collection view stuff
    //let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let itemsPerRow : CGFloat = 4
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var paddedView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reusing...")
        photoArray = nil
    }
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//            collectionView.layoutIfNeeded()
//            collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width , height: 1)
//            return collectionView.collectionViewLayout.collectionViewContentSize
//    }
//    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
//
//        self.layoutIfNeeded()
//        let contentSize = self.collectionView.collectionViewLayout.collectionViewContentSize
//        if self.collectionView.numberOfItems(inSection: 0) < 4 {
//            return CGSize(width: contentSize.width, height: 120) // Static height if colview is not fitted properly.
//        }
//
//        return CGSize(width: contentSize.width, height: contentSize.height + 20) // 20 is the margin of the collectinview with top and bottom
//    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        let newHeight : CGFloat = collectionView.collectionViewLayout.collectionViewContentSize.height
//        var frame : CGRect! = collectionView.frame
//        frame.size.height = newHeight
//        delegate?.changeValue(height: newHeight + 65, row: self.row)
//       // itemCount = Int(Darwin.round(newHeight / 150.0)) + 2
//
//    }
    override func awakeFromNib() {
        paddedView.clipsToBounds = true
        paddedView.layer.cornerRadius = 12
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 6
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
       // collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        collectionView.reloadData()
        
    }
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        layoutIfNeeded()
//    }
//    deinit {
//        collectionView.removeObserver(self, forKeyPath: "contentSize")
//    }
    
}

extension HistoryTableViewCell {
    
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        collectionView.removeObserver(self, forKeyPath: "contentSize")
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idImageCell", for: indexPath) as! CollectionViewPhotoCell
        
        print("testNumber-\(testNumber)")
        testNumber += 1
        print("indexPath-\(indexPath.item)")
        print("photoArray-\(photoArray!.count)")
        cell.imageView.image = photoArray![indexPath.item]
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        var availibleWidth = collectionView.frame.width - paddingSpace
        availibleWidth -= (itemsPerRow - 1) * 2 ///   Three spacers (there are 4 photos per row for iPhone), each 2 points.
        let widthPerItem = availibleWidth / itemsPerRow
        let size = CGSize(width: widthPerItem, height: widthPerItem)
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //return sectionInsets
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2 ///horizontal line spacing, also 2 points, just like the availibleWidth
        
    }

}

extension HistoryTableViewCell {
    /// convert the date into a string, like "Today" or "Monday, January 1"
    func convertDateToReadableString(theDate: Date) {
        print("readableString")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        let todaysDate = Date()
        let todaysDateAsString = dateFormatter.string(from: todaysDate)
        let yesterday = todaysDate.subtract(days: 1)
        let yesterdaysDateAsString = dateFormatter.string(from: yesterday!)
        
        let oneWeekAgo = todaysDate.subtract(days: 7)
        let yestYesterday = yesterday?.subtract(days: 1)
        let range = oneWeekAgo!...yestYesterday!
        
        if stringDate == todaysDateAsString {
            todayLabel.text = "Today"
        } else if stringDate == yesterdaysDateAsString {
            todayLabel.text = "Yesterday"
        } else {
            if range.contains(date) {
                dateFormatter.dateFormat = "EEEE"
                todayLabel.text = dateFormatter.string(from: date)
                print("last week")
            } else {
                dateFormatter.dateFormat = "MMMM d',' yyyy"
                todayLabel.text = dateFormatter.string(from: date)
                print("before last week")
            }
        }
    }
}

extension Date {
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let comp = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: comp, to: self)
    }
    
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
}
