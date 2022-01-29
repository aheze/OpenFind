//
//  SearchNC+Utilities.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/10/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension UIViewController {
    func getCompactBarSafeAreaHeight(with safeAreaInsets: UIEdgeInsets) -> CGFloat {
//        let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let barHeight = navigationController?.navigationBar.getCompactHeight() ?? 0
        return safeAreaInsets.top + barHeight
    }
}
