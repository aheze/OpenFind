//
//  LaunchViewController.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Combine
import RealityKit
import SwiftUI

class LaunchViewController: UIViewController {
    var model: LaunchViewModel

    @IBOutlet var sceneContainer: UIView!
    lazy var sceneView = ARView()

    /// for SwiftUI, respects safe area
    @IBOutlet var contentContainer: UIView!

    static func make(model: LaunchViewModel) -> LaunchViewController {
        let storyboard = UIStoryboard(name: "LaunchContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "LaunchViewController") { coder in
            LaunchViewController(
                coder: coder,
                model: model
            )
        }
        return viewController
    }

    init?(coder: NSCoder, model: LaunchViewModel) {
        self.model = model
        super.init(coder: coder)
    }

    var sceneEventsUpdateSubscription: Cancellable!

    lazy var arView = ARView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
//        arView.cameraMode = .nonAR
//        view.addSubview(arView)
//        arView.pinEdgesToSuperview()
//
//        var sphereMaterial = SimpleMaterial()
//        sphereMaterial.metallic = MaterialScalarParameter(floatLiteral: 1)
//        sphereMaterial.roughness = MaterialScalarParameter(floatLiteral: 0)
//
//        let sphereEntity = ModelEntity(mesh: .generateSphere(radius: 1), materials: [sphereMaterial])
//        let sphereAnchor = AnchorEntity(world: .zero)
//        sphereAnchor.addChild(sphereEntity)
//        arView.scene.anchors.append(sphereAnchor)
//
//        let camera = PerspectiveCamera()
//        camera.camera.fieldOfViewInDegrees = 60
//
//        let cameraAnchor = AnchorEntity(world: .zero)
//        cameraAnchor.addChild(camera)
//
//        arView.scene.addAnchor(cameraAnchor)

//        let cameraTranslation = SIMD3<Float>(x: 0, y: 3, z: 0)
        
//        let cameraTranslation = SIMD3<Float>(x: 0, y: 3, z: 0.01)
//        let cameraTransform = Transform(
//            scale: .one,
//            rotation: simd_quatf(),
//            translation: cameraTranslation
//        )
//
//        camera.transform = cameraTransform
//        camera.look(at: .zero, from: cameraTranslation, relativeTo: nil)

//        let cameraDistance: Float = 3
//        var currentCameraRotation: Float = 0
//        let cameraRotationSpeed: Float = 0.01
//
//        sceneEventsUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
//            let x = sin(currentCameraRotation) * cameraDistance
//            let z = cos(currentCameraRotation) * cameraDistance
//
//            let cameraTranslation = SIMD3<Float>(x, 0, z)
//            let cameraTransform = Transform(scale: .one,
//                                            rotation: simd_quatf(),
//                                            translation: cameraTranslation)
//
//            camera.transform = cameraTransform
//            camera.look(at: .zero, from: cameraTranslation, relativeTo: nil)
//
//            currentCameraRotation += cameraRotationSpeed
//        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("You must create this view controller with metadata.")
    }
}
