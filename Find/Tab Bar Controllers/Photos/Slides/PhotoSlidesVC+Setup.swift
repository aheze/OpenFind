//
//  PhotoSlidesVC+Setup.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func setupDelegates() {
        self.pageViewController.delegate = self
        self.pageViewController.dataSource = self
    }
}
