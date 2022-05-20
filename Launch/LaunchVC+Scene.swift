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
        _ = sceneView

        guard let sceneView = sceneView else { return }
        sceneView.cameraMode = .nonAR
        sceneView.environment.background = .color(.clear)
        sceneContainer.addSubview(sceneView)
        sceneView.pinEdgesToSuperview()

        let anchor = AnchorEntity()
        sceneView.scene.addAnchor(anchor)

        let baseEntity = ModelEntity()
        self.baseEntity = baseEntity
        anchor.addChild(baseEntity)

        self.adjustPositions()
        self.addTiles(to: baseEntity)

        let camera = PerspectiveCamera()
        self.camera = camera
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.addChild(camera)
        sceneView.scene.addAnchor(cameraAnchor)
        camera.look(at: .zero, from: LaunchConstants.cameraPositionInitial, relativeTo: baseEntity)

        self.animateScene()

        UIView.animate(withDuration: 0.5) {
            self.sceneContainer.alpha = 1
            self.imageView.alpha = 0
            self.activityIndicator.alpha = 0
        }

        showUI()
    }

    func animateScene() {
        guard let camera = self.camera else { return }
        guard let baseEntity = self.baseEntity else { return }

        for tile in self.model.tiles {
            tile.entity.move(
                to: tile.midTransform,
                relativeTo: nil,
                duration: LaunchConstants.tilesInitialAnimationDuration,
                timingFunction: .easeInOut
            )
        }

        /// one tiles done animating, start flipping them
        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.tilesInitialAnimationDuration) { [weak self] in
            guard let self = self else { return }
            let normalTiles = self.model.tiles.filter { !$0.text.isPartOfFind }
            self.flipRandomNormalTile(in: normalTiles)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.findTileAnimationDelay) { [weak self] in
            guard let self = self else { return }
            let findTiles = self.model.tiles.filter { $0.text.isPartOfFind }
            for index in findTiles.indices {
                let tile = findTiles[index]
                guard let finalTransform = tile.finalTransform else { continue }

                let percentage = Double(index) / 3
                let delay = percentage * LaunchConstants.findTileAnimationTotalDuration
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    tile.entity.move(
                        to: finalTransform,
                        relativeTo: nil,
                        duration: LaunchConstants.findTileAnimationIndividualDuration,
                        timingFunction: .easeInOut
                    )
                }
            }
        }

        camera.look(at: .zero, from: LaunchConstants.cameraPositionFinal, relativeTo: baseEntity)
        let transform = camera.transform /// get the final transform
        camera.look(at: .zero, from: LaunchConstants.cameraPositionInitial, relativeTo: baseEntity)

        camera.move(
            to: transform,
            relativeTo: nil,
            duration: 5,
            timingFunction: .easeInOut
        )
    }

    func flipRandomNormalTile(in tiles: [LaunchTile]) {
        func flip(tile: LaunchTile, reversed: Bool) {
            let multiplier = Float(reversed ? -1 : 1)
            var transform = tile.midTransform
            transform.rotation = simd_quatf(
                angle: Float(180.degreesToRadians) * multiplier,
                axis: [0, 0, 1]
            )
            tile.entity.move(
                to: transform,
                relativeTo: nil,
                duration: LaunchConstants.tilesRepeatingAnimationDuration,
                timingFunction: .easeInOut
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.tilesRepeatingAnimationDuration) {
                transform.rotation = simd_quatf(
                    angle: Float(360.degreesToRadians) * multiplier,
                    axis: [0, 0, 1]
                )
                tile.entity.move(
                    to: transform,
                    relativeTo: nil,
                    duration: LaunchConstants.tilesRepeatingAnimationDuration,
                    timingFunction: .easeInOut
                )
            }
        }

        guard let randomTile = tiles.randomElement() else { return }

        let location = randomTile.location
        let mirroringLocation = LaunchTile.Location(
            x: model.width - 1 - location.x,
            z: model.height - 1 - location.z
        )

        let mirroringTile = tiles.first { $0.location == mirroringLocation }

        flip(tile: randomTile, reversed: false)
        if let mirroringTile = mirroringTile {
            flip(tile: mirroringTile, reversed: true)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.tilesRepeatingAnimationDelay * 2) { [weak self] in
            guard let self = self else { return }
            self.flipRandomNormalTile(in: tiles)
        }
    }

    func adjustPositions() {
        let modelXCenter = Float(model.width - 1) / 2 /// should be 2.5, which corresponds to a `rowIndex` / `textIndex`
        let modelZCenter = Float(model.height - 1) / 2
        let maxValue = modelXCenter * modelZCenter

        for rowIndex in model.textRows.indices {
            let row = model.textRows[rowIndex]
            for textIndex in row.text.indices {
                let x = Float(textIndex) - modelXCenter
                let z = Float(rowIndex) - modelZCenter
                let value = abs(x * z)

                let percentageOfMaximum = value / maxValue

                let limit = LaunchConstants.tileYOffsetLimit * percentageOfMaximum
                let additionalXOffset = LaunchConstants.tileDiagonalOffsetLimit * (x / modelXCenter)
                let additionalZOffset = LaunchConstants.tileDiagonalOffsetLimit * (z / modelZCenter)

                model.textRows[rowIndex].text[textIndex].yOffset = limit
                model.textRows[rowIndex].text[textIndex].additionalXOffset = additionalXOffset
                model.textRows[rowIndex].text[textIndex].additionalZOffset = additionalZOffset
            }
        }
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

        /// start to the left
        let startingXOffset = getStartingOffset(length: model.width)
        let startingZOffset = getStartingOffset(length: model.height)

        var tiles = [LaunchTile]()
        for rowIndex in model.textRows.indices {
            let row = model.textRows[rowIndex]
            for textIndex in row.text.indices {
                let text = row.text[textIndex]

                let xOffset = getAdditionalOffset(for: Float(textIndex), startingOffset: startingXOffset) /// left to right
                let zOffset = getAdditionalOffset(for: Float(rowIndex), startingOffset: startingZOffset) /// back to front

                let tileEntity = getTileEntity(character: text.character, color: text.color)

                let initialPosition = SIMD3(
                    x: xOffset + text.additionalXOffset,
                    y: text.yOffset,
                    z: zOffset + text.additionalZOffset
                )
                let midPosition = SIMD3(
                    x: xOffset,
                    y: 0,
                    z: zOffset
                )
                var finalPosition: SIMD3<Float>?

                if text.isPartOfFind {
                    finalPosition = SIMD3(
                        x: xOffset,
                        y: LaunchConstants.findTileFinalYOffset,
                        z: zOffset
                    )
                }

                let initialTransform = Transform(
                    scale: .one,
                    rotation: simd_quatf(),
                    translation: initialPosition
                )
                let midTransform = Transform(
                    scale: .one,
                    rotation: simd_quatf(),
                    translation: midPosition
                )

                var finalTransform: Transform?
                if let finalPosition = finalPosition {
                    finalTransform = Transform(
                        scale: .one,
                        rotation: simd_quatf(),
                        translation: finalPosition
                    )
                }

                tileEntity.transform = initialTransform
                baseEntity.addChild(tileEntity)

                let tile = LaunchTile(
                    text: text,
                    entity: tileEntity,
                    location: .init(x: textIndex, z: rowIndex),
                    initialTransform: initialTransform,
                    midTransform: midTransform,
                    finalTransform: finalTransform
                )
                tiles.append(tile)
            }
        }

        model.tiles = tiles
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
    func getTileEntity(character: String, color: UIColor) -> ModelEntity {
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
            font: LaunchConstants.tileFont,
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

        let compensation = self.getCompensation(for: text)

        textEntity.transform.rotation = rotation
        textEntity.position.x = compensation.x
        textEntity.position.y = LaunchConstants.textDepth / 2 + LaunchConstants.tileDepth / 2
        textEntity.position.z = -compensation.y /// need to switch because of rotation
        tileEntity.addChild(textEntity)

        return tileEntity
    }
}
