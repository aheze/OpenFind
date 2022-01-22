//
//  ListsContentCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class ListsContentCell: UICollectionViewCell {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerContentView: UIView!
    
    @IBOutlet weak var headerContentViewTopC: NSLayoutConstraint!
    @IBOutlet weak var headerContentViewRightC: NSLayoutConstraint!
    @IBOutlet weak var headerContentViewBottomC: NSLayoutConstraint!
    @IBOutlet weak var headerContentViewLeftC: NSLayoutConstraint!
    
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerImageViewRightC: NSLayoutConstraint!
    
    @IBOutlet weak var headerStackView: UIStackView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDescriptionLabel: UILabel!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerChipsView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let c = ListsCellConstants.self
        
        headerContentView.backgroundColor = .clear
        headerImageView.tintColor = c.titleColor
        headerTitleLabel.textColor = c.titleColor
        headerDescriptionLabel.textColor = c.descriptionColor
        
        headerImageView.contentMode = .center
        headerImageView.preferredSymbolConfiguration = .init(font: c.headerDescriptionFont)
        headerTitleLabel.font = c.headerTitleFont
        headerDescriptionLabel.font = c.headerDescriptionFont
        
        headerContentViewTopC.constant = c.headerEdgeInsets.top
        headerContentViewRightC.constant = c.headerEdgeInsets.right
        headerContentViewBottomC.constant = c.headerEdgeInsets.bottom
        headerContentViewLeftC.constant = c.headerEdgeInsets.left
        
        headerImageViewRightC.constant = c.headerImageRightPadding
        headerStackView.spacing = c.headerTextSpacing
    }
}
