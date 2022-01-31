//
//  ListsDetailVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI
import UIKit

extension ListsDetailViewController {
    func setup() {
        let colorPickerIconController = ColorPickerIconController(model: headerTopRightColorPickerModel)
        addChildViewController(colorPickerIconController, in: headerTopRightView)
        
        setupViews()
        applyConstants()
        setupNavigationBar()
        
        loadListContents(animate: false)
        updateTableViewHeightConstraint(animated: false)
        
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        
        wordsTableView.dataSource = self
        wordsTableView.delegate = self
        wordsTableView.dragDelegate = self
        wordsTableView.dropDelegate = self
        
        wordsTableView.separatorStyle = .none
        wordsTableView.isScrollEnabled = false
        wordsTableView.allowsSelection = false
        wordsTableView.dragInteractionEnabled = true
        wordsTableView.contentInset = UIEdgeInsets(
            top: ListsDetailConstants.listSpacing / 2,
            left: 0,
            bottom: ListsDetailConstants.listSpacing / 2,
            right: 0
        )
    }
    
    func loadListContents(animate: Bool = true) {
        
        headerTopLeftImageView.image = UIImage(systemName: model.list.icon)
        
        let color = UIColor(hex: model.list.color)
        headerTopRightColorPickerModel.selectedColor = color
        headerView.backgroundColor = color
        
        wordsTopView.backgroundColor = color.withAlphaComponent(0.1)
        wordsTopLeftLabel.textColor = color
        wordsTopCenterLabel.textColor = color
        wordsTopRightImageView.tintColor = color
        
        headerTopCenterTextField.text = model.list.name
        headerBottomTextField.text = model.list.desc
        
        let textColor: UIColor
        let placeholderColor: UIColor
        let backgroundColor: UIColor
        
        let isLight = color.isLight
        if isLight {
            textColor = ListsDetailConstants.headerTextColorBlack
            placeholderColor = ListsDetailConstants.headerPlaceholderColorBlack
            backgroundColor = ListsDetailConstants.headerInnerViewBackgroundColorBlack
        } else {
            textColor = ListsDetailConstants.headerTextColorWhite
            placeholderColor = ListsDetailConstants.headerPlaceholderColorWhite
            backgroundColor = ListsDetailConstants.headerInnerViewBackgroundColorWhite
        }
        
        self.updateColors(animate: animate, isLight: isLight, color: color, textColor: textColor, placeholderColor: placeholderColor, backgroundColor: backgroundColor)
    }
    
    func updateColors(animate: Bool, isLight: Bool, color: UIColor, textColor: UIColor, placeholderColor: UIColor, backgroundColor: UIColor) {
        if isLight, traitCollection.userInterfaceStyle == .light {
            let adjustedTextColor = color.toColor(.black, percentage: 0.6)
            wordsTopLeftLabel.textColor = adjustedTextColor
            wordsTopCenterLabel.textColor = adjustedTextColor
            wordsTopRightImageView.tintColor = adjustedTextColor
        } else if traitCollection.userInterfaceStyle == .dark {
            let adjustedTextColor = color.toColor(.white, percentage: 0.6)
            wordsTopLeftLabel.textColor = adjustedTextColor
            wordsTopCenterLabel.textColor = adjustedTextColor
            wordsTopRightImageView.tintColor = adjustedTextColor
        } else {
            wordsTopLeftLabel.textColor = color
            wordsTopCenterLabel.textColor = color
            wordsTopRightImageView.tintColor = color
        }
        
        headerTopCenterTextField.textColor = textColor
        headerTopCenterTextField.attributedPlaceholder = NSAttributedString(
            string: "Title",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
            
        headerBottomTextField.textColor = textColor
        headerBottomTextField.attributedPlaceholder = NSAttributedString(
            string: "Description (Optional)",
            attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
        )
            
        headerTopLeftImageView.tintColor = textColor
        
        
        /// animate only when lightness changed
        var shouldAnimate = false
        let isLight = color.isLight
        if isLight != self.model.colorIsLight {
            shouldAnimate = animate
        }
        self.model.colorIsLight = isLight
        
        UIView.animate(withDuration: shouldAnimate ? 0.3 : 0, delay: 0, options: .curveEaseOut) {
            self.headerTopLeftView.backgroundColor = backgroundColor
            self.headerTopCenterView.backgroundColor = backgroundColor
            self.headerTopRightView.backgroundColor = backgroundColor
            self.headerBottomView.backgroundColor = backgroundColor
        }

        
        withAnimation(shouldAnimate ? .easeOut(duration: 0.3) : nil) {
            headerTopRightColorPickerModel.tintColor = textColor
        }
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
        
        headerBottomTextField.font = c.headerDescriptionFont
        headerBottomTextField.textAlignment = .center
        
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
