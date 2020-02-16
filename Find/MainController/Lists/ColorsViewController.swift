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


class ColorsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReturnColorNow, ReceiveColor {
    
    func receiveColor(name: String) {
        print("color recieved")
    }
    
    
    var colorName = "00AEEF"
    
    weak var colorDelegate: GetColorInfo?
    var colorArray: [String] = [String]()
    
    func updateInfo() {
        colorDelegate?.returnNewColor(colorName: colorName)
        //print("adf asd  as asfd ")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCellID", for: indexPath) as! SymbolCell
        return cell
    }
    
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
}

class ColorCell: UICollectionViewCell {

    var color = "" {
        didSet {
            self.backgroundColor = UIColor(hex: color)
        }
    }
    
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
