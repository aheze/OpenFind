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

protocol ChangeStatusValue: class {
    func changeValue(to value: CGFloat)
}
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
    @IBOutlet weak var darkBlurEffectHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: JJFloatingActionButton!
    @IBOutlet weak var newShutterButton: NewShutterButton!
    
    
    //MARK: Toolbar
    
    let realm = try! Realm()
    var listCategories: Results<FindList>?
    @IBOutlet weak var listsCollectionView: UICollectionView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var autoCompleteButton: UIButton!
    @IBOutlet weak var cancelButtonNew: UIButton!
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.ramReel.textField.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        }, completion: { _ in
            self.ramReel.textField.text = ""
            self.ramReel.textField.textColor = UIColor.white
        })
        view.endEditing(true)
    }
    @IBAction func autocompButtonPressed(_ sender: UIButton) {
        if let selectedItem = ramReel.wrapper.selectedItem {
            ramReel.textField.text = nil
            ramReel.textField.insertText(selectedItem.render())
            view.endEditing(true)
        }
    }
    
    //MARK: Matches HUD
    
    var createdStatusView: Bool = false
    var previousNumberOfMatches: Int = 0
    //var shouldScale = true
    var currentNumber = 0
    var startGettingNearestFeaturePoints = false
    let fastSceneConfiguration = AROrientationTrackingConfiguration()
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    weak var changeDelegate: ChangeStatusValue?
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

    var aspectRatioWidthOverHeight : CGFloat = 0
    var aspectRatioSucceeded : Bool = false
    var sizeOfPixelBufferFast : CGSize = CGSize(width: 0, height: 0)
    
    //MARK: Every mode (Universal)
    var statusBarHidden : Bool = false
    var finalTextToFind : String = ""
    let deviceSize = UIScreen.main.bounds.size
    ///Save the image
    var globalUrl : URL = URL(fileURLWithPath: "")
    
    
    //MARK: Ramreel
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
    
    //MARK: New Camera no Sceneview
    let avSession = AVCaptureSession()
    var snapshotImageOrientation = UIImage.Orientation.upMirrored
    private var captureCompletionBlock: ((UIImage) -> Void)?
    
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
        let cameraDevice = getCamera()
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
    func startSession() { if !avSession.isRunning { DispatchQueue.global().async { self.avSession.startRunning() } } }
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
        
        
        changeDelegate = statusView as? ChangeStatusValue
        
        let layout = listsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        
        numberLabel.isHidden = false
        updateMatchesNumber(to: 0)
       
        loadListsRealm()
        setUpButtons()
        setUpTimers()
        setUpRamReel()
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
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if busyFastFinding == false {
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
extension Notification.Name {
     static let toggleCreateName = Notification.Name("toggleCreateName")
}
