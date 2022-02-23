//
//  PhotosCells.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/15/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

/// the main photos cell
class PhotosCollectionCell: UICollectionViewCell {
    var representedAssetIdentifier: String?
    
    var tapped: (() -> Void)?
    @IBOutlet var buttonView: ButtonView!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonView.tapped = { [weak self] in
            self?.tapped?()
        }
        imageView.contentMode = .scaleAspectFill
    }
}

/// the results photos cell
class PhotosResultsCell: UICollectionViewCell {
    var representedAssetIdentifier: String?
    
    var tapped: (() -> Void)?
    @IBOutlet var buttonView: ButtonView!
    
    /// `imageView` on left, `rightStackView` on right
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewTopC: NSLayoutConstraint!
    @IBOutlet var stackViewRightC: NSLayoutConstraint!
    @IBOutlet var stackViewBottomC: NSLayoutConstraint!
    @IBOutlet var stackViewLeftC: NSLayoutConstraint!
    
    /// image on the left
    @IBOutlet var imageView: UIImageView!
    
    /// vertical stack view on right
    @IBOutlet var rightStackView: UIStackView!
    
    /// horizontal stack view, contains title + results
    @IBOutlet var rightTopStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var resultsLabel: PaddedLabel!
    
    @IBOutlet var descriptionContainerView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resultsLabel.layer.cornerRadius = resultsLabel.bounds.height / 2
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonView.tapped = { [weak self] in
            self?.tapped?()
        }
        
        imageView.contentMode = .scaleAspectFill
        descriptionTextView.isEditable = false
        
        let c = PhotosResultsCellConstants.self
        resultsLabel.backgroundColor = c.resultsLabelBackgroundColor
        resultsLabel.textInsets = c.resultsLabelEdgeInsets
        stackView.spacing = c.cellSpacing
        rightStackView.spacing = c.cellSpacing
        rightTopStackView.spacing = c.cellSpacing
        
        layer.cornerRadius = c.cornerRadius
        
        stackViewTopC.constant = c.cellPadding
        stackViewRightC.constant = c.cellPadding
        stackViewBottomC.constant = c.cellPadding
        stackViewLeftC.constant = c.cellPadding
        
        imageView.layer.cornerRadius = c.imageCornerRadius
        
        titleLabel.font = c.titleFont
        resultsLabel.font = c.resultsFont
        descriptionTextView.font = c.descriptionFont
        
        titleLabel.textColor = c.titleTextColor
        resultsLabel.textColor = c.resultsLabelTextColor
        descriptionTextView.textColor = c.descriptionTextColor
    }
}
