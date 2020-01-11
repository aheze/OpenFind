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
    
    
 
    
    @IBOutlet weak var minimizeButton: UIButton!
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
    var shouldScale = true
    var currentNumber = 0
    var startGettingNearestFeaturePoints = false
    let fastSceneConfiguration = AROrientationTrackingConfiguration()
    
    @IBAction func upHUDPressed(_ sender: UIButton) {
        print("up")
        matchesUpPressed()
    }
    @IBAction func downHUDPressed(_ sender: UIButton) {
        print("down")
        matchesDownPressed()
    }
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberDenomLabel: UILabel!
    
    var matchesCanAcceptNewValue: Bool = true
    var matchesShouldFireTimer: Bool = true
    var pipPositionViews = [PipPositionView]()
    
    @IBOutlet weak var slashImage: UIImageView!
    
    var specialPip = PipPositionView()
    
    var initialOffset: CGPoint = .zero
    let pipWidth: CGFloat = 55
    let pipHeight: CGFloat = 120
    let panRecognizer = UIPanGestureRecognizer()
    var pipPositions: [CGPoint] {
        return pipPositionViews.map { $0.center }
    }
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        refreshScreen()
    }
    
    var shouldMin = true
    @IBAction func minimizeButtonButtonPressed(_ sender: UIButton) {
        print("press")
        shouldMin = !shouldMin
        hideTopNumber(hide: shouldMin)
    }
    
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
    
    var blurView = UIVisualEffectView()
    ///Detect if the view controller attempted to dismiss, but didn't
    var hasStartedDismissing = false
    var cancelSeconds = 0
    var cancelTimer : Timer?
    var isCancelTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    
    ///FAST MODE
    enum FastFinding {
        case busy
        case notBusy
        case inactive
    }
    //var fastFindingToggle = FastFinding.inactive
    var busyFastFinding = false
    lazy var fastTextDetectionRequest = VNRecognizeTextRequest(completionHandler: handleFastDetectedText)
    var startFastFinding = false
    var fastTimer = RepeatingTimer(timeInterval: 0.02)
    var tempComponents = [Component]()
    var currentComponents = [Component]()
    var nextComponents = [Component]()
    //var componentsToLayers = [Component: CALayer]()
    //var layersToSublayers = [CALayer: CALayer]()
 //   var componentsToViews = [Component: UIView]()
    
    var numberCurrentFastmodePass: Int = 0
    var numberOfFastMatches: Int = 0

    
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
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
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
    var scanModeToggle = CurrentModeToggle.fast
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
        //UIApplication.shared.statusBarStyle = .lightContent
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: Sceneview
        
        setUpARDelegates()
        sceneView.delegate = self
        sceneView.session.delegate = self
        numberLabel.isHidden = false
        numberDenomLabel.isHidden = false
        shouldMin = false
        hideTopNumber(hide: shouldMin)
        
        fastTextDetectionRequest.recognitionLevel = .fast
        fastTextDetectionRequest.recognitionLanguages = ["en_GB"]
        //fastTextDetectionRequest.customWords = ["98ohkjshgosro9g"]
        //fastTextDetectionRequest.usesLanguageCorrection = true
        textDetectionRequest.recognitionLevel = .fast
        textDetectionRequest.recognitionLanguages = ["en_GB"]
        textDetectionRequest.usesLanguageCorrection = true
        focusTextDetectionRequest.recognitionLevel = .fast
        focusTextDetectionRequest.recognitionLanguages = ["en_GB"]
        focusTextDetectionRequest.usesLanguageCorrection = true
        
        updateMatchesNumber(to: 0)
       
        setUpButtons()
        setUpTimers()
        setUpRamReel()
        setUpToolBar()
        setUpFilePath()
        setUpMatches()
        setUpCrosshair()
        //addCoaching()
        
        //changeHUDSize(to: CGSize(width: 55, height: 55))
        //make sure the position views are hidden
        for view in pipPositionViews {
            view.isHidden = true
            view.alpha = 0
        }
        
        scanModeToggle = .fast
        classicHasFoundOne = false
        stopCoaching()
        stopProcessingImage = true
        classicTimer.suspend()
        focusTimer.suspend()
        sceneView.session.run(fastSceneConfiguration, options: [.removeExistingAnchors, .resetTracking])
        modeButton.imageView.image = #imageLiteral(resourceName: "bfast 2")
        busyFastFinding = false
        fastTimer.resume()
        print("resume?")
//        switch scanModeToggle {
//        case .classic:
////            print("Classic Mode")
////            previewView.isHidden = true
////            classicTimer.resume()
//            toClassic()
//        case .focused:
//            print("Focus Mode")
//            //previewView.isHidden = true
//            toFocus()
//        case .fast:
//            print("fast mode")
//           // previewView.isHidden = false
//            toFast()
//        }
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        classicHasFoundOne = false
    }
    
    
//    override var prefersStatusBarHidden: Bool {
//        return self.statusBarHidden
//    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


}




