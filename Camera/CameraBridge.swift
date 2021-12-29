//
//  CameraBridge.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct CameraBridge {
    static func makeController(model: CameraViewModel) -> CameraController {
        let camera = CameraController(model: model)
        return camera
    }
}
