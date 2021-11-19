//
//  Bridge.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public struct Bridge {
    public static func makeController() -> PhotosController {
        let photos = PhotosController()
        return photos
    }
}
