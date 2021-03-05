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

protocol ToggleCreateCircle: class {
    func toggle(created: Bool)
}
protocol UpdateMatchesNumberStats: class {
    func update(to: Int)
}


class CameraViewController: UIViewController {
    
    let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
    let updateImportantShouldPresentWhatsNew = true
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
    
    @IBOutlet weak var statsButton: CustomButton!
    @IBOutlet weak var statsLabel: LTMorphingLabel!
    @IBAction func statsButtonPressed(_ sender: Any) {
        tappedOnStats()
    }
    
    @IBOutlet weak var fullScreenView: UIView!
    @IBOutlet weak var fullScreenButton: CustomButton!
    @IBOutlet weak var fullScreenImageView: UIImageView!
    
    var isFullScreen = false
    @IBOutlet weak var fullScreenTopC: NSLayoutConstraint!
    @IBOutlet weak var fullScreenLeftNeighborC: NSLayoutConstraint!
    @IBOutlet weak var fullScreenLeftC: NSLayoutConstraint!
    @IBOutlet weak var fullScreenBottomC: NSLayoutConstraint!
    @IBAction func fullScreenButtonPressed(_ sender: Any) {
        isFullScreen.toggle()
        toggleFullScreen(isFullScreen)
    }
    
    
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var flashButton: CustomButton!
    @IBOutlet weak var flashImageView: UIImageView!
    @IBOutlet weak var flashTopC: NSLayoutConstraint!
    @IBOutlet weak var flashRightNeighborC: NSLayoutConstraint!
    @IBOutlet weak var flashRightC: NSLayoutConstraint!
    @IBOutlet weak var flashBottomC: NSLayoutConstraint!
    @IBAction func flashButtonPressed(_ sender: Any) {
    }
    
    
    
    var cameBackFromSettings: (() -> Void)?
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsBottomC: NSLayoutConstraint!
    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var settingsButton: CustomButton!
    @IBAction func settingsButtonPressed(_ sender: Any) {
        let settingsVC = SettingsViewHoster()
        settingsVC.presentationController?.delegate = self
        settingsVC.dismissed = { [weak self] in
            self?.cameBackFromSettings?()
        }
        self.present(settingsVC, animated: true)
    }
    
    var currentPausedImage: UIImage?
    var waitingToFind = false /// when changed letters in search bar, but already is finding, wait until finished.
    
    /// paused, shouldFadeActionButtons
    var cameraChanged: ((Bool, Bool) -> Void)?
    var savePressed = false
    var cachePressed = false
    
    var normalSearchFieldTopCConstant = CGFloat(0)
    var displayingOrientationError = false
    
    @IBOutlet weak var contentTopC: NSLayoutConstraint!
    
    @IBOutlet weak var controlsBlurView: UIVisualEffectView!
    @IBOutlet weak var controlsBlurBottomC: NSLayoutConstraint!
    @IBOutlet weak var showControlsButton: UIButton!
    @IBAction func showControlsPressed(_ sender: Any) {
        isFullScreen = false
        toggleFullScreen(isFullScreen)
    }
    
    
    @IBOutlet weak var passthroughBottomC: NSLayoutConstraint!
    
    
    
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
    
    //MARK: Timer and haptic feedback
    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    //MARK: Toolbar
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var shouldResetHighlights = false
    
    //MARK: Keyboard
    let toolbar = ListToolBar()
    var toolbarWidthC: Constraint?
    var toolbarLeftC: Constraint?
    var toolbarTopC: Constraint?
    var didFinishShouldUpdateHeight = false
    
    //MARK: Search Bar
    
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
    
    var temporaryPreventGestures: ((Bool) -> Void)?
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
    
    //MARK: Motion and AR Engine
    var motionManager = CMMotionManager()
    var motionXAsOfHighlightStart = Double(0) ///     X
    var motionYAsOfHighlightStart = Double(0) ///     Y
    var motionZAsOfHighlightStart = Double(0) ///     Z
    
    @IBOutlet weak var drawingView: UIView!
    
    //MARK: FAST MODE
    var busyFastFinding = false
    var tempComponents = [Component]()
    var currentComponents = [Component]()
    var nextComponents = [Component]()
    
    var matchToColors = [String: [CGColor]]()
    
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var aspectRatioWidthOverHeight : CGFloat = 0
    
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
    private var captureCompletionBlock: ((UIImage) -> Void)?
    var cameraDevice: AVCaptureDevice?
    
    //MARK: Camera Focus allowed views
    @IBOutlet weak var cameraView: CameraView!
    let videoDataOutput = AVCaptureVideoDataOutput()
    
    // MARK: Tips
    var cacheTipView: EasyTipView?
    var howManyTimesFastFoundSincePaused = 0 /// how many times fast found
    var dismissedCacheTipAlready = false /// if dismissed already, don't show again
    
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
        print("Warning - Didn't recognize interface orientation (\(orientation))")
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

        if deviceHasNotch && !deviceIsRoundPad {
            if isForcingStatusBarHidden {
                normalSearchFieldTopCConstant = -10
            } else {
                normalSearchFieldTopCConstant = -6
            }
        } else {
            if isForcingStatusBarHidden {
                normalSearchFieldTopCConstant = -6
            } else {
                normalSearchFieldTopCConstant = 6
            }
        }
        
        contentTopC.constant = normalSearchFieldTopCConstant
        searchContentView.layoutIfNeeded()
        
        self.modalPresentationStyle = .automatic
        
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardFrameChanged(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_KeyboardHeightChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        controlsBlurView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        controlsBlurView.effect = nil
        showControlsButton.alpha = 0
        controlsBlurView.layer.cornerRadius = 8
        controlsBlurView.clipsToBounds = true
        
        updateMatchesNumber(to: 0)
        setupSearchBar()
        
        statsView.layer.cornerRadius = statsView.bounds.width / 2
        fullScreenView.layer.cornerRadius = fullScreenView.bounds.width / 2
        flashView.layer.cornerRadius = flashView.bounds.width / 2
        settingsView.layer.cornerRadius = settingsView.bounds.width / 2
        
        
        statsBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        fullScreenBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        flashBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        settingsBottomC.constant = CGFloat(ConstantVars.tabHeight) + 8
        
        statsLabel.morphingEffect = .evaporate
        statsButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.statsLabel.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.statsLabel.alpha = 1
                })
            }
        }
        
        fullScreenButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.fullScreenImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.fullScreenImageView.alpha = 1
                })
            }
        }
        
        flashButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.flashImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.flashImageView.alpha = 1
                })
            }
        }
        
        settingsButton.touched = { [weak self] down in
            if down {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.settingsImageView.alpha = 0.5
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self?.settingsImageView.alpha = 1
                })
            }
        }
        
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
        
        
        whatsNewView.alpha = 0
        whatsNewView.layer.cornerRadius = 6
        whatsNewView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        whatsNewButton.alpha = 0
        
        let version = WhatsNew.Version(
            major: 1,
            minor: 2,
            patch: 0
        )
        
        if !keyValueVersionStore.has(version: version) {
            keyValueVersionStore.set(version: version)
            
            /// not presented yet
            if updateImportantShouldPresentWhatsNew {
                shouldPresentWhatsNew = true
                whatsNewHeightC.constant = 28
                UIView.animate(withDuration: 1.5, animations: {
                    self.whatsNewView.alpha = 1
                    self.whatsNewButton.alpha = 1
                    self.whatsNewView.layoutIfNeeded()
                })
            }
            
        }
        
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(currentVersion, forKey: "CurrentAppVersion")
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
