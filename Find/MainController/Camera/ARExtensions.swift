//
//  ARExtensions.swift
//  Find
//
//  Created by Andrew on 10/25/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit

extension ViewController: ARCoachingOverlayViewDelegate {
  func addCoaching() {
    coachingOverlay.delegate = self
    coachingOverlay.session = sceneView.session
    coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // MARK: CoachingGoal
    coachingOverlay.goal = .anyPlane
    
    sceneView.addSubview(coachingOverlay)
    
    sceneView.bringSubviewToFront(coachingOverlay)
    print(coachingOverlay.frame)
    print(coachingOverlay.bounds)
    coachingOverlay.frame = sceneView.frame
    print(coachingOverlay.frame)
    print(coachingOverlay.bounds)
  }
  public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
    coachingOverlayView.activatesAutomatically = true
    
  }
}

extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func setUpARDelegates() {
        ///called when ViewDidLoad, loads a world tracking (Classic) configuration
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneConfiguration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(sceneConfiguration)
    }
    func runImageTrackingSession(with trackingImages: Set<ARReferenceImage>,
                                         runOptions: ARSession.RunOptions = [.removeExistingAnchors, .resetTracking]) {
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 20
        configuration.trackingImages = trackingImages
        sceneView.session.run(configuration, options: runOptions)
        print("run image tracking session")
    }
    
    ///Classic, for making the plane bigger when the device moves around
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
        let planeNode = node.childNodes.first,
        let plane = planeNode.geometry as? SCNPlane else { return }
       
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
       
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
    
    ///Classic, for putting a detected plane on the screen
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
            print("plane detected")
        } else {
            return
        }
  }


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: focus renderer
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let plane1 = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            plane1.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.8)
            plane1.cornerRadius = 0.005
            let planeNode1 = SCNNode(geometry: plane1)
                            planeNode1.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode1)
            detectedPlanes[planeNode1] = imageAnchor
            
        }
            return node
    }
    func getImage(node: SCNNode) {
        //print("findingInNode??: \(findingInNode)")
        if findingInNode == false {
            if let anchor = detectedPlanes[node] {
                if let corners = self.projection(from: anchor) {
                    DispatchQueue.global(qos: .background).async {
                        self.findInNode(points: corners.0, buffer: corners.1)
                }
                }
            }
        }
    }
    func placeBlueFrame(node: SCNNode) {
        //print("firsttime: \(firstTimeFocusHighlight)")
        if firstTimeFocusHighlight == true {
            firstTimeFocusHighlight = false
        if let anchor = detectedPlanes[node] {
            if let corners = self.projection(from: anchor) {
                    var size = CGSize()
                    size.width = corners.0[2].x - corners.0[3].x
                    size.height = corners.0[1].y - corners.0[3].y
                    let shape = getRect(size: size)
                    let planeNode = SCNNode(geometry: shape)
                    planeNode.eulerAngles.z = -.pi / 2
                    blueNode.addChildNode(planeNode)
                    print("asdfklj")
                    currentHighlightNode = planeNode
                    let action = SCNAction.scale(to: 1.1, duration: 0.2)
                    blueNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
                    planeNode.runAction(action, completionHandler: {
                        let action2 = SCNAction.scale(to: 1, duration: 0.3)
                        planeNode.runAction(action2)
                    })
                }
            }
        }
    }

    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if scanModeToggle == .focused {
            let results = sceneView.hitTest(crosshairPoint, options: nil)
            if let feature = results.first {
              //  focusTimer.suspend()
                
              //  stopTagFindingInNode = false
                let planeNode = feature.node
                blueNode = planeNode
                isOnDetectedPlane = true
                numberOfFocusTimes = 0
                placeBlueFrame(node: planeNode)
                getImage(node: planeNode)
            } else {
                firstTimeFocusHighlight = true
                numberOfFocusTimes += 1
    
              //  stopTagFindingInNode = true
                blueNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.3)
    
                let fadeOut = SCNAction.fadeOpacity(to: 0, duration: 0.2)
                isOnDetectedPlane = false
                currentHighlightNode.runAction(fadeOut, completionHandler: {
                    self.currentHighlightNode.removeFromParentNode()
                })
                
                if numberOfFocusTimes == 65 {
                    print("resume")
                    // stopTagFindingInNode = false
                    focusTimer.resume()
    
                }
            }
        }
    }
    func projection(from anchor: ARImageAnchor) -> ([CGPoint], CVPixelBuffer)? {

        guard let camera = sceneView.session.currentFrame?.camera else {
        return nil
        }
        let refImg = anchor.referenceImage
        let transform = anchor.transform.transpose
        let size = deviceSize
        let width = Float(refImg.physicalSize.width / 2)
        let height = Float(refImg.physicalSize.height / 2)
        let pointsWorldSpace = [
            matrix_multiply(simd_float4([width, 0, -height, 1]), transform).vector_float3, // top right
            matrix_multiply(simd_float4([width, 0, height, 1]), transform).vector_float3, // bottom right
            matrix_multiply(simd_float4([-width, 0, -height, 1]), transform).vector_float3, // bottom left
            matrix_multiply(simd_float4([-width, 0, height, 1]), transform).vector_float3 // top left
        ]
        // Project 3D point to 2D space
        let pointsViewportSpace = pointsWorldSpace.map { (point) -> CGPoint in
            return camera.projectPoint(point,
                                       orientation: .portrait,
                                       viewportSize: size)
        }
            let array = pointsViewportSpace
            let buffer = sceneView.session.currentFrame?.capturedImage
            return (array, buffer) as? ([CGPoint], CVPixelBuffer)
        
    }
}
extension simd_float4 {
    var vector_float3: vector_float3 { return simd_float3([x, y, z]) }
}
