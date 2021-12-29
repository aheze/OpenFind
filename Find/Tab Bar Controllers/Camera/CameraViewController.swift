//
//  CameraViewController.swift
//  Find
//
//  Created by Zheng on 10/13/19.
//  Copyright © 2019 Zheng. All rights reserved.
//

import AVFoundation
import CoreMotion
import RealmSwift
import SnapKit
import UIKit
import Vision
import WhatsNewKit

protocol ToggleCreateCircle: class {
    func toggle(created: Bool)
}

class CameraViewController: UIViewController {
    let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
    let updateImportantShouldPresentWhatsNew = true
    var shouldPresentWhatsNew = false
    
    // MARK: Accessibility

    @IBOutlet var statsWidthC: NSLayoutConstraint!
    @IBOutlet var statsHeightC: NSLayoutConstraint!
    @IBOutlet var fullScreenWidthC: NSLayoutConstraint!
    @IBOutlet var fullScreenHeightC: NSLayoutConstraint!
    @IBOutlet var flashWidthC: NSLayoutConstraint!
    @IBOutlet var flashHeightC: NSLayoutConstraint!
    @IBOutlet var settingsWidthC: NSLayoutConstraint!
    @IBOutlet var settingsHeightC: NSLayoutConstraint!
    var controlsView: UIView?
    
    @IBOutlet var cameraGroupView: UIView!
    var showingTranscripts = false
    var currentTranscriptComponents = [Component]()
    var previousActivatedHighlight: Component?
    
    @IBOutlet var topGroupView: UIView!
    @IBOutlet var searchBackgroundView: UIView!
    
    override func accessibilityPerformMagicTap() -> Bool {
        toggleShutter()
        return true
    }
    
    // MARK: Tab bar

    @IBOutlet var cameraIconHolder: UIView!
    @IBOutlet var cameraIconHolderBottomC: NSLayoutConstraint!
    
    @IBOutlet var messageView: MessageView!
    @IBOutlet var messageViewBottomC: NSLayoutConstraint!
    @IBOutlet var saveToPhotos: SaveToPhotosButton!
    @IBOutlet var cameraIcon: CameraIcon!
    @IBOutlet var cache: CacheButton!
    @IBOutlet var saveLabel: UILabel!
    @IBOutlet var cacheLabel: UILabel!
    
    var statsFocused = false
    var statsShouldAnnounce = false
    @IBOutlet var statsView: StatsView!
    @IBOutlet var statsBottomC: NSLayoutConstraint!
    
    @IBOutlet var statsButton: CustomButton!
    @IBOutlet var statsLabel: LTMorphingLabel!
    @IBAction func statsButtonPressed(_ sender: Any) {
        tappedOnStats()
    }
    
    @IBOutlet var fullScreenView: UIView!
    @IBOutlet var fullScreenButton: CustomButton!
    @IBOutlet var fullScreenImageView: UIImageView!
    
    var isFullScreen = false
    @IBOutlet var fullScreenTopC: NSLayoutConstraint!
    @IBOutlet var fullScreenLeftNeighborC: NSLayoutConstraint!
    @IBOutlet var fullScreenLeftC: NSLayoutConstraint!
    @IBOutlet var fullScreenBottomC: NSLayoutConstraint!
    @IBAction func fullScreenButtonPressed(_ sender: Any) {
        isFullScreen.toggle()
        toggleFullScreen(isFullScreen)
    }
    
    var flashlightOn = false
    @IBOutlet var flashView: UIView!
    @IBOutlet var flashDisableIcon: FlashDisableIcon!
    @IBOutlet var flashButton: CustomButton!
    @IBOutlet var flashImageView: UIImageView!
    @IBOutlet var flashTopC: NSLayoutConstraint!
    @IBOutlet var flashRightNeighborC: NSLayoutConstraint!
    @IBOutlet var flashRightC: NSLayoutConstraint!
    @IBOutlet var flashBottomC: NSLayoutConstraint!
    @IBAction func flashButtonPressed(_ sender: Any) {
        flashlightOn.toggle()
        toggleFlashlight(flashlightOn)
    }
    
    var cameBackFromSettings: (() -> Void)?
    @IBOutlet var settingsView: UIView!
    @IBOutlet var settingsBottomC: NSLayoutConstraint!
    
    @IBOutlet var settingsImageView: UIImageView!
    @IBOutlet var settingsButton: CustomButton!
    @IBAction func settingsButtonPressed(_ sender: Any) {
        setupSettings()
    }
    
    var currentPausedImage: UIImage?
    var waitingToFind = false /// when changed letters in search bar, but already is finding, wait until finished.
    
    /// paused, shouldFadeActionButtons
    var cameraChanged: ((Bool, Bool) -> Void)?
    var savePressed = false
    var cachePressed = false
    
    var normalSearchFieldTopCConstant = CGFloat(0)
    var displayingOrientationError = false
    
    @IBOutlet var contentTopC: NSLayoutConstraint!
    
    @IBOutlet var controlsBlurView: UIVisualEffectView!
    @IBOutlet var controlsBlurBottomC: NSLayoutConstraint!
    @IBOutlet var showControlsButton: UIButton!
    @IBAction func showControlsPressed(_ sender: Any) {
        isFullScreen = false
        toggleFullScreen(isFullScreen)
    }
    
    @IBOutlet var passthroughGroupView: passthroughGroupView!
    @IBOutlet var passthroughBottomC: NSLayoutConstraint!
    
    // MARK: Stats

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
    
    // MARK: Camera focusing

    @IBOutlet var focusGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var focusView: UIView!
    @IBAction func handleFocusGesture(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .ended else { return }
        let location = sender.location(in: focusView)
        let focusPoint = cameraView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: location) /// might be reversed horizontally
        
        if let device = cameraDevice {
            do {
                try device.lockForConfiguration()
                
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                device.unlockForConfiguration()
            } catch {}
        }
        
        let focusViewIndicator = CameraFocusView()
        let focusLength: CGFloat = 100
        let halfFocusLength = focusLength / 2
        
        focusViewIndicator.frame = CGRect(x: location.x - halfFocusLength, y: location.y - halfFocusLength, width: focusLength, height: focusLength)
        
        focusViewIndicator.alpha = 0
        
        focusViewIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        let existingFocusViews = focusView.subviews
        focusView.addSubview(focusViewIndicator)
        
        UIView.animate(withDuration: 0.2) {
            for existingFocusView in existingFocusViews {
                existingFocusView.alpha = 0
                existingFocusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveLinear) {
            focusViewIndicator.alpha = 1
            focusViewIndicator.transform = CGAffineTransform.identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveLinear) {
                    focusViewIndicator.alpha = 0
                    focusViewIndicator.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                } completion: { _ in
                    for existingFocusView in self.focusView.subviews {
                        if existingFocusView.alpha == 0 {
                            existingFocusView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Timer and haptic feedback

    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    // MARK: Toolbar

    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    
    // MARK: Keyboard

    var toolbar: ListToolBar?
    
    // MARK: Search Bar

    var allowSearch = true /// orientation disable
    var allowSearchFocus = true /// disable when on different screen
    var insertingListsCount = 0
    var isSchedulingList = false
    
    @IBOutlet var searchContentView: UIView!
    @IBOutlet var searchBarLayout: UICollectionViewFlowLayout!
    
    @IBOutlet var searchCollectionView: UICollectionView!
    @IBOutlet var searchCollectionTopC: NSLayoutConstraint!
    @IBOutlet var searchCollectionRightC: NSLayoutConstraint!
    
    // MARK: Prompts

    @IBOutlet var promptContainerView: passthroughGroupView!
    
    @IBOutlet var warningView: UIView!
    @IBOutlet var warningLabel: UILabel!
    @IBOutlet var warningHeightC: NSLayoutConstraint!
    
    var searchShrunk = true
    
    @IBOutlet var alternateWarningView: UIView!
    @IBOutlet var alternateWarningLabel: UILabel!
    @IBOutlet var alternateWarningHeightC: NSLayoutConstraint!
    
    @IBOutlet var whatsNewView: UIView!
    @IBOutlet var whatsNewButton: UIButton!
    @IBOutlet var whatsNewHeightC: NSLayoutConstraint!
    @IBAction func whatsNewPressed(_ sender: Any) {
        if shouldPresentWhatsNew {
            dismissWhatsNew(completion: {
                self.displayWhatsNew()
            })
        }
    }
    
    var temporaryPreventGestures: ((Bool) -> Void)?
    @IBOutlet var newSearchTextField: TextField!
    @IBOutlet var searchTextTopC: NSLayoutConstraint! /// starts at 8
    @IBOutlet var searchTextLeftC: NSLayoutConstraint!
    @IBOutlet var searchContentViewHeight: NSLayoutConstraint!
    
    // MARK: Lists

    @IBOutlet var listsDownIndicatorView: UIView!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var listsLabel: UILabel!
    @IBOutlet var tapToRemoveLabel: UILabel!
    @IBOutlet var arrowDownImage: UIImageView!
    
    var selectedLists = [EditableFindList]()
    weak var injectListDelegate: InjectLists?
    
    var previousNumberOfMatches: Int = 0
    
    var blurView = UIVisualEffectView()
    
    // MARK: Motion and AR Engine

    var motionManager = CMMotionManager()
    var motionXAsOfHighlightStart = Double(0) ///     X
    var motionYAsOfHighlightStart = Double(0) ///     Y
    var motionZAsOfHighlightStart = Double(0) ///     Z
    
    @IBOutlet var drawingBaseView: CustomActionsView!
    @IBOutlet var drawingView: DrawingView!
    
    // MARK: FAST MODE

    var busyFastFinding = false
    var currentComponents = [Component]()
    var pixelBufferSize = CGSize(width: 0, height: 0)
    
    /// scale + haptic feedback
    var canNotify = false
    
    var matchToColors = [String: [HighlightColor]]()
    
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var aspectRatioWidthOverHeight: CGFloat = 0
    
    var finalTextToFind: String = ""
    let deviceSize = screenBounds.size
    var globalUrl: URL = .init(fileURLWithPath: "")
    
    // MARK: Caching

    var startedCaching = false
    var cachedComponents = [Component]()
    var rawCachedContents = [EditableSingleHistoryContent]() /// raw vision coordinates to save to disk
    var currentCachingProcess: UUID?
    var finishedCaching = false
    var currentProgress = CGFloat(0) /// how much cache is finished
    
    var numberCurrentlyFindingFromCache = 0 /// how many cache findings are currently going on
    var highlightsFromCache = [Component]() /// highlights that were from the cache
    
    // MARK: Camera

    var currentlyCapturing = false
    @IBOutlet var pausedImageView: UIImageView!
    
    let avSession = AVCaptureSession()
    private var captureCompletionBlock: ((UIImage) -> Void)?
    var cameraDevice: AVCaptureDevice?
    
    // MARK: Camera Focus allowed views

    @IBOutlet var cameraView: CameraView!
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoDataOutput = AVCapturePhotoOutput()
    
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
        cameraView.videoPreviewLayer.frame = view.bounds
        if let connection = cameraView.videoPreviewLayer.connection {
            if connection.isVideoOrientationSupported {
                if let orientation = statusBarOrientation {
                    connection.videoOrientation = interfaceOrientation(toVideoOrientation: orientation)
                    if orientation != .portrait {
                        displayingOrientationError = true
                        newSearchTextField.isEnabled = false
                        resetHighlights()
                        
                        alternateWarningHeightC.constant = 70
                        UIView.animate(withDuration: 0.5, animations: {
                            self.alternateWarningView.alpha = 1
                            self.alternateWarningLabel.alpha = 1
                            self.alternateWarningView.layoutIfNeeded()
                        }) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                UIAccessibility.post(notification: .layoutChanged, argument: self.warningView)
                            }
                        }
                    } else {
                        if displayingOrientationError == true {
                            displayingOrientationError = false
                            newSearchTextField.isEnabled = true
                            
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
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
#if DEBUG
            fatalError("Could not obtain UIInterfaceOrientation from a valid windowScene")
#else
            return nil
#endif
        }
        return orientation
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

        return .portrait
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cameraIconHolderBottomC.constant = FindConstantVars.shutterBottomDistance
        
        cameraIcon.makeActiveState()()
//        cameraIcon.rimView.layer.borderColor = UIColor.white.cgColor
        
        adjustButtonLayout(CameraState.isPaused, animate: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if deviceHasNotch, !deviceIsRoundPad {
            if isForcingStatusBarHidden {
                normalSearchFieldTopCConstant = -16
            } else {
                normalSearchFieldTopCConstant = -2
            }
        } else {
            if isForcingStatusBarHidden {
                normalSearchFieldTopCConstant = -6
            } else {
                normalSearchFieldTopCConstant = 6
            }
        }
        
        focusGestureRecognizer.delegate = self
        
        contentTopC.constant = normalSearchFieldTopCConstant
        searchContentView.layoutIfNeeded()
        
        controlsBlurView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        controlsBlurView.effect = nil
        showControlsButton.alpha = 0
        controlsBlurView.layer.cornerRadius = controlsBlurView.bounds.height / 2
        controlsBlurView.clipsToBounds = true
        
        updateMatchesNumber(to: 0, tapHaptic: false)
        setupSearchBar()
        
        statsView.layer.cornerRadius = statsView.bounds.width / 2
        fullScreenView.layer.cornerRadius = fullScreenView.bounds.width / 2
        flashView.layer.cornerRadius = flashView.bounds.width / 2
        settingsView.layer.cornerRadius = settingsView.bounds.width / 2
        
        statsBottomC.constant = CGFloat(FindConstantVars.tabHeight) + 8
        fullScreenBottomC.constant = CGFloat(FindConstantVars.tabHeight) + 8
        flashBottomC.constant = CGFloat(FindConstantVars.tabHeight) + 8
        settingsBottomC.constant = CGFloat(FindConstantVars.tabHeight) + 8
        
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
            [weak self] data, error in
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
                }) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        UIAccessibility.post(notification: .layoutChanged, argument: self.warningView)
                    }
                }
            }
        }
        
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(currentVersion, forKey: "CurrentAppVersion")
        }
        
        /// 1.2 setup
        setupCameraButtons()
        
        setupAccessibility()
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
        if busyFastFinding == false, allowSearch == true, displayingOrientationError == false, allowSearchFocus == true, CameraState.isPaused == false {
            /// 1. Find
            fastFind(in: pixelBuffer)
        }
    }
}

/// not used
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

/// not used
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
