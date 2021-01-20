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
            cachePhoto()
            print("cache")
        case .delete:
            print("delete")
        case .info:
            let infoVC = InfoViewHoster()
            self.present(infoVC, animated: true)
        }
    }
}
