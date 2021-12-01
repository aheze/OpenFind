//
//  CameraBridge.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct CameraBridge {
    static func makeController(model: ToolbarViewModel.Camera) -> CameraController {
        let camera = CameraController(model: model)
        return camera
    }
}

