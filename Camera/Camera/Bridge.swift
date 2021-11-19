//
//  Bridge.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

public struct Bridge {
    public static func makeController() -> CameraController {
        let camera = CameraController()
        return camera
    }
}

public enum Constants {
    public static var activeIconColor = UIColor.blue
    public static var iconFont = UIFont.preferredFont(forTextStyle: .title2)
}
