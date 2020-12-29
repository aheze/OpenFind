//
//  CameraViewController.swift
//  Find
//
//  Created by Zheng on 10/13/19.
//  Copyright © 2019 Zheng. All rights reserved.
//

import UIKit
import ARKit
import Vision
import AVFoundation
import CoreMotion
import RealmSwift
import SnapKit
import SwiftEntryKit
import WhatsNewKit

protocol ToggleCreateCircle: class {
    func toggle(created: Bool)
}
protocol UpdateMatchesNumberStats: class {
    func update(to: Int)
}
class CameraView: UIView {
    
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    // MARK: UIView
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}

class CameraViewController: UIViewController {
    
    let keyValueVersionStore = KeyValueWhatsNewVersionStore(keyValueable: UserDefaults.standard)
    let updateImportantShouldPresentWhatsNew = false
    var shouldPresentWhatsNew = false
    
    @IBOutlet weak var cameraIconHolder: UIView!
    @IBOutlet weak var cameraIconHolderBottomC: NSLayoutConstraint!
    
    @IBOutlet weak var messageView: MessageView!
    @IBOutlet weak var saveToPhotos: SaveToPhotosButton!
    @IBOutlet weak var cameraIcon: CameraIcon!
    @IBOutlet weak var cache: CacheButton!
    @IBOutlet weak var saveLabel: UILabel!
    @IBOutlet weak var cacheLabel: UILabel!
    
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
//    @IBOutlet weak var menuButton: JJFloatingActionButton!
//    @IBOutlet weak var newShutterButton: NewShutterButton!
    
    let defaults = UserDefaults.standard
    var shouldShowTextDetectIndicator = true
    var shouldHapticFeedback = true
    
    
    //MARK: Stats
    weak var updateStatsNumber: UpdateMatchesNumberStats?
    var currentNumberOfMatches = 0
    
    var newNumberOfMatchesFound = 0
    var existingNumberOfMatchesFound = 0
    
    
    //MARK: Timer and haptic feedback
//    var hapticFeedbackEnabled = true
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
    
//    var removeListMode = true
    var focusingList = EditableFindList()
    
    var allowSearch = true
    
    
    
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
//    weak var updateToolbar: UpdateToolbar?
    
    //MARK: Matches HUD
    
    var createdStatusView: Bool = false
    var previousNumberOfMatches: Int = 0
    //var shouldScale = true
    var currentNumber = 0
    var startGettingNearestFeaturePoints = false
    let fastSceneConfiguration = AROrientationTrackingConfiguration()
//    @IBOutlet weak var numberLabel: UILabel!
//    @IBOutlet weak var statusView: UIView!
//    weak var changeDelegate: ChangeStatusValue?
    weak var toggleCreateDelegate: ToggleCreateCircle?
    
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
    
    //MARK: Every mode (Universal)
    var statusBarHidden : Bool = false
    var finalTextToFind : String = ""
    let deviceSize = screenBounds.size
    ///Save the image
    var globalUrl : URL = URL(fileURLWithPath: "")

    
    //MARK: New Camera no Sceneview
    var previewTempImageView = UIImageView()
    let avSession = AVCaptureSession()
    var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var captureCompletionBlock: ((UIImage) -> Void)?
    var cameraDevice: AVCaptureDevice?
    
    //MARK: Camera Focus allowed views
//    @IBOutlet weak var menuAllowView: UIView!
//    @IBOutlet weak var middleAllowView: UIView!
//    @IBOutlet weak var statusAllowView: UIView!
//    @IBOutlet weak var stackAllowView: UIStackView!
//    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var cameraView: CameraView!
    let videoDataOutput = AVCaptureVideoDataOutput()
    func getImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
       guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
           return nil
       }
       CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
       let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
       let width = CVPixelBufferGetWidth(pixelBuffer)
       let height = CVPixelBufferGetHeight(pixelBuffer)
       let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
       let colorSpace = CGColorSpaceCreateDeviceRGB()
       let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
       guard let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
           return nil
       }
       guard let cgImage = context.makeImage() else {
           return nil
       }
       let image = UIImage(cgImage: cgImage, scale: 1, orientation:.right)
       CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        return image
    }
    private func getCamera() -> AVCaptureDevice? {
        if let cameraDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                for: .video, position: .back) {
            return cameraDevice
        } else if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video, position: .back) {
            return cameraDevice
        } else {
            print("Missing Camera.")
            return nil
        }
    }
    private func configureCamera() {
        cameraView.session = avSession
        if let cameraDevice = getCamera() {
            do {
                let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
                if avSession.canAddInput(captureDeviceInput) {
                    avSession.addInput(captureDeviceInput)
                }
            }
            catch {
                print("Error occured \(error)")
                return
            }
            avSession.sessionPreset = .photo
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Buffer Queue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil))
            if avSession.canAddOutput(videoDataOutput) {
                avSession.addOutput(videoDataOutput)
            }
            cameraView.videoPreviewLayer.videoGravity = .resizeAspectFill
            let newBounds = view.layer.bounds
            cameraView.videoPreviewLayer.bounds = newBounds
            print(cameraView.videoPreviewLayer.bounds)
            cameraView.videoPreviewLayer.position = CGPoint(x: newBounds.midX, y: newBounds.midY);
            avSession.startRunning()
        }
    }
    func startSession() { if !avSession.isRunning {
//        print("not running avsession")
        DispatchQueue.global().async { self.avSession.startRunning() } } }
    func stopSession() {
        if avSession.isRunning {
            DispatchQueue.global().async {
                self.avSession.stopRunning()
            }
        }
    }
    
    
    @objc private func _KeyboardFrameChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            var shouldFade = false
            if didFinishShouldUpdateHeight {
                self.toolbarTopC?.update(offset: rect.origin.y - 80)
                if rect.width == CGFloat(0) {
                    shouldFade = true
                }
            }
            if rect.width != CGFloat(0) {
                self.toolbarWidthC?.update(offset: rect.width)
                self.toolbarLeftC?.update(offset: rect.origin.x)
            }
            UIView.animate(withDuration: 0.6, animations: {
                if rect.width < screenBounds.size.width {
                    self.toolbar.layer.cornerRadius = 5
                } else {
                    self.toolbar.layer.cornerRadius = 0
                }
                if shouldFade == true {
                    self.toolbar.alpha = 0
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    @objc private func _KeyboardHeightChanged(_ notification: Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            UIView.animate(withDuration: 0.5, animations: {
                let rect = frame.cgRectValue
                if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                    if let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                        if rect.width == CGFloat(0) {
                            self.didFinishShouldUpdateHeight = true
                        } else {
                            self.didFinishShouldUpdateHeight = false
                            self.toolbarTopC?.update(offset: rect.origin.y - 80)
                            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                                if rect.origin.y == screenBounds.size.height {
                                    self.toolbar.alpha = 0
                                } else {
                                    self.toolbar.alpha = 1
                                }
                                self.view.layoutIfNeeded()
                            }, completion: nil)
                        }
                    }
                }
            })
        }
    }
    
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
                        
                        resetFastHighlights()
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
            normalSearchFieldTopCConstant = 0
        } else {
            normalSearchFieldTopCConstant = 12
//            normalSearchFieldTopCConstant = 22
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
//        numberLabel.isHidden = false
        updateMatchesNumber(to: 0)
//        setUpButtons()
        setUpTempImageView()
        setUpSearchBar()
        setUpFilePath()
        
        
        /// is already athorized in Launchscreen
//        if isAuthorized() {
            configureCamera()
//        }
        busyFastFinding = false
        
//        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.01
       //  initial configuration
        if let deviceMot = motionManager.deviceMotion?.attitude {
            initialAttitude = deviceMot
        }

        motionManager.startDeviceMotionUpdates(to: .main) {
            [weak self] (data, error) in
            guard let data = data, error == nil else {
                return
            }
            self?.updateHighlightOrientations(attitude: data.attitude)
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
        
        cameraIconHolder.backgroundColor = UIColor.clear
        cameraIcon.isActualButton = true
        cameraIcon.pressed = { [weak self] in
            guard let self = self else { return }
            CameraState.isOn.toggle()
            self.cameraIcon.toggle(on: CameraState.isOn)
            self.cameraChanged?(CameraState.isOn)
        }
        saveToPhotos.alpha = 0
        saveToPhotos.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        cache.alpha = 0
        cache.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        saveLabel.alpha = 0
        cacheLabel.alpha = 0
        
        saveToPhotos.pressed = { [weak self] in
            guard let self = self else { return }
            self.savePressed.toggle()
            if self.savePressed {
                UIView.animate(withDuration: Double(Constants.transitionDuration)) {
                    self.saveToPhotos.photosIcon.makeActiveState(offset: true)()
                }
                self.saveLabel.fadeTransition(0.2)
                self.saveLabel.text = "Saved"
            } else {
                UIView.animate(withDuration: Double(Constants.transitionDuration)) {
                    self.saveToPhotos.photosIcon.makeNormalState(details: Constants.detailIconColorDark, foreground: Constants.foregroundIconColorDark, background: Constants.backgroundIconColorDark)()
                }
                self.saveLabel.fadeTransition(0.2)
                self.saveLabel.text = "Save"
            }
        }
        cache.pressed = { [weak self] in
            guard let self = self else { return }
            self.cachePressed.toggle()
            if self.cachePressed {
                self.cache.cacheIcon.animateCheck(percentage: 1)
                self.cache.cacheIcon.toggleRim(light: true)
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Caching..."
                self.messageView.showMessage("Caching - 50%", dismissible: false, duration: -1)
            } else {
                self.cache.cacheIcon.animateCheck(percentage: 0)
                self.cache.cacheIcon.toggleRim(light: false)
                self.cacheLabel.fadeTransition(0.2)
                self.cacheLabel.text = "Cache"
                self.messageView.showMessage("Cancelled", dismissible: true, duration: 1)
            }
        }
        
        
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
        if busyFastFinding == false && allowSearch == true && displayingOrientationError == false {
            
            /// 1. Find
            fastFind(in: pixelBuffer)
        }
        guard captureCompletionBlock != nil,
            let outputImage = UIImage(pixBuffer: pixelBuffer) else { return }
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
