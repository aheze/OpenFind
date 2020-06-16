//
//  ListCollectionCell.swift
//  Find
//
//  Created by Andrew on 1/20/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class ListCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var nameDescription: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var contentsList: UILabel!
    
    @IBOutlet weak var highlightView: UIView!
    
    @IBOutlet weak var checkmarkView: UIImageView!
    
    @IBOutlet weak var tapHighlightView: UIView!
    //    var shouldSelect = false
    
    //    override func awakeFromNib() {
//        super.awakeFromNib()
//        print("hkjsdf")
//        contentView.layer.cornerRadius = 10
//    }
    
//    override var isSelected: Bool {
//        didSet {
//            if isSelected == true {
//                UIView.animate(withDuration: 0.1, animations: {
//                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//                })
////                checkmarkView.alpha = 1
////                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
//                    UIView.animate(withDuration: 0.1, animations: {
//                        self.highlightView.alpha = 1
//                        self.checkmarkView.alpha = 1
//                        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
////                        self.layoutIfNeeded()
//                    })
////                })
//            } else {
//                print("NOT SELLLELEL")
//                UIView.animate(withDuration: 0.1, animations: {
//                    self.highlightView.alpha = 0
//                    self.checkmarkView.alpha = 0
//                    self.transform = CGAffineTransform.identity
////                    self.layoutIfNeeded()
//                })
////                highlightView.alpha = 0
////                checkmarkView.alpha = 0
//            }
//        }
//    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                print("HIGH")
                tapHighlightView.alpha = 1
//                baseView.backgroundColor = UIColor(named: "TransparentWhite")
            } else {
                tapHighlightView.alpha = 0
//                baseView.backgroundColor = UIColor(named: "PureBlank")
            }
        }
    }
}
