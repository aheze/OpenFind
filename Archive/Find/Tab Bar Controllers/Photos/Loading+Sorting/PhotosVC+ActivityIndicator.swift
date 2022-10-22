//
//  PhotosVC+ActivityIndicator.swift
//  Find
//
//  Created by Zheng on 1/12/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SnapKit
import UIKit

extension PhotosViewController {
    func addActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.activityIndicator = activityIndicator
        activityIndicator.startAnimating()
    }
}
