//
//  ImageCell.swift
//  Find
//
//  Created by Zheng on 1/1/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet var shadowImageView: UIImageView!
    @IBOutlet var cacheImageView: UIImageView!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var imageView: UIImageView!
    
    // MARK: Selection

    @IBOutlet var highlightView: UIView!
    @IBOutlet var selectionImageView: UIImageView!
}
