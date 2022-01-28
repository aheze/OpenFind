//
//  CameraBridge.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import UIKit

struct CameraBridge {
    static func makeController(
        cameraViewModel: CameraViewModel,
        realmModel: RealmModel
    ) -> CameraController {
        let camera = CameraController(
            cameraViewModel: cameraViewModel,
            realmModel: realmModel
        )
        return camera
    }
}
