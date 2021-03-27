//
//  SegmentedSlider+Selection.swift
//  Find
//
//  Created by Zheng on 1/11/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension SegmentedSlider {
    func showNumberOfSelected(show: Bool) {
        cancelTouch(cancel: show)
        showingPhotosSelection = show
        if show {
            contentView.isUserInteractionEnabled = false
            stackView.isHidden = true
            indicatorView.isHidden = true
            contentView.addSubview(numberOfSelectedView)
            numberOfSelectedView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            self.accessibilityLabel = "Select Photos"
            
        } else {
            contentView.isUserInteractionEnabled = true
            stackView.isHidden = false
            indicatorView.isHidden = false
            numberOfSelectedView.removeFromSuperview()
            
            self.accessibilityLabel = "Filters"
        }
    }
    
    func updateNumberOfSelected(to number: Int) {
        if showingPhotosSelection {
            let text: String
            if number == 1 {
                text = "\(number) Photo Selected"
            } else if number == 0 {
                text = "Select Photos"
            } else {
                text = "\(number) Photos Selected"
            }
            
            self.numberOfSelectedLabel.text = text
            self.accessibilityLabel = text
        }
    }
    
}
