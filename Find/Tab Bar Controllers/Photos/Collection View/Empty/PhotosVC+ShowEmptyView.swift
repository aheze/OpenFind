//
//  PhotosVC+ShowEmptyView.swift
//  Find
//
//  Created by Zheng on 1/26/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SnapKit

extension PhotosViewController {
    func showEmptyView(previously: PhotoFilter, to: PhotoFilter) {
        if let emptyDescriptionView = emptyDescriptionView {
            emptyDescriptionView.change(from: previously, to: to)
            UIView.animate(withDuration: 0.3) {
                emptyDescriptionView.alpha = 1
            }
        } else {
            let emptyView = EmptyDescriptionView()
            emptyView.alpha = 0
            view.addSubview(emptyView)
            emptyView.snp.makeConstraints { (make) in
                make.edges.equalTo(view.safeAreaLayoutGuide)
            }
            
            emptyView.change(from: previously, to: to)
            UIView.animate(withDuration: 0.3) {
                emptyView.alpha = 1
            }
            
            self.emptyDescriptionView = emptyView
        }
        view.bringSubviewToFront(segmentedSlider)
    }
    func hideEmptyView() {
        if let emptyDescriptionView = emptyDescriptionView {
            UIView.animate(withDuration: 0.1) {
                emptyDescriptionView.alpha = 0
            }
        }
    }
}
