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
