//
//  ListCollectionCell.swift
//  Find
//
//  Created by Andrew on 1/20/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class ListCollectionCell: UICollectionViewCell {
    @IBOutlet var baseView: UIView!
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var nameDescription: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var contentsList: UILabel!
    
    @IBOutlet var highlightView: UIView!
    
    @IBOutlet var checkmarkView: UIImageView!
    
    @IBOutlet var tapHighlightView: UIView!

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                tapHighlightView.alpha = 1
            } else {
                tapHighlightView.alpha = 0
            }
        }
    }
}
