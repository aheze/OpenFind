//
//  LaunchVC+Scene.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealityKit
import SceneKit
import UIKit

extension LaunchViewController {
    func setupScene() {
        sceneView.cameraMode = .nonAR
        sceneView.environment.background = .color(Colors.accentDarkBackground)
        sceneContainer.addSubview(sceneView)
        sceneView.pinEdgesToSuperview()
        sceneView.debugOptions = [.showPhysics]

        let anchor = AnchorEntity()
        sceneView.scene.addAnchor(anchor)

        let basePosition = SIMD3<Float>(x: 0, y: 0, z: 0)
        let cameraPosition = SIMD3<Float>(x: 0, y: 0.4, z: 0.01) /// can't be 0

        let baseEntity = ModelEntity()
        baseEntity.position = basePosition

        let box = MeshResource.generateBox(width: 0.1, height: 0.02, depth: 0.1, cornerRadius: 0.05, splitFaces: false)
        let material = SimpleMaterial(color: .red, isMetallic: true)
        let diceEntity = ModelEntity(mesh: box, materials: [material])
        baseEntity.addChild(diceEntity)

        anchor.addChild(baseEntity)

        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        sceneView.scene.addAnchor(cameraAnchor)
        camera.position = cameraPosition
        camera.look(at: basePosition, from: cameraPosition, relativeTo: baseEntity)
    }
}
