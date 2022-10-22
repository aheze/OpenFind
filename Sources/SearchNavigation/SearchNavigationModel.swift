//
//  SearchNavigationModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

class SearchNavigationModel {
    
    var onWillBecomeActive: (() -> Void)?
    var onDidBecomeActive: (() -> Void)?
    var onWillBecomeInactive: (() -> Void)?
    var onDidBecomeInactive: (() -> Void)?
    var onBoundsChange: ((CGSize, UIEdgeInsets) -> Void)?
    
    var showNavigationBar: ((Bool) -> Void)?
}
