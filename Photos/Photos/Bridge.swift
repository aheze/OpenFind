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

public enum Constants {
    public static var activeIconColor = UIColor.blue
    public static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
}
