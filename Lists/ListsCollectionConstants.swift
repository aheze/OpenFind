//
//  ListsCollectionConstants.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

struct ListsCollectionConstants {
    static var minCellWidth = CGFloat(300)
    static var sidePadding = CGFloat(16)
}

struct ListsCellConstants {
    static var headerFont = UIFont.preferredFont(forTextStyle: .body).bold()
    static var headerEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    
    /// hugs the chips
    static var contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    static var chipFont = UIFont.preferredFont(forTextStyle: .body)
    static var chipEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    static var chipSpacing = CGFloat(8)
    static var maxNumberOfChipLines = 2
    
}
