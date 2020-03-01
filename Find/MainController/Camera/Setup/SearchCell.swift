//
//  SearchCell.swift
//  Find
//
//  Created by Zheng on 2/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false

    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        //Exhibit A - We need to cache our calculation to prevent a crash.
//        if !isHeightCalculated {
//            setNeedsLayout()
//            layoutIfNeeded()
//            let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//            var newFrame = layoutAttributes.frame
//            newFrame.size.width = CGFloat(ceilf(Float(size.width)))
//            layoutAttributes.frame = newFrame
//            isHeightCalculated = true
//        }
//        return layoutAttributes
//    }
    
}
