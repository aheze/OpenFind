//
//  ListsDetailVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import UIKit

extension ListsDetailViewController {
    func setup() {
        let colorPickerViewController = ColorPickerViewController(model: headerTopRightColorPickerModel)
        addChildViewController(colorPickerViewController, in: headerTopRightView)
        
        setupViews()
        applyConstants()
        loadListContents()
        updateTableViewHeightConstraint()
        
        scrollView.alwaysBounceVertical = true
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
    }
    
    func loadListContents() {
        headerTopLeftImageView.image = UIImage(systemName: list.image)
        
        let color = UIColor(hex: list.color)
        headerTopRightColorPickerModel.color = color
        headerView.backgroundColor = color
        
        wordsTopView.backgroundColor = color.withAlphaComponent(0.1)
        wordsTopLeftLabel.textColor = color
        wordsTopCenterLabel.textColor = color
        wordsTopRightImageView.tintColor = color
        
        headerTopCenterTextField.text = list.name
        headerBottomTextField.text = list.desc
    }
    
    func setupViews() {
        view.backgroundColor = .secondarySystemBackground
        
        headerStackView.backgroundColor = .clear
        headerTopView.backgroundColor = .clear
        headerBottomTextField.backgroundColor = .clear
        
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        containerStackView.backgroundColor = .clear
        
        headerTopLeftImageView.tintColor = .white
        headerTopLeftImageView.contentMode = .center
        headerTopLeftImageView.preferredSymbolConfiguration = .init(font: ListsDetailConstants.headerTitleFont)
        
        wordsTopLeftView.backgroundColor = .clear
        wordsTopCenterView.backgroundColor = .clear
        wordsTopRightView.backgroundColor = .clear
    }
    
    func applyConstants() {
        let c = ListsDetailConstants.self
        
        containerStackView.spacing = c.containerSpacing
        
        headerTopViewHeightC.constant = c.headerTitleFont.lineHeight
            + c.headerTitleEdgeInsets.top
            + c.headerTitleEdgeInsets.bottom
        
        headerBottomViewHeightC.constant = c.headerDescriptionFont.lineHeight
        + c.headerDescriptionEdgeInsets.top
        + c.headerDescriptionEdgeInsets.bottom
        
        headerTopLeftViewRightC.constant = c.headerSpacing
        headerTopRightViewLeftC.constant = c.headerSpacing
        headerStackView.spacing = c.headerSpacing
        
        headerView.clipsToBounds = true
        headerView.layer.cornerRadius = ListsDetailConstants.headerCornerRadius
        
        headerTopLeftView.backgroundColor = c.headerInnerViewBackgroundColor
        headerTopCenterView.backgroundColor = c.headerInnerViewBackgroundColor
        headerTopRightView.backgroundColor = c.headerInnerViewBackgroundColor
        headerBottomView.backgroundColor = c.headerInnerViewBackgroundColor
        
        headerTopLeftView.clipsToBounds = true
        headerTopCenterView.clipsToBounds = true
        headerTopRightView.clipsToBounds = true
        headerBottomView.clipsToBounds = true
        
        headerTopLeftView.layer.cornerRadius = c.headerInnerViewCornerRadius
        headerTopCenterView.layer.cornerRadius = c.headerInnerViewCornerRadius
        headerTopRightView.layer.cornerRadius = c.headerInnerViewCornerRadius
        headerBottomView.layer.cornerRadius = c.headerInnerViewCornerRadius
        
        containerViewTopC.constant = c.contentInset.top
        containerViewRightC.constant = c.contentInset.right
        containerViewBottomC.constant = c.contentInset.bottom
        containerViewLeftC.constant = c.contentInset.left
        
        headerTopCenterTextField.font = c.headerTitleFont
        headerTopCenterTextField.textAlignment = .center
        headerTopCenterTextField.textColor = c.headerTextColor
        headerTopCenterTextField.attributedPlaceholder = NSAttributedString(
            string: "Title",
            attributes: [NSAttributedString.Key.foregroundColor: c.headerPlaceholderColor]
        )
        
        headerBottomTextField.font = c.headerDescriptionFont
        headerBottomTextField.textAlignment = .center
        headerBottomTextField.textColor = c.headerTextColor
        headerBottomTextField.attributedPlaceholder = NSAttributedString(
            string: "Description (Optional)",
            attributes: [NSAttributedString.Key.foregroundColor: c.headerPlaceholderColor]
        )
        
        
        // MARK: - Words
        wordsView.clipsToBounds = true
        wordsView.layer.cornerRadius = c.wordsCornerRadius
        
        /// left edit button
        wordsTopLeftLabel.font = c.wordsHeaderActionsFont
        wordsTopLeftLabel.textInsets = c.wordsHeaderActionsEdgeInsets
        
        wordsTopCenterLabel.font = c.wordsHeaderTitleFont
        wordsTopCenterLabel.textInsets = c.wordsHeaderTitleEdgeInsets
        
        wordsTopRightImageView.contentMode = .center
        wordsTopRightImageView.preferredSymbolConfiguration = .init(font: c.wordsHeaderActionsFont)
        wordsTopRightImageView.image = UIImage(systemName: "plus")
        
        wordsTopRightImageViewLeftC.constant = c.wordsHeaderActionsEdgeInsets.left
        wordsTopRightImageViewRightC.constant = c.wordsHeaderActionsEdgeInsets.right
    }
}
