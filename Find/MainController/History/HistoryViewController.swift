//
//  HistoryViewController.swift
//  Find
//
//  Created by Andrew on 11/11/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum Const {
       static var closeCellHeight: CGFloat = 70
       static var openCellHeight: CGFloat = 260
       static var rowsCount = 20}
class HistoryViewController: UIViewController, UpdateValueDelegate{
    
    var categoryArray : [String] = [String]()
    var sortedCatagoryArray : [Date] = [Date]()
    var folderURL = URL(fileURLWithPath: "", isDirectory: true)
    var howManyItemsInEachCategory : [Int] = [Int]()
    
    var cellHeights: [CGFloat] = []
    var heightOfRow : CGFloat!
    var heightOfCurrentExpandedCell = CGFloat(0)
    var cellExpandedHeights : [Int: CGFloat] = [Int: CGFloat]()
    
    var dictOfHists = Dictionary<Date, Array<UIImage>>()
    var dictionaryOfHists: [Date : [UIImage]] = [:]
    
    var currentExpandedCell : Int = 0
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = Const.closeCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        getCategories()
    }
    
}
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func changeValue(height: CGFloat, row: Int) {
        heightOfCurrentExpandedCell = height
        cellExpandedHeights[row] = height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as HistoryTableViewCell = cell else {
            return
        }
        cell.fileURL = folderURL
        cell.date = sortedCatagoryArray[indexPath.row]
        cell.row = indexPath.row
        cell.historyFormats.indexPathOfCell = indexPath.row
        cell.historyFormats.dateTaken = sortedCatagoryArray[indexPath.row]
      //  cell.historyFormats.photos
        
        cell.delegate = self
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "idTableCell", for: indexPath) as! HistoryTableViewCell
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = Const.closeCellHeight
            if currentExpandedCell == indexPath.row {
                if let heightOfExpand = cellExpandedHeights[indexPath.row] {
                    height = heightOfExpand
                }
            }
        print("\(height) : indexPath: \(indexPath.row)")
        return height
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentExpandedCell == indexPath.row {
            currentExpandedCell = -1
            } else {
                currentExpandedCell = indexPath.row
            }
            tableView.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                tableView.beginUpdates()
                tableView.endUpdates()
            }, completion: nil)
        }
    
}
extension HistoryViewController {
    func getCategories() {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            for item in items {
       
                let theFileName = (item as NSString).lastPathComponent
                let splits = theFileName.split(separator: "=")
                
                let categoryName = String(splits[0])
                if !categoryArray.contains(categoryName) {
                    categoryArray.append(categoryName)
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMddyy"
                let dateFromString = dateFormatter.date(from: String(splits[0]))!
                
                if theFileName.contains(categoryName) {
                    if let image = loadImageFromDocumentDirectory(urlOfFile: folderURL, nameOfImage: theFileName) {
                        //dictOfHists[dateFromString] = [image]
                        dictOfHists[dateFromString, default: [UIImage]()].append(image)
                        ///This is an array of UIImages.
//                        let itemNew: [Date: [UIImage]] = [
//                            dateFromString: "new value"
//                        ]
//                        var existingItems = dictionaryOfHists[dateFromString] as? [Date: [UIImage]] ?? [Date: [UIImage]]()
//                        existingItems.ap
                    }
                }
                
                    
                
                
                

            }
        } catch {
            print("error getting photos... \(error)")
        }
       
        var tempCategories = [Date]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMddyy"
        for cat in categoryArray {
            let date = dateFormatter.date(from: cat)
            if let date = date {
                tempCategories.append(date)
            }
        }
        tempCategories.sort(by: { $0.compare($1) == .orderedDescending})
        for cat in tempCategories {
//            let newDate = dateFormatter.string(from: cat)
            sortedCatagoryArray.append(cat)
        }
        Const.rowsCount = sortedCatagoryArray.count
           print("cats:\(sortedCatagoryArray)")
        cellHeights = Array(repeating: Const.closeCellHeight, count: sortedCatagoryArray.count)
        

        print("dictionary of hists: \(dictOfHists)")
    }
    func loadImageFromDocumentDirectory(urlOfFile: URL,nameOfImage : String) -> UIImage? {
        let imageURL = urlOfFile.appendingPathComponent("\(nameOfImage)")
        guard let image = UIImage(contentsOfFile: imageURL.path) else { return nil }
        return image
    }
}
