//
//  PhotosSlidesVC+Toolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import UIKit

extension PhotosSlidesViewController {
    func configureToolbar(for photo: Photo) {
        if let metadata = photo.metadata {
            if metadata.isStarred {
                model.slidesState?.toolbarStarOn = true
                return
            }
        }
        
        model.slidesState?.toolbarStarOn = false
        model.slidesState?.toolbarInformationOn = false
    }
}
