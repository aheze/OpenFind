//
//  HPhotoCell.swift
//  Find
//
//  Created by Andrew on 11/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class HPhotoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heartView: UIImageView!
    @IBOutlet weak var cachedView: UIImageView!
    @IBOutlet weak var checkmarkView: UIImageView!
    
    @IBOutlet weak var pinkTintView: UIView!
    @IBOutlet weak var highlightView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkView.alpha = 0
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        pinkTintView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
        highlightView.snp.makeConstraints { (make) in
            make.edges.equalTo(imageView)
        }
    }

}
