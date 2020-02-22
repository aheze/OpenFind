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
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        print("hkjsdf")
//        contentView.layer.cornerRadius = 10
//    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                baseView.backgroundColor = UIColor(named: "TransparentWhite")
            } else {
                baseView.backgroundColor = UIColor(named: "PureBlank")
            }
        }
    }
}
