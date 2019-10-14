//
//  ViewController.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import JJFloatingActionButton

class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var modeButton: JJFloatingActionButton!
    @IBOutlet weak var shutterButton: ShutterButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var menuButton: JJFloatingActionButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Sceneview
        sceneView.delegate = self
        let sceneConfiguration = ARWorldTrackingConfiguration()
        sceneConfiguration.planeDetection = .horizontal
        sceneView.session.run(sceneConfiguration)
        
        setUpButtons()
    }
    
    var statusBarHidden : Bool = false
    override var prefersStatusBarHidden: Bool {
        return self.statusBarHidden
    }


}
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIColor.white
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            node.addChildNode(planeNode)
        }else{
           return
        }
    }
    
}

extension ViewController {
    func setUpButtons() {
        self.statusBarHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        })
        
        let goToHist = menuButton.addItem()
        goToHist.titleLabel.text = "History"
        goToHist.imageView.image = #imageLiteral(resourceName: "bhistory 2")
        goToHist.action = { item in
            print("hist")
            //self.performSegue(withIdentifier: "goToHist", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        let goToSett = menuButton.addItem()
        goToSett.titleLabel.text = "Settings"
        goToSett.imageView.image = #imageLiteral(resourceName: "bsettings 2")
        goToSett.action = { item in
            print("settings")
            //self.performSegue(withIdentifier: "goToSett", sender: self)
            //self.t.suspend()
            //self.f.suspend()
        }
        
        
        
    let goToClassic = modeButton.addItem()
        goToClassic.titlePosition = .trailing
        goToClassic.titleLabel.text = "Classic mode"
        goToClassic.imageView.image = #imageLiteral(resourceName: "bclassic 2")
        goToClassic.action = { item in
            print("classicmode")
            
             //self.scanModeToggle = .classic
             //self.stopFinding = true
             //self.blurScreen(mode: false)
             //self.f.suspend()
             //self.stopLoopTag = false
             //self.t.resume()
            UIView.animate(withDuration: 0.2, animations: {
                if let tag1 = self.view.viewWithTag(1) {
                    tag1.alpha = 0
                }
                if let tag2 = self.view.viewWithTag(2) {
                    tag2.alpha = 0
                }
            })

        }
        let goToFocus = modeButton.addItem()
        goToFocus.titlePosition = .trailing
        goToFocus.titleLabel.text = "Focus mode"
        goToFocus.imageView.image = #imageLiteral(resourceName: "bfocus 2")
        goToFocus.action = { item in
            //self.classicHasFoundOne = false
            print("focusmode")
            //self.scanModeToggle = .focused
            //self.stopLoopTag = true
            //self.stopFinding = false
            //self.t.suspend()
            //self.numberOfFocusTimes = 0
            //self.f.resume()
            //self.blurScreen(mode: true)
        }
        menuButton.overlayView.backgroundColor = UIColor.clear
        modeButton.overlayView.backgroundColor = UIColor.clear
    }
}

