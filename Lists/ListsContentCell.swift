//
//  ListsContentCell.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/8/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsContentCell: UICollectionViewCell {
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerContentView: UIView!
    
    @IBOutlet var headerContentViewTopC: NSLayoutConstraint!
    @IBOutlet var headerContentViewRightC: NSLayoutConstraint!
    @IBOutlet var headerContentViewBottomC: NSLayoutConstraint!
    @IBOutlet var headerContentViewLeftC: NSLayoutConstraint!
    
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerImageViewRightC: NSLayoutConstraint!
    
    @IBOutlet var headerStackView: UIStackView!
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var headerDescriptionLabel: UILabel!

    @IBOutlet var containerView: UIView!
    @IBOutlet var chipsContainerView: UIView!
    
    @IBOutlet var chipsContainerViewTopC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewRightC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewBottomC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewLeftC: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let c = ListsCellConstants.self
        
        headerContentView.backgroundColor = .clear
        chipsContainerView.backgroundColor = .clear
        
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
        
        chipsContainerViewTopC.constant = c.contentEdgeInsets.top
        chipsContainerViewRightC.constant = c.contentEdgeInsets.right
        chipsContainerViewBottomC.constant = c.contentEdgeInsets.bottom
        chipsContainerViewLeftC.constant = c.contentEdgeInsets.left
        
        headerImageViewRightC.constant = c.headerImageRightPadding
        headerStackView.spacing = c.headerTextSpacing
    }
}

class ListChipView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.layer.cornerRadius = ListsCellConstants.chipCornerRadius
        addSubview(backgroundView)
        return backgroundView
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.font = ListsCellConstants.chipFont
        label.textAlignment = .center
        addSubview(label)
        return label
    }()
    
    private func commonInit() {
        backgroundColor = .clear
        _ = backgroundView
        _ = label
    }
}
