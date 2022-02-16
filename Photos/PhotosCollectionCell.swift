//
//  PhotosCollectionCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class PhotosCollectionCell: UICollectionViewCell {
    var representedAssetIdentifier: String?
    
    var tapped: (() -> Void)?
    @IBOutlet weak var buttonView: ButtonView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonView.tapped = { [weak self] in
            self?.tapped?()
        }
    }
}
