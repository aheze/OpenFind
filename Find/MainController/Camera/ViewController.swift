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
        
        UIView.animate(withDuration: 0.4, animations: {
            self.ramReel.textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        }, completion: { _ in
            self.ramReel.textField.text = ""
            self.ramReel.textField.textColor = UIColor.white
        })
        
        
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
    
    
    @IBOutlet var matchesWidthConstraint: NSLayoutConstraint!
    @IBOutlet var matchesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var matchesBig: MatchesGradientView!
    @IBOutlet var upButtonToNumberConstraint: NSLayoutConstraint!
    @IBOutlet var downButtonToNumberConstraint: NSLayoutConstraint!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    @IBAction func upHUDPressed(_ sender: UIButton) {
        print("up")
    }
    @IBAction func downHUDPressed(_ sender: UIButton) {
        print("down")
    }
    @IBOutlet weak var numberLabel: UILabel!
    
    var matchesCanAcceptNewValue: Bool = true
    var matchesShouldFireTimer: Bool = true
    var pipPositionViews = [PipPositionView]()
    var initialOffset: CGPoint = .zero
    let pipWidth: CGFloat = 55
    let pipHeight: CGFloat = 55
    let panRecognizer = UIPanGestureRecognizer()
    var pipPositions: [CGPoint] {
        return pipPositionViews.map { $0.center }
    }
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        refreshScreen()
    }
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    var bsdfhjknL: Bool = false
    var skdjbf : Bool = false
    var currentPipPosition : CGPoint?
    override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews  ()
        //test
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
    let classicTimer = RepeatingTimer(timeInterval: 0.8)
    var isBusyProcessingImage = false
    var stopProcessingImage = false
    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    let sceneConfiguration = ARWorldTrackingConfiguration()
    ///     classic highlights
            var classicHighlightArray = [SCNNode]()
            var secondClassicHighlightArray = [SCNNode]()
            var classicHasFoundOne : Bool = false
            var processImageNumberOfPasses = 0
            var numberOfHighlights : Int = 0
    lazy var textDetectionRequest = VNRecognizeTextRequest(completionHandler: handleDetectedText)
//        let request = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
//        request.recognitionLevel = .fast
//        request.recognitionLanguages = ["en_GB"]
//        request.usesLanguageCorrection = true
//        return request
//    }()
    
    ///FOCUS MODE
    var focusTimer = RepeatingTimer(timeInterval: 1)
    
    var currentCameraImage: CVPixelBuffer!
    var focusHasFoundOne: Bool = false
    var imagesToTrack = [ARReferenceImage]()
    var isLookingForRect: Bool = false
    var numberOfFocusTimes: Int = 0
    var detectedPlanes = [SCNNode: ARImageAnchor]()
    var blueNode = SCNNode()
    var currentHighlightNode = SCNNode()
    
    var stopTagFocusVision : Bool = false
    
    
    var isOnDetectedPlane : Bool = false
    var findingInNode : Bool = false
    var focusRepeatsCounter: Int = 0
    var firstTimeFocusHighlight = true
    
    var focusImageSize: CGSize = CGSize(width: 0, height: 0)
    var referenceImageSizeInRealWorld: CGSize = CGSize(width: 0, height: 0)
    var extentOfPerspectiveImage = CGRect()
    
    var focusHighlightArray = [SCNNode]()
    var secondFocusHighlightArray = [SCNNode]()
    lazy var focusTextDetectionRequest = VNRecognizeTextRequest(completionHandler: handleFocusDetectedText)
    
    ///Every mode (Universal)
    let coachingOverlay = ARCoachingOverlayView()
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
        setUpARDelegates()
        
        textDetectionRequest.recognitionLevel = .fast
        textDetectionRequest.recognitionLanguages = ["en_GB"]
        textDetectionRequest.usesLanguageCorrection = true
        focusTextDetectionRequest.recognitionLevel = .fast
        focusTextDetectionRequest.recognitionLanguages = ["en_GB"]
        focusTextDetectionRequest.usesLanguageCorrection = true
            
       
        setUpButtons()
        setUpTimers()
        setUpRamReel()
        setUpToolBar()
        setUpFilePath()
        setUpMatches()
        setUpCrosshair()
        addCoaching()
        
        changeHUDSize(to: CGSize(width: 55, height: 55))
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




