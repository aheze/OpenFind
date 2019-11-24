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
    
    var historyFormats: HistoryFormat = HistoryFormat()
    var row: Int?
    var itemCount = 0
    var photoArray : [UIImage]? = [UIImage]()
    var date : Date = Date() {
        didSet {
            print("date: \(date), row: \(row)")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMddyy"
            stringDate = dateFormatter.string(from: date)
            convertDateToReadableString(theDate: date)
            getCategories()
        }
    }
    var stringDate = ""
    var size = CGSize(width: 1, height: 1)
    var heightOfCell : CGFloat!
    var fileURL : URL = URL(fileURLWithPath: "")
    
    ///collection view stuff
    let sectionInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    let itemsPerRow : CGFloat = 4
    
    @IBOutlet weak var paddedView: UIView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let newHeight : CGFloat = collectionView.collectionViewLayout.collectionViewContentSize.height
        var frame : CGRect! = collectionView.frame
        frame.size.height = newHeight
        delegate?.changeValue(height: newHeight + 65, row: self.row!)
        itemCount = Int(Darwin.round(newHeight / 150.0)) + 2
        
    }
    override func awakeFromNib() {
        paddedView.clipsToBounds = true
        paddedView.layer.cornerRadius = 12
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.layer.cornerRadius = 6
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        collectionView.reloadData()
        
    }
    
}

extension HistoryTableViewCell {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
                collectionView.removeObserver(self, forKeyPath: "contentSize")

    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "idImageCell", for: indexPath) as! CollectionViewPhotoCell
        cell.imageView.image = photoArray?[indexPath.item]
        return cell
        
    }
 
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availibleWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availibleWidth / itemsPerRow
        size = CGSize(width: widthPerItem, height: widthPerItem)
        print("size:::: \(size)")
        //let sizee = CGSize(width: 50, height: 50)
        return CGSize(width: widthPerItem, height: widthPerItem)
        //return sizee
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
        
    }

}

extension HistoryTableViewCell {
    /// get categories,
    /// convert the date into a string, like "Today" or "Monday, January 1",
    /// loadImageFromDir
    func loadImageFromDocumentDirectory(urlOfFile: URL,nameOfImage : String) -> UIImage? {
        let imageURL = fileURL.appendingPathComponent("\(nameOfImage)")
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
        return image
    }
    func getCategories() {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: fileURL.path)
            for item in items {
                
                let theFileName = (item as NSString).lastPathComponent
                if theFileName.contains(stringDate) {
                    if let image = loadImageFromDocumentDirectory(urlOfFile: fileURL, nameOfImage: theFileName) {
                    photoArray!.append(image)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
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
