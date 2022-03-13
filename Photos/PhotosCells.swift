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
    
    @IBOutlet var overlayView: UIView!
    @IBOutlet weak var overlayGradientImageView: UIImageView!
    @IBOutlet var overlayStarImageView: UIImageView!
    @IBOutlet var overlayStarImageViewLeftC: NSLayoutConstraint!
    @IBOutlet var overlayStarImageViewBottomC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFill
        overlayView.isUserInteractionEnabled = false
        buttonView.tapped = { [weak self] in
            self?.tapped?()
        }
        
        /// configure constants
        let c = PhotosCellConstants.self
        overlayView.backgroundColor = .clear
        overlayStarImageView.tintColor = c.starTintColor
        overlayStarImageView.setIconFont(font: c.starFont)
        overlayStarImageViewLeftC.constant = c.starLeftPadding
        overlayStarImageViewBottomC.constant = c.starBottomPadding
        
    }
}

/// the results photos cell
class PhotosResultsCell: UICollectionViewCell {
    var highlightsViewController: HighlightsViewController?
    var representedAssetIdentifier: String?
    
    var tapped: (() -> Void)?
    var appeared: (() -> Void)?
    var disappeared: (() -> Void)?
    @IBOutlet var buttonView: ButtonView!
    
    /// `imageView` on left, `rightStackView` on right
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var stackViewTopC: NSLayoutConstraint!
    @IBOutlet var stackViewRightC: NSLayoutConstraint!
    @IBOutlet var stackViewBottomC: NSLayoutConstraint!
    @IBOutlet var stackViewLeftC: NSLayoutConstraint!
    
    /// image on the left
    
    @IBOutlet weak var leftContainerView: UIView!
    @IBOutlet var leftContainerViewWidthC: NSLayoutConstraint!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var leftOverlayView: UIView!
    @IBOutlet weak var leftOverlayGradientImageView: UIImageView!
    @IBOutlet var leftOverlayStarImageView: UIImageView!
    @IBOutlet var leftOverlayStarImageViewLeftC: NSLayoutConstraint!
    @IBOutlet var leftOverlayStarImageViewBottomC: NSLayoutConstraint!
    
    /// vertical stack view on right
    @IBOutlet var rightStackView: UIStackView!
    
    /// horizontal stack view, contains title + results
    @IBOutlet var rightTopStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var resultsLabel: PaddedLabel!
    
    @IBOutlet var descriptionContainerView: UIView!
    @IBOutlet var descriptionHighlightsContainerView: UIView!
    @IBOutlet var descriptionTextView: UITextView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resultsLabel.layer.cornerRadius = resultsLabel.bounds.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        stackView.isUserInteractionEnabled = false
        resultsLabel.clipsToBounds = true
        
        descriptionTextView.contentInset = .zero
        descriptionTextView.textContainerInset = .zero
        descriptionTextView.backgroundColor = .clear
        
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
        leftContainerViewWidthC.constant = c.leftContainerWidth
        
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
        
        /// configure constants for the image
        leftOverlayView.backgroundColor = .clear
        leftOverlayStarImageView.tintColor = PhotosCellConstants.starTintColor
        leftOverlayStarImageView.setIconFont(font: PhotosCellConstants.starFont)
        leftOverlayStarImageViewLeftC.constant = PhotosCellConstants.starLeftPadding
        leftOverlayStarImageViewBottomC.constant = PhotosCellConstants.starBottomPadding
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disappeared?()
    }
}
