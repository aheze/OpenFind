//
//  CameraBridge.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct CameraBridge {
    static func makeController(cameraViewModel: CameraViewModel, listsViewModel: ListsViewModel) -> CameraController {
        let camera = CameraController(
            cameraViewModel: cameraViewModel,
            listsViewModel: listsViewModel
        )
        return camera
    }
}
