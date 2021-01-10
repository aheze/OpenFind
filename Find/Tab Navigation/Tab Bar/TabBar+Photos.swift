//
//  TabBar+Photos.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum PhotoSlideAction {
    case share
    case star
    case cache
    case delete
    case info
    
}
extension TabBarView {
    func showPhotoSlideControls(show: Bool) {
        if show {
            controlsReferenceView.isUserInteractionEnabled = true
            stackView.isHidden = true
            controlsReferenceView.addSubview(photoSlideControls)
            photoSlideControls.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            controlsReferenceView.isUserInteractionEnabled = false
            stackView.isHidden = false
            photoSlideControls.removeFromSuperview()
        }
        
    }
}
