//
//  PhotosCollectionHeader.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/30/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class PhotosCollectionHeader: UICollectionReusableView {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelLeftC: NSLayoutConstraint!
    @IBOutlet var labelRightC: NSLayoutConstraint! /// space between label right and image right
    @IBOutlet var labelTopC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let c = PhotosHeaderConstants.self
        
        label.textColor = .white
        label.font = c.font
        labelLeftC.constant = c.labelLeftPadding
        labelRightC.constant = c.labelRightPadding
        labelTopC.constant = c.labelTopPadding
        
        imageView.image = UIImage(named: "HeaderShadow")
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        isUserInteractionEnabled = false
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        if let attributes = layoutAttributes as? PhotosSectionHeaderLayoutAttributes {
            var startTitle = ""
            var endTitle: String?
            if let firstCategorization = attributes.encompassingCategorizations.first {
                startTitle = firstCategorization.getTitle()
            }
            if let endCategorization = attributes.encompassingCategorizations.last {
                endTitle = endCategorization.getTitle()
            }
            
            if let endTitle = endTitle, startTitle != endTitle {
                let title = "\(startTitle) - \(endTitle)"
                label.text = title
            } else {
                label.text = startTitle
            }
            
            alpha = attributes.isVisible ? 1 : 0
        }
    }
}
