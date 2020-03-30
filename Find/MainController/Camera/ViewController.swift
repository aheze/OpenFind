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
import AVFoundation
import CoreMotion
import RealmSwift
import SnapKit

//protocol ChangeStatusValue: class {
//    func changeValue(to value: CGFloat)
//}
protocol ToggleCreateCircle: class {
    func toggle(created: Bool)
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
class ViewController: UIViewController {
    
    @IBOutlet weak var darkBlurEffect: UIVisualEffectView!
//    @IBOutlet weak var darkBlurEffectHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: JJFloatingActionButton!
    @IBOutlet weak var newShutterButton: NewShutterButton!
    
    let defaults = UserDefaults.standard
    
    
    //MARK: Timer and haptic feedback
    var hapticFeedbackEnabled = true
    var currentPassCount = 0 /// +1 whenever frame added for AV
    
    
    
    //MARK: Toolbar
    
//    @IBOutlet weak var listsToolbarLayout: UICollectionViewFlowLayout!
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    var editableListCategories = [EditableFindList]()
    var currentContentsOfScreen = ""
    
    
    
    var shouldResetHighlights = false
    
//    @IBOutlet weak var listsCollectionView: UICollectionView!
//    @IBOutlet weak var toolBar: UIView!
//    @IBOutlet weak var autoCompleteButton: UIButton!
//    @IBOutlet weak var cancelButtonNew: UIButton!
//    @IBOutlet weak var newMatchButton: UIButton!
//
//    @IBAction func cancelButtonPressed(_ sender: UIButton) {
//        removeAllLists()
//    }
//    @IBAction func autocompButtonPressed(_ sender: UIButton) {
//        view.endEditing(true)
//        if insertingListsCount == 0 {
//            updateListsLayout(toType: "doneAndShrink")
//        } else {
//            isSchedulingList = true
//        }
//    }
//    @IBAction func newMatchPressed(_ sender: Any) {
//        if let searchText = newSearchTextField.text {
//            newSearchTextField.text = "\(searchText)\u{2022}"
//        }
//
////        if let ramText = ramReel.textField.text {
////            ramReel.textField.text = "\(ramText)\u{2022}"
////        }
//    }
    
    //MARK: Search Bar
    
//    var removeListMode = true
    var focusingList = EditableFindList()
    
    var allowSearch = true
    
    var insertingListsCount = 0
    var isSchedulingList = false
    
    @IBOutlet weak var searchContentView: UIView!
    
    @IBOutlet weak var searchBarLayout: UICollectionViewFlowLayout!
    
//
    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchCollectionTopC: NSLayoutConstraint!
    @IBOutlet weak var searchCollectionRightC: NSLayoutConstraint!
    
    @IBOutlet weak var warningView: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var warningHeightC: NSLayoutConstraint!
    
    
    
    //    @IBOutlet var listsView: UIView!
//    @IBOutlet weak var listViewCollectionView: UICollectionView!
//
//    @IBOutlet var searchTextField: TextField!
//    @IBOutlet weak var searchTextBar: UIView!
    
    
    var searchShrunk = true
    
    @IBOutlet weak var newSearchTextField: TextField!
    @IBOutlet weak var searchTextTopC: NSLayoutConstraint! ///starts at 8
    @IBOutlet weak var searchTextLeftC: NSLayoutConstraint!
    //    var listsViewTop: Constraint? = nil
//    var listsViewLeft: Constraint? = nil
//    var listsViewWidth: Constraint? = nil
//    
//    var textFieldTop: Constraint? = nil
//    var textFieldLeft: Constraint? = nil
//    var textFieldWidth: Constraint? = nil
    
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
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
//    weak var changeDelegate: ChangeStatusValue?
    weak var toggleCreateDelegate: ToggleCreateCircle?
    
    var blurView = UIVisualEffectView()
    ///Detect if the view controller attempted to dismiss, but didn't
    var hasStartedDismissing = false
    var cancelSeconds = 0
    var cancelTimer : Timer?
    //var isCancelTimerRunning = false //This will be used to make sure only one timer is created at a time.
    
    //MARK: Motion and AR Engine
    var motionManager: CMMotionManager!
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
    
    var currentMatchStrings = [String]()
//    var currentMatchArray = [String]()
    var currentSearchFindList = EditableFindList()
    var currentListsSharedFindList = EditableFindList()
    var currentSearchAndListSharedFindList = EditableFindList()
    
    var stringToList = [String: EditableFindList]()
//    var containedList = [String]()
    
    var aspectRatioWidthOverHeight : CGFloat = 0
//    var aspectRatioSucceeded : Bool = false
//    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    //MARK: Every mode (Universal)
    var statusBarHidden : Bool = false
    var finalTextToFind : String = ""
    let deviceSize = UIScreen.main.bounds.size
    ///Save the image
    var globalUrl : URL = URL(fileURLWithPath: "")

    
    //MARK: New Camera no Sceneview
    var previewTempImageView = UIImageView()
    let avSession = AVCaptureSession()
    var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var captureCompletionBlock: ((UIImage) -> Void)?
    var cameraDevice: AVCaptureDevice?
    
    //MARK: Camera Focus allowed views
    @IBOutlet weak var menuAllowView: UIView!
    @IBOutlet weak var middleAllowView: UIView!
    @IBOutlet weak var statusAllowView: UIView!
    @IBOutlet weak var stackAllowView: UIStackView!
    @IBOutlet weak var controlsView: UIView!
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
            fatalError("Missing expected back camera device.")
            //return nil
        }
    }
    private func configureCamera() {
        cameraView.session = avSession
        cameraDevice = getCamera() 
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice!)
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
        //cameraView.videoPreviewLayer.position = CGPoint(x: 0.5, y: 0.5)
        //cameraView.videoPreviewLayer.frame = self.view.bounds
        let newBounds = view.layer.bounds
        //avLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        cameraView.videoPreviewLayer.bounds = newBounds
        print(cameraView.videoPreviewLayer.bounds)
        cameraView.videoPreviewLayer.position = CGPoint(x: newBounds.midX, y: newBounds.midY);
        avSession.startRunning()
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
    private func isAuthorized() -> Bool {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                          completionHandler: { (granted:Bool) -> Void in
                                            if granted {
                                                DispatchQueue.main.async {
                                                   // self.configureTextDetection()
                                                    self.configureCamera()
                                                }
                                            }
            })
            return true
        case .authorized:
            return true
        case .denied, .restricted: return false
        }
    }
    func capturePhoto(completion: ((UIImage) -> Void)?) {
        captureCompletionBlock = completion
    }
    // initial configuration
   
    var initialAttitude: CMAttitude?
    //var refAttitudeReferenceFrame: CMAttitudeReferenceFrame?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let hexString = defaults.string(forKey: "highlightColor") {
            highlightColor = hexString
            print("COLOR: \(hexString)")
        }
        
        
//        changeDelegate = statusView as? ChangeStatusValue
        
        
//        highlightColor
        
        numberLabel.isHidden = false
        updateMatchesNumber(to: 0)
       
//        loadListsRealm()
        setUpButtons()
        setUpTimers()
        
        setUpTempImageView()
        
//        setUpRamReel()
        setUpSearchBar()
        
        
        setUpFilePath()
        if isAuthorized() {
            configureCamera()
        }
        busyFastFinding = false
        
        motionManager = CMMotionManager()
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
            // translate the attitude
            self?.updateHighlightOrientations(attitude: data.attitude)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //classicHasFoundOne = false
        print("diss")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // get magnitude of vector via Pythagorean theorem
    func getMagnitude(from attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) +
                pow(attitude.yaw, 2) +
                pow(attitude.pitch, 2))
    }

    


}



extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    // MARK: - Camera Delegate and Setup
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        currentPassCount += 1
//        print("PASS: \(currentPassCount)")
        
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyFastFinding == false && allowSearch == true {
//            print("fastFind!!")
            fastFind(in: pixelBuffer)
        }
        
        
        guard captureCompletionBlock != nil,
            let outputImage = UIImage(pixBuffer: pixelBuffer) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let captureCompletionBlock = self.captureCompletionBlock {
                //print("askdh")
                captureCompletionBlock(outputImage)
                //AudioServicesPlayAlertSound(SystemSoundID(1108))
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

        let screenSize: CGRect = UIScreen.main.bounds
        let imageRect = CGRect(x: screenSize.origin.x, y: screenSize.origin.y, width: size.width, height: size.height)
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
//extension Notification.Name {
//     static let toggleCreateName = Notification.Name("toggleCreateName")
//}
