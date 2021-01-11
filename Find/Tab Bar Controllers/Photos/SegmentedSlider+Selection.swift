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
        if show {
            contentView.isUserInteractionEnabled = false
            stackView.isHidden = true
            indicatorView.isHidden = true
            contentView.addSubview(numberOfSelectedView)
            numberOfSelectedView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            contentView.isUserInteractionEnabled = true
            stackView.isHidden = false
            indicatorView.isHidden = false
            numberOfSelectedView.removeFromSuperview()
        }
    }
}
