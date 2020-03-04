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


class ColorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReceiveColor, ScrolledToColors {
    
    
    func scrolledHere() {
        print("SCROLL")
        if let row = colorArray.firstIndex(of: colorName) {
            let indP = IndexPath(item: row, section: 0)
            print(indP)
            selectedPath = row
            collectionView.selectItem(at: indP, animated: false, scrollPosition: .centeredVertically)
        }
    }
    func receiveColor(name: String) {
        print("color recieved")
        colorName = name
    }
    
    private let sectionInsets = UIEdgeInsets(top: 8.0,
    left: 8.0,
    bottom: 8.0,
    right: 8.0)
    
    var colorName = "#579f2b"
    var selectedPath = -1
    
    weak var colorDelegate: GetColorInfo?
    var colorArray: [String] = [
        "#eb2f06","#e55039","#f7b731","#fed330","#78e08f",
        "#fc5c65","#fa8231","#f6b93b","#b8e994","#2bcbba",
        "#ff6348","#b71540","#579f2b","#d1d8e0","#778ca3",
        "#e84393","#a55eea","#5352ed","#70a1ff","#40739e",
        "#45aaf2","#2d98da","#00aeef","#4b6584","#0a3d62"]
//        ["#eb2f06","#e55039","#f7b731","#fed330","#78e08f","#fc5c65","#fa8231","#f6b93b","#b8e994","#2bcbba","#a55eea","#b71540","#079992","#d1d8e0","#778ca3","#45aaf2","#2d98da","#00aeef","#4b6584","#0a3d62"]
    
    //["#eb2f06","#e55039","#f7b731","#fed330","#78e08f”,"#fc5c65","#fa8231","#f6b93b","#b8e994","#2bcbba","#ff6348" ,"#b71540","#079992","#d1d8e0","#778ca3","#a55eea","#5352ed","#70a1ff","#f1f2f6","#e84393","#45aaf2","#2d98da","#00aeef","#4b6584","#0a3d62"]
    
    
  
    
//    func updateInfo() {
//        if colorName == "" {
//            colorName = "#00aeef"
//        }
//        print("Return color. Color name: \(colorName)")
//        colorDelegate?.returnNewColor(colorName: colorName)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorName = colorArray[indexPath.item]
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! ColorCell
        print("select")
        colorDelegate?.returnNewColor(colorName: colorName)
        selectedPath = indexPath.item
       // cell.checkMarkView.isHidden = false
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        colorName = colorArray[indexPath.item]
        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! ColorCell
        
        print("deselect")
       // cell.checkMarkView.isHidden = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! ColorCell
        cell.color = colorArray[indexPath.item]
        if selectedPath == indexPath.item {
            cell.checkMarkView.isHidden = false
        } else {
            cell.checkMarkView.isHidden = true
        }
        //cell.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
       // cell.sizeForItems = collectionView.siz
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(5)
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        print("width: \(widthPerItem)")
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
}

class ColorCell: UICollectionViewCell {

    @IBOutlet weak var checkMarkView: UIImageView!
    //var sizeForItems = CGFloat(0)
    var color = "" {
        didSet {
            print(color)
            var contentLength = bounds.size.width
            var halfContL = contentLength / 2
            print("content height for color cell: \(contentLength)")
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: halfContL, y: halfContL), radius: CGFloat(halfContL), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath

            //change the fill color
            shapeLayer.fillColor = UIColor(hexString: color).cgColor
            //you can change the stroke color
            //shapeLayer.strokeColor = UIColor.red.cgColor
            //you can change the line width
            //shapeLayer.lineWidth = 30

            contentView.layer.addSublayer(shapeLayer)
            contentView.bringSubviewToFront(checkMarkView)
            //self.backgroundColor = UIColor(hex: color)
        }
    }
    
    var overlayView = UIView()
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                checkMarkView.isHidden = false
//                let length = bounds.size.width
//
//                //var newView = UIView()
//                overlayView.frame = (CGRect(x: 0, y: 0, width: length, height: length))
//                overlayView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//                overlayView.layer.cornerRadius = 10
//                //overlayView.tag = 010101
//                contentView.addSubview(<#T##view: UIView##UIView#>)

            } else {
                checkMarkView.isHidden = true
               // if let newView = contentView.viewWithTag(010101) {
//                    overlayView.removeFromSuperview()
               // }
            }
        }
    }
    
}

//extension UIColor {
//    public convenience init?(hex: String) {
//        let r, g, b, a: CGFloat
//
//        if hex.hasPrefix("#") {
//            let start = hex.index(hex.startIndex, offsetBy: 1)
//            let hexColor = String(hex[start...])
//
//            if hexColor.count == 8 {
//                let scanner = Scanner(string: hexColor)
//                var hexNumber: UInt64 = 0
//
//                if scanner.scanHexInt64(&hexNumber) {
//                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
//                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
//                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
//                    a = CGFloat(hexNumber & 0x000000ff) / 255
//
//                    self.init(red: r, green: g, blue: b, alpha: a)
//                    return
//                }
//            }
//        }
//
//        return nil
//    }
//}
