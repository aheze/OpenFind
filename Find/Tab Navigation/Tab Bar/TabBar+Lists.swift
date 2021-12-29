//
//  TabBar+Lists.swift
//  Find
//
//  Created by Zheng on 12/29/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension TabBarView {
    func showListsControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            stackView.isHidden = true
            controlsReferenceView.addSubview(listsControls)
            listsControls.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            backgroundView.accessibilityLabel = "Toolbar"
            contentView.accessibilityElements = [backgroundView, listsSelectionLabel, listsDeleteButton]
        } else {
            controlsReferenceView.isUserInteractionEnabled = false
            stackView.isHidden = false
            listsControls.removeFromSuperview()
            
            backgroundView.accessibilityLabel = "Tab bar"
            contentView.accessibilityElements = nil
        }
    }

    func updateListsSelectionLabel(numberOfSelected: Int) {
        if numberOfSelected == 0 {
            listsDeleteButton.isEnabled = false
        } else {
            listsDeleteButton.isEnabled = true
        }
        
        if numberOfSelected == 1 {
            listsSelectionLabel.text = "\(numberOfSelected) List Selected"
            listsDeleteButton.accessibilityHint = "Delete \(numberOfSelected) selected list"
        } else if numberOfSelected == 0 {
            listsSelectionLabel.text = "Select Lists"
            listsDeleteButton.accessibilityHint = "Select lists first."
        } else {
            listsSelectionLabel.text = "\(numberOfSelected) Lists Selected"
            listsDeleteButton.accessibilityHint = "Delete \(numberOfSelected) selected lists"
        }
    }
}
