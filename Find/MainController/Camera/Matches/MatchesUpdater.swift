//
//  MatchesUpdater.swift
//  Find
//
//  Created by Andrew on 1/2/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

//import UIKit
//import ARKit
//
//extension ViewController {
//    
//    
//    
//    func matchesUpPressed() {
//    }
//    
//    func matchesDownPressed() {
////        sceneView.session.pause()
////        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, .showWorldOrigin]
////        sceneView.session.run(fastSceneConfiguration)
////        startGettingNearestFeaturePoints = true
//        //        let results = sceneView.hitTest(CGPoint(x: 200, y: 400), types: .featurePoint)
////                        if let hitResult = results.first {
//  //      print("FEATURE ADJFJKHDLJDHSHBKJ________+_")
//        //let realTextWidth = (individualCharacterWidth * CGFloat(stringToFind.count)) / CGFloat(2000)
//        
//       // let highlight = SCNBox(width: 0.04, height: 0.02, length: 0.04, chamferRadius: 0.005)
//        let highlight = SCNPlane(width: 0.05, height: 0.02)
//        let material = SCNMaterial()
//        let highlightColor : UIColor = #colorLiteral(red: 0, green: 0.7389578223, blue: 0.9509587884, alpha: 1)
//        material.diffuse.contents = highlightColor.withAlphaComponent(0.95)
//        highlight.materials = [material]
//        
//        let node = SCNNode(geometry: highlight)
////                            node.transform = SCNMatrix4(hitResult.anchor!.transform)
////                            node.position = SCNVector3(
////                                x: hitResult.worldTransform.columns.3.x,
////                                y: hitResult.worldTransform.columns.3.y,
////                                z: hitResult.worldTransform.columns.3.z
////                            )
//        //node.position = SCNVector3(0.0, 1, -0.2)
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.2
//        translation.columns.3.y = -0.05
//        translation.columns.3.x = -0.05
//
//        // Translate 10 cm in front of the camera
//        guard let frame = sceneView.session.currentFrame else {
//            print("EROROWEIO")
//            return}
//     
//        let imageResolution = frame.camera.imageResolution
//        let viewSize = sceneView.bounds.size
//        let projection = frame.camera.projectionMatrix(for: .portrait,
//            viewportSize: viewSize, zNear: 1, zFar: 2)
//        let yScale = projection[1,1] // = 1/tan(fovy/2)
//        let yFovDegrees = 2 * atan(1/yScale) * 180/Float.pi
//        let xFovDegrees = yFovDegrees * Float(viewSize.height / viewSize.width)
//        print(yFovDegrees)
//        print(xFovDegrees)
//        
////        let secNode = node
////        secNode.position = SCNVector3(0.1, 0.5, -0.2)
//        
//        sceneView.scene.rootNode.addChildNode(node)
//        node.simdTransform = matrix_multiply(frame.camera.transform, translation)
////        sceneView.scene.rootNode.addChildNode(secNode)
//  
//    
////                        }
//        
//        
//        
//        let defaults = UserDefaults.standard
//        
//        let hasPressedBefore = defaults.bool(forKey: "hasPressedBefore")
//        print(hasPressedBefore)
//            print("exists")
//       
////            defaults.set(25, forKey: "Age")
////            defaults.set(true, forKey: "UseTouchID")
////            defaults.set(CGFloat.pi, forKey: "Pi")
////
////            defaults.set("Paul Hudson", forKey: "Name")
////            defaults.set(Date(), forKey: "LastRun")
////        
//        
////        let attribute = EKAttributes()
////        attribute.
////        SwiftEntryKit.display(entry: T##UIView, using: T##EKAttributes)
//    }
//    func disableNewHighlights(enable: Bool) {
//        shouldScale = enable
//        
//    }
//}
