//
//  PhotosVC+Sorting.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

class Month: Hashable {
    
    var id = UUID()
    var monthDate = Date()
    var assets = [PHAsset]()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Month, rhs: Month) -> Bool {
        lhs.id == rhs.id
    }
}
