//
//  PhotoFindVC+Populate.swift
//  Find
//
//  Created by Zheng on 1/15/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

class ResultPhoto: NSObject {
    var findPhoto = FindPhoto()
    var numberOfMatches = 0
    var descriptionText = ""
    var descriptionHeight = CGFloat(0)
    var descriptionMatchRanges = [ArrayOfMatchesInComp]()
    var components = [Component]()
}

extension PhotoFindViewController {
    func populatePhotos(findPhotos: [FindPhoto]) {
        self.findPhotos = findPhotos
    }
}
