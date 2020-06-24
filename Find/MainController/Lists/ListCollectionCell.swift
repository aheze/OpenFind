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
