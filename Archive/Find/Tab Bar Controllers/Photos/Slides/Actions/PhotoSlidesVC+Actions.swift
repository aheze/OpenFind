//
//  PhotoSlidesVC+Actions.swift
//  Find
//
//  Created by Zheng on 1/9/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func actionPressed(action: PhotoSlideAction) {
        switch action {
        case .share:
            sharePhoto()
        case .star:
            starPhoto()
        case .cache:
            cachePhoto()
        case .delete:
            startDeletePhoto()
        case .info:
            infoPressed()
        }
    }
}
