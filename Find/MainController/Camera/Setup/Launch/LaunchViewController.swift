//
//  LaunchViewController.swift
//  Find
//
//  Created by Zheng on 3/31/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var topLeftImageView: UIImageView!
    
    @IBOutlet weak var topRightImageView: UIImageView!
    
    @IBOutlet weak var bottomLeftImageView: UIImageView!
    
    @IBOutlet weak var bottomRightImageView: UIImageView!
    
    @IBOutlet weak var totalWidthC: NSLayoutConstraint!
    
    @IBOutlet weak var totalHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var allowAccessView: UIView!
    
    
    @IBOutlet weak var allowAccessButton: UIButton!
    
    @IBAction func allowAccessPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var settingsPictureView: UIImageView!
    
    let deviceSize = UIScreen.main.bounds.size
    let loadingImages = (0...10).map { UIImage(named: "\($0)")! }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allowAccessView.isHidden = true
        allowAccessView.alpha = 0
        allowAccessView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        settingsPictureView.alpha = 0
        
        allowAccessButton.layer.cornerRadius = 6
        
//        view.layoutIfNeeded()
        print("LOADIM: \(loadingImages)")
        topRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-270).degreesToRadians)
        bottomLeftImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
        bottomRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-180).degreesToRadians)
        
        let defaults = UserDefaults.standard
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        if !launchedBefore {
            print("FIRST LAUNCH")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.drawAnimation()
            })
        } else {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                print("Authourized")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "fullScreenStart")
                })
            case .notDetermined:
                print("ND")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "needPermissions")
                })
            case .denied:
                print("D")
            case .restricted:
                print("R")
                
            }
//            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
//            //already authorized
//                print("Authourized")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
//                    self.drawAnimation()
//                })
//
//            } else {
//                self.drawAnimation(type: "needPermissions")
//
//            }
        }
 
        
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
      super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    
    
    func drawAnimation(type: String = "onboarding") {
        let availibleWidth = deviceSize.width - 100
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.baseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            switch type {
            case "needPermissions":
                print("anim")
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = availibleWidth
                self.allowAccessView.isHidden = false
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.allowAccessView.transform = CGAffineTransform.identity
                    self.allowAccessView.alpha = 1
                    
                    self.topLeftImageView.image = UIImage(named: "10")
                    self.topRightImageView.image = UIImage(named: "10")
                    self.bottomLeftImageView.image = UIImage(named: "10")
                    self.bottomRightImageView.image = UIImage(named: "10")
                    self.topLeftImageView.animationImages = self.loadingImages
                    self.topRightImageView.animationImages = self.loadingImages
                    self.bottomLeftImageView.animationImages = self.loadingImages
                    self.bottomRightImageView.animationImages = self.loadingImages
                    self.topLeftImageView.animationRepeatCount = 1
                    self.topRightImageView.animationRepeatCount = 1
                    self.bottomLeftImageView.animationRepeatCount = 1
                    self.bottomRightImageView.animationRepeatCount = 1
                    self.topLeftImageView.animationDuration = 0.4
                    self.topRightImageView.animationDuration = 0.4
                    self.bottomLeftImageView.animationDuration = 0.4
                    self.bottomRightImageView.animationDuration = 0.4
                    self.topLeftImageView.startAnimating()
                    self.topRightImageView.startAnimating()
                    self.bottomLeftImageView.startAnimating()
                    self.bottomRightImageView.startAnimating()
                })
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        //access allowed
                    } else {
                        //access denied
                    }
                })
            case "onboarding":
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = availibleWidth
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    
                    self.topLeftImageView.image = UIImage(named: "10")
                    self.topRightImageView.image = UIImage(named: "10")
                    self.bottomLeftImageView.image = UIImage(named: "10")
                    self.bottomRightImageView.image = UIImage(named: "10")
                    self.topLeftImageView.animationImages = self.loadingImages
                    self.topRightImageView.animationImages = self.loadingImages
                    self.bottomLeftImageView.animationImages = self.loadingImages
                    self.bottomRightImageView.animationImages = self.loadingImages
                    self.topLeftImageView.animationRepeatCount = 1
                    self.topRightImageView.animationRepeatCount = 1
                    self.bottomLeftImageView.animationRepeatCount = 1
                    self.bottomRightImageView.animationRepeatCount = 1
                    self.topLeftImageView.animationDuration = 0.4
                    self.topRightImageView.animationDuration = 0.4
                    self.bottomLeftImageView.animationDuration = 0.4
                    self.bottomRightImageView.animationDuration = 0.4
                    self.topLeftImageView.startAnimating()
                    self.topRightImageView.startAnimating()
                    self.bottomLeftImageView.startAnimating()
                    self.bottomRightImageView.startAnimating()
                }) { _ in
                    
                }
            case "fullScreenStart":
                let finalWidth = self.deviceSize.width
                let finalHeight = self.deviceSize.height
                self.totalWidthC.constant = finalWidth
                self.totalHeightC.constant = finalHeight
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
                    viewController.modalTransitionStyle = .crossDissolve
                    self.present(viewController, animated: true, completion: nil)
                })
                UIView.animate(withDuration: 0.4, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.topLeftImageView.alpha = 0
                    self.topRightImageView.alpha = 0
                    self.bottomLeftImageView.alpha = 0
                    self.bottomRightImageView.alpha = 0
                    self.view.alpha = 0
                })
                default:
                    print("WRONG!!")
            }
        }
    }
            
//            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
//                if granted {
//                    print("ALLOW")
//                    self.drawAnimation(type: "fullScreenStart")
//                    //access allowed
//                } else {
//                    self.drawAnimation(type: "needPermissions")
//                    print("NOT AL")
//                    //access denied
//                }
//            })
        
}
        
        
            
    
    
//public extension UIDevice {
//
//    static let modelName: Bool = {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let identifier = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8, value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//
//        func mapToDevice(identifier: String) -> Bool { // swiftlint:disable:this cyclomatic_complexity
//            #if os(iOS)
//            switch identifier {
//            case "iPhone10,3", "iPhone10,6":                return true
//            case "iPhone11,2":                              return true
//            case "iPhone11,4", "iPhone11,6":                return true
//            case "iPhone11,8":                              return true
//            case "iPhone12,1":                              return true
//            case "iPhone12,3":                              return true
//            case "iPhone12,5":                              return true
//            default:                                        return false
//            }
//            #elseif os(tvOS)
//            switch identifier {
//            case "AppleTV5,3": return "Apple TV 4"
//            case "AppleTV6,2": return "Apple TV 4K"
//            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
//            default: return identifier
//            }
//            #endif
//        }
//
//        return mapToDevice(identifier: identifier)
//    }()
//
//}
