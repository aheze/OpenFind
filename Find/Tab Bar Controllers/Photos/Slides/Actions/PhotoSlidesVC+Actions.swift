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
        print("action! \(action)")
        
        switch action {
        
        case .share:
            print("share")
            
        case .star:
            print("star")
            starPhoto()
        case .cache:
            
            print("cache")
            cachePhoto()
        case .delete:
            print("delete")
            startDeletePhoto()
        case .info:
            infoPressed()
        }
    }
}
