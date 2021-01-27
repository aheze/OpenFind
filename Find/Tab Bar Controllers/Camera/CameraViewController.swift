//
//  CameraViewController.swift
//  Find
//
//  Created by Zheng on 10/13/19.
//  Copyright © 2019 Zheng. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import CoreMotion
import RealmSwift
import SnapKit
import WhatsNewKit
import EasyTipView

protocol ToggleCreateCircle: class {
    func toggle(created: Bool)
}
protocol UpdateMatchesNumberStats: class {
    func update(to: Int)
}


class CameraViewController: UIViewController {
    
    let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
    let updateImportantShouldPresentWhatsNew = false
    var shouldPresentWhatsNew = false
    
    // MARK: Tab bar
    @IBOutlet weak var cameraIconHolder: UIView!
    @IBOutlet weak var cameraIconHolderBottomC: NSLayoutConstraint!
    
    @IBOutlet weak var messageView: MessageView!
    @IBOutlet weak var saveToPhotos: SaveToPhotosButton!
    @IBOutlet weak var cameraIcon: CameraIcon!
    @IBOutlet weak var cache: CacheButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var cacheLabel: UILabel!
    
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var statsBottomC: NSLayoutConstraint!
    @IBOutlet weak var statsButton: UIButton!
    
    
    @IBAction func statsButtonDown(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.statsButton.alpha = 0.5
        })
    }
    
    @IBAction func statsButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.statsButton.alpha = 1
        })
        tappedOnStats()
    }
    @IBAction func statsButtonCancel(_ sender: Any) {
        UIView.animate(withDuration: 0.2, animations: {
            self.statsButton.alpha = 1
        })
    }
    
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsBottomC: NSLayoutConstraint!
    @IBOutlet weak var settingsButton: UIButton!
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let settingsVC = SettingsViewHoster()
        settingsVC.presentationController?.delegate = self
        self.present(settingsVC, animated: true)
    }
    
    var currentPausedImage: UIImage?
    var waitingToFind = false /// when changed letters in search bar, but already is finding, wait until finished.
    
    var cameraChanged: ((Bool) -> Void)?
    var savePressed = false
    var cachePressed = false
    
    let deviceType = UIDevice.current.modelName
    
    
    var normalSearchFieldTopCConstant = CGFloat(0)
    var displayingOrientationError = false
    
    ///PINCHING
//    @IBOutlet weak var controlsBottomC: NSLayoutConstraint! //15
    
    @IBOutlet weak var contentTopC: NSLayoutConstraint!
    //15
    
//    @IBOutlet var pinchGesture: UIPinchGestureRecognizer!
    var shouldPinch = true
//    @IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
//        controlsBottomC.constant = 15 - (sender.scale * 50)
//        contentTopC.constant = normalSearchFieldTopCConstant - (sender.scale * 50)
//        UIView.animate(withDuration: 0.2, animations: {
//            self.view.layoutIfNeeded()
//        })
//        if sender.state == UIGestureRecognizer.State.ended {
//            if sender.scale >= 1.3 {
//                controlsBottomC.constant = -80
//                contentTopC.constant = -100
//                searchContentView.isHidden = false
//                controlsView.isHidden = false
//
//                controlsBlurView.isHidden = false
//                controlsBlurView.alpha = 0
//                UIView.animate(withDuration: 0.4, animations: {
//                    self.view.layoutIfNeeded()
//                    self.searchContentView.alpha = 0
//                    self.controlsView.alpha = 0
//
//                    self.controlsBlurView.alpha = 1
//                    self.controlsBlurView.transform = CGAffineTransform.identity
//                }) { _ in
//                    self.searchContentView.isHidden = true
//                    self.controlsView.isHidden = true
//                    self.shouldPinch = true
//                }
//            } else {
//                revealControls()
//            }
//        }
        
//    }
    @IBOutlet weak var controlsBlurView: UIVisualEffectView!
    
    @IBAction func showControlsPressed(_ sender: Any) {
        revealControls()
    }
    
    func revealControls() {
//        searchContentView.isHidden = false
//        controlsView.isHidden = false
//        controlsBlurView.isHidden = true
//        controlsBottomC.constant = 15
//        contentTopC.constant = normalSearchFieldTopCConstant
//        UIView.animate(withDuration: 0.4, animations: {
//            self.view.layoutIfNeeded()
//            self.searchContentView.alpha = 1
//            self.controlsView.alpha = 1
//            
//            self.controlsBlurView.alpha = 0
//            self.controlsBlurView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
//        }) { _ in
//            self.controlsBlurView.isHidden = true
//        }
    }
    
    
    @IBOutlet weak var darkBlurEffect: UIVisualEffectView!
    
    let defaults = UserDefaults.standard
    var shouldShowTextDetectIndicator = true
    var shouldHapticFeedback = true
    
    
    //MARK: Stats
    weak var updateStatsNumber: UpdateMatchesNumberStats?
    var currentNumberOfMatches = 0
    lazy var statsNavController: StatsNavController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "StatsViewController") as? StatsViewController {
            let navigationController = StatsNavController(rootViewController: viewController)
            navigationController.viewController = viewController
            return navigationController
        }
        fatalError()
    }()
    
    var newNumberOfMatchesFound = 0
    var existingNumberOfMatchesFound = 0
    
    
    //MARK: Timer and haptic feedback
    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    //MARK: Toolbar
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var currentContentsOfScreen = ""
    var shouldResetHighlights = false
    
    //MARK: Keyboard
    let toolbar = ListToolBar()
    var toolbarWidthC: Constraint?
    var toolbarLeftC: Constraint?
    var toolbarTopC: Constraint?
    var didFinishShouldUpdateHeight = false
    
    //MARK: Search Bar
    var focusingList = EditableFindList()
    
    var allowSearch = true /// orientation disable
    var allowSearchFocus = true /// disable when on different screen
    
    var insertingListsCount = 0
    var isSchedulingList = false
    
    @IBOutlet weak var searchContentView: UIView!
    
    @IBOutlet weak var searchBarLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchCollectionTopC: NSLayoutConstraint!
    @IBOutlet weak var searchCollectionRightC: NSLayoutConstraint!
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var warningHeightC: NSLayoutConstraint!
    var searchShrunk = true
    
    @IBOutlet weak var alternateWarningView: UIView!
    @IBOutlet weak var alternateWarningLabel: UILabel!
    @IBOutlet weak var alternateWarningHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var whatsNewView: UIView!
    @IBOutlet weak var whatsNewButton: UIButton!
    @IBOutlet weak var whatsNewHeightC: NSLayoutConstraint!
    @IBAction func whatsNewPressed(_ sender: Any) {
        if shouldPresentWhatsNew {
            dismissWhatsNew(completion: {
                self.displayWhatsNew()
            })
        }
    }
    
    @IBOutlet weak var newSearchTextField: TextField!
    @IBOutlet weak var searchTextTopC: NSLayoutConstraint! ///starts at 8
    @IBOutlet weak var searchTextLeftC: NSLayoutConstraint!
    @IBOutlet weak var searchContentViewHeight: NSLayoutConstraint!
    
    //MARK: Lists
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var listsLabel: UILabel!
    @IBOutlet weak var tapToRemoveLabel: UILabel!
    @IBOutlet weak var arrowDownImage: UIImageView!
    
    var selectedLists = [EditableFindList]()
    weak var injectListDelegate: InjectLists?
    
    var previousNumberOfMatches: Int = 0
    
    
    var blurView = UIVisualEffectView()
    
    ///Detect if the view controller attempted to dismiss, but didn't
    var hasStartedDismissing = false
    var cancelSeconds = 0
    var cancelTimer : Timer?
    
    //MARK: Motion and AR Engine
    var motionManager = CMMotionManager()
    var motionXAsOfHighlightStart = Double(0) ///     X
    var motionYAsOfHighlightStart = Double(0) ///     Y
    var motionZAsOfHighlightStart = Double(0) ///     Z
    
    @IBOutlet weak var drawingView: UIView!
    
    //MARK: FAST MODE
    var busyFastFinding = false
    var startFastFinding = false
    var tempComponents = [Component]()
    var currentComponents = [Component]()
    var nextComponents = [Component]()
    var numberOfFastMatches: Int = 0
    
    var highlightColor = "00aeef"
    
    var matchToColors = [String: [CGColor]]()
    
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var stringToList = [String: EditableFindList]()
    var aspectRatioWidthOverHeight : CGFloat = 0
    
    var statusBarHidden : Bool = false
    var finalTextToFind : String = ""
    let deviceSize = screenBounds.size
    var globalUrl : URL = URL(fileURLWithPath: "")
    
    // MARK: Caching
    var startedCaching = false
    var cachedContents = [EditableSingleHistoryContent]()
    var currentCachingProcess: UUID?
    var finishedCaching = false
    var currentProgress = CGFloat(0) /// how much cache is finished
    
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var highlightsFromCache = [Component]() /// highlights that were from the cache

    
    //MARK: Camera
    @IBOutlet weak var pausedImageView: UIImageView!
    
    let avSession = AVCaptureSession()
    var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var captureCompletionBlock: ((UIImage) -> Void)?
    var cameraDevice: AVCaptureDevice?
    var allowedToAccessPhotos = false /// photos permissions
    
    //MARK: Camera Focus allowed views
    @IBOutlet weak var cameraView: CameraView!
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: Tips
    var cacheTipView: EasyTipView?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .pageSheet
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    func capturePhoto(completion: ((UIImage) -> Void)?) {
        captureCompletionBlock = completion
    }
    var initialAttitude: CMAttitude?
    
    override var prefersStatusBarHidden: Bool {
        return true  
    }
 
    override func viewWillLayoutSubviews() {
        cameraView.videoPreviewLayer.frame = self.view.bounds
        if let connection = cameraView.videoPreviewLayer.connection {
            if connection.isVideoOrientationSupported {
                if let orientation = statusBarOrientation {
                    connection.videoOrientation = self.interfaceOrientation(toVideoOrientation: orientation)
                    if orientation != .portrait {
                        displayingOrientationError = true
                        newSearchTextField.isEnabled = false
                        updateMatchesNumber(to: 0)
                        
                        resetHighlights()
                        shouldResetHighlights = true
                        
                        alternateWarningHeightC.constant = 70
                        UIView.animate(withDuration: 0.5, animations: {
                            self.alternateWarningView.alpha = 1
                            self.alternateWarningLabel.alpha = 1
                            self.alternateWarningView.layoutIfNeeded()
                        })
                    } else {
                        if displayingOrientationError == true {
                            displayingOrientationError = false
                            newSearchTextField.isEnabled = true
                            
                            shouldResetHighlights = false
                            alternateWarningHeightC.constant = 0
                            UIView.animate(withDuration: 0.5, animations: {
                                self.alternateWarningView.alpha = 0
                                self.alternateWarningLabel.alpha = 0
                                self.alternateWarningView.layoutIfNeeded()
                            })
                        }
                    }
                }
            }
        }
    }
    var statusBarOrientation: UIInterfaceOrientation? {
        get {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                #if DEBUG
                fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
                #else
                return nil
                #endif
            }
            return orientation
        }
    }
    func interfaceOrientation(toVideoOrientation orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            break
        }
        print("Warning - Didn't recognise interface orientation (\(orientation))")
        return .portrait
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraIconHolderBottomC.constant = ConstantVars.shutterBottomDistance
        
        cameraIcon.makeActiveState()()
        cameraIcon.rimView.layer.borderColor = UIColor.white.cgColor
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var hasNotch = false
        switch deviceType {
            case "iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone11,4", "iPhone11,6", "iPhone11,8", "iPhone12,3", "iPhone12,5":
                hasNotch = true
            default:
                break
        }
        if hasNotch {
            normalSearchFieldTopCConstant = -6
        } else {
            normalSearchFieldTopCConstant = 6
        }
        contentTopC.constant = normalSearchFieldTopCConstant
        searchContentView.layoutIfNeeded()
        
//        pinchGesture.delegate = self
        self.modalPresentationStyle = .automatic
        
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardFrameChanged(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        readDefaultsValues()
        
        controlsBlurView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        controlsBlurView.alpha = 0
        controlsBlurView.layer.cornerRadius = 8
        controlsBlurView.clipsToBounds = true
        controlsBlurView.isHidden = true
        updateMatchesNumber(to: 0)
        setupSearchBar()
        
        statsView.layer.cornerRadius = statsView.bounds.width / 2
        settingsView.layer.cornerRadius = settingsView.bounds.width / 2
        statsBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        settingsBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        
        
        configureCamera()
        busyFastFinding = false
        
        motionManager.deviceMotionUpdateInterval = 0.01
        
        if let deviceMot = motionManager.deviceMotion?.attitude {
            initialAttitude = deviceMot
        }

        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] (data, error) in
            if !CameraState.isPaused {
                guard let data = data, error == nil else {
                    return
                }
                self?.updateHighlightOrientations(attitude: data.attitude)
            }
        }
        
        /// call to pre load with images
//        preloadAllImages()
        
        whatsNewView.alpha = 0
        whatsNewView.layer.cornerRadius = 6
        whatsNewView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        whatsNewButton.alpha = 0
        
        if !keyValueVersionStore.has(version: WhatsNew.Version.current()) {
            keyValueVersionStore.set(version: WhatsNew.Version.current())
            
            /// not presented yet
            if updateImportantShouldPresentWhatsNew {
                shouldPresentWhatsNew = true
                whatsNewHeightC.constant = 32
                UIView.animate(withDuration: 1.5, animations: {
                    self.whatsNewView.alpha = 1
                    self.whatsNewButton.alpha = 1
                    self.whatsNewView.layoutIfNeeded()
                })
            }
            
        }
        
        /// 1.2 setup
        setupCameraButtons()
    }
    
    
    func makeActiveState() {
        UIView.animate(withDuration: 0.4) {
            self.saveToPhotos.alpha = 1
            self.saveToPhotos.transform = CGAffineTransform.identity
            self.cache.alpha = 1
            self.cache.transform = CGAffineTransform.identity
            self.saveLabel.alpha = 1
            self.cacheLabel.alpha = 1
        }
    }
    
    func makeInactiveState() {
        UIView.animate(withDuration: 0.4) {
            self.saveToPhotos.alpha = 0
            self.saveToPhotos.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.cache.alpha = 0
            self.cache.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.saveLabel.alpha = 0
            self.cacheLabel.alpha = 0
        }
    }
    
    // get magnitude of vector via Pythagorean theorem
    func getMagnitude(from attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) +
                pow(attitude.yaw, 2) +
                pow(attitude.pitch, 2))
    }

    func readDefaultsValues() {
        
        if let hexString = defaults.string(forKey: "highlightColor") {
            highlightColor = hexString
        }
        
        let showText = defaults.bool(forKey: "showTextDetectIndicator")
        let hapFeed = defaults.bool(forKey: "hapticFeedback")
        
        if showText {
            shouldShowTextDetectIndicator = true
        } else {
            shouldShowTextDetectIndicator = false
        }
        
        if hapFeed {
            shouldHapticFeedback = true
        } else {
            shouldHapticFeedback = false
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        currentPassCount += 1
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyFastFinding == false && allowSearch == true && displayingOrientationError == false && allowSearchFocus == true && CameraState.isPaused == false {
            
            /// 1. Find
            fastFind(in: pixelBuffer)
        }
        guard
            captureCompletionBlock != nil,
            let outputImage = UIImage(pixBuffer: pixelBuffer)
        else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let captureCompletionBlock = self.captureCompletionBlock {
                captureCompletionBlock(outputImage)
            }
            self.captureCompletionBlock = nil
        }
    }
}
extension UIImage {

    convenience init?(pixBuffer: CVPixelBuffer) {
        var ciImage = CIImage(cvPixelBuffer: pixBuffer)
        let transform = ciImage.orientationTransform(for: CGImagePropertyOrientation(rawValue: 6)!)
        ciImage = ciImage.transformed(by: transform)
        let size = ciImage.extent.size

        let screenSize: CGRect = screenBounds
        let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
