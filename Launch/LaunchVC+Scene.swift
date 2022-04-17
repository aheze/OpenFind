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
//        sceneView.debugOptions = [.showPhysics, .showWorldOrigin]

        let anchor = AnchorEntity()
        sceneView.scene.addAnchor(anchor)

        let basePosition = SIMD3<Float>(x: 0, y: 0, z: 0)
        let cameraPosition = SIMD3<Float>(x: 0.0001, y: 0.4, z: 0.1) /// can't be 0

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
        func getStartingOffset(length: Int) -> Float {
            let totalTileLength = Float(length) * LaunchConstants.tileLength
            let totalTileGap = Float(length - 1) * LaunchConstants.tileGap
            let totalLength = totalTileLength + totalTileGap
            let offset = -totalLength / 2 + LaunchConstants.tileLength / 2
            return offset
        }

        /// get offset along one access
        func getAdditionalOffset(for index: Float, startingOffset: Float) -> Float {
            let lengthOffset = LaunchConstants.tileLength * index
            let gapOffset = LaunchConstants.tileGap * index
            let offset = startingOffset + lengthOffset + gapOffset
            return offset
        }

        let width = model.textRows.first?.text.count ?? 0
        let height = model.textRows.count

        /// start to the left
        let startingXOffset = getStartingOffset(length: width)
        let startingZOffset = getStartingOffset(length: height)


        for rowIndex in model.textRows.indices {
            let row = model.textRows[rowIndex]
            for textIndex in row.text.indices {
                let text = row.text[textIndex]

                let xOffset = getAdditionalOffset(for: Float(textIndex), startingOffset: startingXOffset) /// left to right
                let zOffset = getAdditionalOffset(for: Float(rowIndex), startingOffset: startingZOffset) /// back to front

                let tile = getTile(character: text.character, color: text.color)
                tile.position = [xOffset, 0, zOffset]
                baseEntity.addChild(tile)
            }
        }
    }

    /// Gets half of the width, height and length of the bounding box,
    /// because the origin-point of the text is originally in the bottom-left corner of the bounding box.
    func getCompensation(for mesh: MeshResource) -> SIMD3<Float> {
        let bounds = mesh.bounds
        let boxCenter = bounds.center
        var compensation = -boxCenter
        compensation *= [1, 1, 0]
        return compensation
    }
}

extension LaunchViewController {
    func getTile(character: String, color: UIColor) -> ModelEntity {
        let tile = MeshResource.generateBox(
            width: LaunchConstants.tileLength,
            height: LaunchConstants.tileDepth,
            depth: LaunchConstants.tileLength,
            cornerRadius: LaunchConstants.tileCornerRadius,
            splitFaces: false
        )

        let tileMaterial = SimpleMaterial(color: color, roughness: 0, isMetallic: true)
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
