//
//  ListsContentView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/29/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

class ListsContentView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var headerView: ButtonView!
    
    @IBOutlet var headerViewHeightC: NSLayoutConstraint!
    @IBOutlet var headerStackView: UIStackView!
    
    @IBOutlet var headerStackViewTopC: NSLayoutConstraint!
    @IBOutlet var headerStackViewRightC: NSLayoutConstraint!
    @IBOutlet var headerStackViewBottomC: NSLayoutConstraint!
    @IBOutlet var headerStackViewLeftC: NSLayoutConstraint!
    
    @IBOutlet var headerLeftView: UIView!
    @IBOutlet var headerLeftViewWidthC: NSLayoutConstraint!
    @IBOutlet var headerImageView: UIImageView!
    
    @IBOutlet var headerSelectionIconView: SelectionIconView!
    @IBOutlet var headerTitleLabel: UILabel!
    @IBOutlet var headerDescriptionLabel: UILabel!

    @IBOutlet var containerView: UIView!
    @IBOutlet var containerButtonView: ButtonView!
    @IBOutlet var chipsContainerView: UIView!
    
    @IBOutlet var chipsContainerViewTopC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewRightC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewBottomC: NSLayoutConstraint!
    @IBOutlet var chipsContainerViewLeftC: NSLayoutConstraint!
    
    var tapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ListsContentView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setup()
    }

    func setup() {
        let c = ListsCellConstants.self
        
        clipsToBounds = true
        
        /// allow button view to be pressed
        headerStackView.isUserInteractionEnabled = false

        headerStackView.backgroundColor = .clear
        headerLeftView.backgroundColor = .clear
        chipsContainerView.backgroundColor = .clear
        
        headerLeftViewWidthC.constant = c.headerLeftWidth
        headerSelectionIconView.configuration = .listsSelection
        
        headerImageView.setIconFont(font: c.headerDescriptionFont)
        headerTitleLabel.font = c.headerTitleFont
        headerDescriptionLabel.font = c.headerDescriptionFont
        headerDescriptionLabel.alpha = 0.75
        headerImageView.clipsToBounds = false
        
        headerViewHeightC.constant = c.headerTitleFont.lineHeight
            + c.headerEdgeInsets.top
            + c.headerEdgeInsets.bottom
        
        headerStackViewTopC.constant = c.headerEdgeInsets.top
        headerStackViewRightC.constant = c.headerEdgeInsets.right
        headerStackViewBottomC.constant = c.headerEdgeInsets.bottom
        headerStackViewLeftC.constant = c.headerEdgeInsets.left
        
        chipsContainerViewTopC.constant = c.contentEdgeInsets.top
        chipsContainerViewRightC.constant = c.contentEdgeInsets.right
        chipsContainerViewBottomC.constant = c.contentEdgeInsets.bottom
        chipsContainerViewLeftC.constant = c.contentEdgeInsets.left
        
        headerStackView.setCustomSpacing(c.headerImageRightPadding, after: headerImageView)
        headerStackView.spacing = c.headerTextSpacing
        
        headerView.shouldFade = false
        headerView.tapped = { [weak self] in
            self?.tapped?()
        }
        headerView.touchedDown = { [weak self] down in
            self?.touchedDown(down)
        }
        
        containerButtonView.shouldFade = false
        containerButtonView.tapped = { [weak self] in
            self?.tapped?()
        }
        containerButtonView.touchedDown = { [weak self] down in
            self?.touchedDown(down)
        }
    }
    
    func touchedDown(_ down: Bool) {
        if down {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.8
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
    }
}

extension ListsContentView {
    func configureData(list: List) {
        let color = UIColor(hex: list.color)
        headerView.backgroundColor = color
        headerImageView.image = UIImage(systemName: list.icon)
        headerTitleLabel.text = list.displayedTitle
        headerDescriptionLabel.text = list.description
        layer.cornerRadius = ListsCellConstants.cornerRadius
        
        if color.isLight {
            headerImageView.tintColor = ListsCellConstants.titleColorBlack
            headerTitleLabel.textColor = ListsCellConstants.titleColorBlack
            headerDescriptionLabel.textColor = ListsCellConstants.descriptionColorBlack
        } else {
            headerImageView.tintColor = ListsCellConstants.titleColorWhite
            headerTitleLabel.textColor = ListsCellConstants.titleColorWhite
            headerDescriptionLabel.textColor = ListsCellConstants.titleColorWhite
        }
    }

    func configureSelection(selected: Bool, modelSelecting: Bool) {
        isUserInteractionEnabled = !modelSelecting
        if modelSelecting {
            headerSelectionIconView.isHidden = false
            headerSelectionIconView.alpha = 1
            if selected {
                headerSelectionIconView.setState(.selected)
            } else {
                headerSelectionIconView.setState(.empty)
            }
        } else {
            headerSelectionIconView.isHidden = true
            headerSelectionIconView.alpha = 0
            headerSelectionIconView.setState(.empty)
        }
    }
    
    /// tapped parameter = focus or don't focus first word
    func addChipViews(with list: List, chipFrames: [ListFrame.ChipFrame], tapped: ((Bool) -> Void)? = nil) {
        chipsContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        let color = UIColor(hex: list.color)
        
        for chipFrame in chipFrames {
            let chipView = ListChipView(type: chipFrame.chipType)
            chipView.frame = chipFrame.frame
            chipView.label.text = chipFrame.string
            chipView.color = color
            chipView.setColors()
            
            switch chipFrame.chipType {
            case .word:
                chipView.backgroundView.backgroundColor = ListsCellConstants.chipBackgroundColor
                if let tapped = tapped {
                    chipView.tapped = {
                        tapped(false)
                    }
                }
            case .wordsLeft:
                chipView.backgroundView.backgroundColor = color.withAlphaComponent(0.1)
                if let tapped = tapped {
                    chipView.tapped = {
                        tapped(false)
                    }
                }
            case .addWords:
                chipView.backgroundView.backgroundColor = color.withAlphaComponent(0.1)
                if let tapped = tapped {
                    chipView.tapped = {
                        tapped(true)
                    }
                }
            }
            chipsContainerView.addSubview(chipView)
        }
    }
}
