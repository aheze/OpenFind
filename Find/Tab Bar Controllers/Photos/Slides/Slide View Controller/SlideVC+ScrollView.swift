//
//  SlideVC+ScrollView.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension SlideViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
