//
//  ViewController.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import ARKit
import Vision
import JJFloatingActionButton


class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var darkBlurEffect: UIVisualEffectView!
    @IBOutlet weak var darkBlurEffectHeightConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var modeButton: JJFloatingActionButton!
    @IBOutlet weak var shutterButton: ShutterButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var menuButton: JJFloatingActionButton!
    
    @IBOutlet weak var toolbarView: UIView!
    
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var autocompButton: UIButton!
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        print("cancel")
        view.endEditing(true)
    }
    
    @IBAction func autocompButtonPressed(_ sender: UIButton) {
        print("autocomp")
        if let selectedItem = ramReel.wrapper.selectedItem {
            ramReel.textField.text = nil
            ramReel.textField.insertText(selectedItem.render())
            view.endEditing(true)
        }
    }
    
    ///Matches HUD
    
    @IBOutlet weak var matchesBig: MatchesGradientView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBAction func upHUDPressed(_ sender: UIButton) {
        print("up")
    }
    @IBAction func downHUDPressed(_ sender: UIButton) {
        print("down")
    }
    @IBOutlet weak var numberLabel: UILabel!
    var amountOfMatches: Int = 0
    var matchesCanAcceptNewValue: Bool = true
    var matchesShouldFireTimer: Bool = true
    var pipPositionViews = [PipPositionView]()
    var initialOffset: CGPoint = .zero
    let pipWidth: CGFloat = 55
    let pipHeight: CGFloat = 120
    let panRecognizer = UIPanGestureRecognizer()
    var pipPositions: [CGPoint] {
        return pipPositionViews.map { $0.center }
    }
    var currentPipPosition : CGPoint?
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews  ()
        print("layout")
        matchesBig.center = currentPipPosition ?? pipPositions.last ?? .zero
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == matchesBig {
                self.matchesShouldFireTimer = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    
                    if self.matchesShouldFireTimer == true {
                                for view in self.pipPositionViews {
                            view.isHidden = false
                            UIView.animate(withDuration: 0.2, animations: {
                                view.alpha = 1
                            })
                            
                        }
                        
                    }
                }
            }
            
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == matchesBig {
            // do something with your currentPoint
            matchesShouldFireTimer = false
            for view in pipPositionViews {
                UIView.animate(withDuration: 0.2, animations: {
                    view.alpha = 0
                }, completion: {
                    _ in
                    view.isHidden = true
                })
            }
            }
        }
    }
    
    ///CLASSIC MODE
    let classicTimer = RepeatingTimer(timeInterval: 1)
    var isBusyProcessingImage = false
    var stopProcessingImage = false
    let sceneConfiguration = ARWorldTrackingConfiguration()
    ///     classic highlights
            var classicHighlightArray = [SCNNode]()
            var secondClassicHighlightArray = [SCNNode]()
            var classicHasFoundOne : Bool = false
            var processImageNumberOfPasses = 0
            var numberOfHighlights: Int = 0
    
    ///FOCUS MODE
    
    ///Every mode (Universal)
    var statusBarHidden : Bool = false
    var scanModeToggle = CurrentModeToggle.classic
    var finalTextToFind : String = ""
    let deviceSize = UIScreen.main.bounds.size
    var keyboardHeight = CGFloat() {
        didSet {
            if toolbarBottomConstraint.constant == 0 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.toolbarBottomConstraint.constant = self.keyboardHeight
                    print("keyboard: \(self.keyboardHeight)")
                })
            }
        }
    }
    
    ///Crosshair
    var crosshairPoint : CGPoint = CGPoint(x: 0, y: 0)
    
    
    
    ///Save the image
    var globalUrl : URL = URL(fileURLWithPath: "")
    
    lazy var textDetectionRequest: VNRecognizeTextRequest = {
        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        request.recognitionLevel = .fast
        request.recognitionLanguages = ["en_GB"]
        request.usesLanguageCorrection = true
        return request
    }()
    //ramreel
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    let data: [String] = {
        do {
            guard let dataPath = Bundle.main.path(forResource: "data", ofType: "txt") else {
                return []
            }
            
            let data = try WordReader(filepath: dataPath)
            return data.words
        }
        catch let error {
            print(error)
            return []
        }
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Sceneview
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneConfiguration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(sceneConfiguration)
        
        setUpButtons()
        setUpClassicTimer()
        setUpRamReel()
        setUpToolBar()
        setUpFilePath()
        setUpMatches()
        setUpCrosshair()
        //make sure the position views are hidden
        for view in pipPositionViews {
            view.isHidden = true
            view.alpha = 0
        }
        
        switch scanModeToggle {
            case .classic:
                print("Classic Mode")
                classicTimer.resume()
            case .focused:
                print("Focus Mode")
            
        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        classicHasFoundOne = false
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return self.statusBarHidden
    }


}
//MARK: AR
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
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
        }else{
           return
        }
    }
    
}




