//
//  LaunchCVC+Setup.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension LaunchContentViewController {
    func setup() {
        view.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        view.addDebugBorders(.green)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}
