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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorName = colorArray[indexPath.item]
        colorDelegate?.returnNewColor(colorName: colorName)
        selectedPath = indexPath.item
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        colorName = colorArray[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! ColorCell
        cell.color = colorArray[indexPath.item]
        if selectedPath == indexPath.item {
            cell.checkMarkView.isHidden = false
        } else {
            cell.checkMarkView.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(5)
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
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
            let contentLength = bounds.size.width
            let halfContL = contentLength / 2
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: halfContL, y: halfContL), radius: CGFloat(halfContL), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath

            shapeLayer.fillColor = UIColor(hexString: color).cgColor
            contentView.layer.addSublayer(shapeLayer)
            contentView.bringSubviewToFront(checkMarkView)
        }
    }
    
    var overlayView = UIView()
    
    override var isSelected: Bool {
        didSet {
            if (isSelected) {
                checkMarkView.isHidden = false
            } else {
                checkMarkView.isHidden = true
            }
        }
    }
}
