//
//  PhotoSlidesVC+Delete.swift
//  Find
//
//  Created by Zheng on 1/21/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

extension PhotoSlidesViewController {
    func startDeletePhoto() {
        let findPhoto = resultPhotos[currentIndex].findPhoto
        self.deletePhotoFromSlides?(findPhoto)
        
    }
}
