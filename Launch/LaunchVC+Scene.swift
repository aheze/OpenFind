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
        sceneView.debugOptions = [.showPhysics, .showWorldOrigin]

        let anchor = AnchorEntity()
        sceneView.scene.addAnchor(anchor)

        let basePosition = SIMD3<Float>(x: 0, y: 0, z: 0)
        let cameraPosition = SIMD3<Float>(x: 0.01, y: 0.3, z: 0.4) /// can't be 0

        let baseEntity = ModelEntity()
        anchor.addChild(baseEntity)

        addTiles(to: baseEntity)

        let camera = PerspectiveCamera()
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        sceneView.scene.addAnchor(cameraAnchor)
        camera.position = cameraPosition
        camera.look(at: basePosition, from: cameraPosition, relativeTo: baseEntity)
    }

    func addTiles(to baseEntity: ModelEntity) {
        let text = "FIND"
        let startingOffset = -(Float(text.count) / 2) * LaunchConstants.tileLength + LaunchConstants.tileLength / 2
        print("start: \(startingOffset)")
        for stringIndex in text.indices {
            let character = String(text[stringIndex])
            let index = Float(text.distance(from: text.startIndex, to: stringIndex))

            let tile = getTile(character: character)
            let xOffset = startingOffset + LaunchConstants.tileLength * index
            print("off: \(xOffset)")
            tile.position = [xOffset, 0, 0]
            baseEntity.addChild(tile)
        }
    }

    /// Gets half of the width, height and length of the bounding box,
    /// because the origin-point of the text is originally in the bottom-left corner of the bounding box.
    func getCompensation(for mesh: MeshResource) -> SIMD3<Float> {
        let bounds = mesh.bounds
        let boxCenter = bounds.center
        let boxMin = bounds.min
        var compensation = -boxCenter
//        - boxCenter
        print("         ->comp: \(compensation).. from \(boxMin) to \(boxCenter)")
        compensation *= [1, 1, 0]
        return compensation
    }
}

extension LaunchViewController {
    func getTile(character: String) -> ModelEntity {
        let tile = MeshResource.generateBox(
            width: LaunchConstants.tileLength,
            height: LaunchConstants.tileDepth,
            depth: LaunchConstants.tileLength,
            cornerRadius: LaunchConstants.tileCornerRadius,
            splitFaces: false
        )
        
        var tileMaterial = PhysicallyBasedMaterial()
        tileMaterial.baseColor = .init(tint: Colors.accent, texture: nil)
        tileMaterial.roughness = PhysicallyBasedMaterial.Roughness(floatLiteral: 0.0)
        tileMaterial.metallic = PhysicallyBasedMaterial.Metallic(floatLiteral: 1.0)
        
        let textMaterial = SimpleMaterial(color: UIColor.white.withAlphaComponent(0.25), roughness: 0, isMetallic: true)

        let text = MeshResource.generateText(
            character,
            extrusionDepth: LaunchConstants.textDepth,
            font: .systemFont(ofSize: LaunchConstants.textHeight, weight: .semibold),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )

        let tileEntity = ModelEntity(mesh: tile, materials: [tileMaterial])

        let textEntity = ModelEntity(mesh: text, materials: [textMaterial])
        let rotation = simd_quatf(
            angle: -.pi / 2, /* 45 Degrees */
            axis: [1, 0, 0] /* About X axis */
        )

        let compensation = getCompensation(for: text)

        textEntity.transform.rotation = rotation
        textEntity.position.x = compensation.x
        textEntity.position.y = LaunchConstants.textDepth / 2 + LaunchConstants.tileDepth / 2
        textEntity.position.z = -compensation.y /// need to switch because of rotation
        tileEntity.addChild(textEntity)

        return tileEntity
    }
}
