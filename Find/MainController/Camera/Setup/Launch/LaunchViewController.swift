//
//  LaunchViewController.swift
//  Find
//
//  Created by Zheng on 3/31/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import AVFoundation
//import paper_onboarding
import SnapKit

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
    
    @IBOutlet weak var allowAccessViewHeightC: NSLayoutConstraint!
    
    @IBOutlet weak var allowAccessWidthC: NSLayoutConstraint!
    
    @IBOutlet weak var accessDescLabel: UILabel!
    
    @IBAction func allowAccessPressed(_ sender: Any) {
        if shouldGoToSettings {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5, animations: {
                            self.allowAccessView.alpha = 0
                            self.allowAccessView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                        }) { _ in
                            self.allowAccessView.isHidden = true
                            self.drawAnimation(type: "fullScreenStart")
                        }
                    }
                    print("allow")
                    //access allowed
                } else {
                    print("NOT allow")
                    self.shouldGoToSettings = true
                    self.firstTimeDeny = false
                    DispatchQueue.main.async {
                        self.drawAnimation(type: "DENIED")
                    }
                    //access denied
                }
            })
        }
    }
    var shouldGoToSettings = false
    var firstTimeDeny = false
    
    @IBOutlet weak var settingsPictureView: UIImageView!
    
    @IBOutlet weak var skipButton: UIButton!
    @IBAction func skipPressed(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "launchedBefore")
        defaults.set("00AEEF", forKey: "highlightColor")
        
        defaults.set(true, forKey: "showTextDetectIndicator")
        defaults.set(true, forKey: "hapticFeedback")
        
        UIView.animate(withDuration: 0.5, animations: {
            self.onboarding.alpha = 0
            self.onboarding.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.getStartedButton.alpha = 0
            self.getStartedButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        })
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Authourized")
            self.drawAnimation(type: "fullScreenStart")
        case .notDetermined:
            print("ND")
            shouldGoToSettings = false
            self.drawAnimation(type: "needPermissions")
        case .denied:
            print("D")
            firstTimeDeny = true
            shouldGoToSettings = true
            self.drawAnimation(type: "DENIED")
        case .restricted:
            print("R")
            self.drawAnimation(type: "Restricted")
        }
    }
    let onboarding = PaperOnboarding()
    @IBOutlet weak var getStartedButton: UIButton!
    @IBAction func getStartedPressed(_ sender: Any) {
        print("start!!!")
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "launchedBefore")
        defaults.set("00AEEF", forKey: "highlightColor")
        
        defaults.set(true, forKey: "showTextDetectIndicator")
        defaults.set(true, forKey: "hapticFeedback")
        
        UIView.animate(withDuration: 0.5, animations: {
            self.onboarding.alpha = 0
            self.onboarding.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            self.getStartedButton.alpha = 0
            self.getStartedButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        })
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Authourized")
            self.drawAnimation(type: "fullScreenStart")
        case .notDetermined:
            print("ND")
            shouldGoToSettings = false
            self.drawAnimation(type: "needPermissions")
        case .denied:
            print("D")
            firstTimeDeny = true
            shouldGoToSettings = true
            self.drawAnimation(type: "DENIED")
        case .restricted:
            print("R")
            self.drawAnimation(type: "Restricted")
        }
        
    }
    var bottomOnboardingConstraint: Constraint? = nil
    
    
    
    let deviceSize = UIScreen.main.bounds.size
    let loadingImages = (0...10).map { UIImage(named: "\($0)")! }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.alpha = 0
        skipButton.isHidden = true
        
        getStartedButton.alpha = 0
        getStartedButton.isHidden = true
        getStartedButton.layer.cornerRadius = 6
        getStartedButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        allowAccessView.isHidden = true
        allowAccessView.alpha = 0
        allowAccessView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        settingsPictureView.alpha = 0
        
        allowAccessButton.layer.cornerRadius = 6
        allowAccessView.layer.cornerRadius = 14
        
//        view.layoutIfNeeded()
//        print("LOADIM: \(loadingImages)")
        topRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-270).degreesToRadians)
        bottomLeftImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
        bottomRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-180).degreesToRadians)
        
        let defaults = UserDefaults.standard
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        //launchedBefore == false
        if launchedBefore == false {
            print("FIRST LAUNCH")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.drawAnimation(type: "onboarding")
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
                shouldGoToSettings = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "needPermissions")
                })
            case .denied:
                print("D")
                firstTimeDeny = true
                shouldGoToSettings = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    
                    self.drawAnimation(type: "DENIED")
                })
            case .restricted:
                print("R")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "Restricted")
                })
            }
        }
 
        
    }
    
//    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//        viewControllerToPresent.modalPresentationStyle = .fullScreen
//      super.present(viewControllerToPresent, animated: flag, completion: completion)
//    }
//
    
    
    func drawAnimation(type:String = "onboarding") {
        let availibleWidth = deviceSize.width - 60
        let accessAvailibleWidth = deviceSize.width - 100
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.baseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            switch type {
            case "Restricted":
                print("RRR")
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = availibleWidth
                self.allowAccessViewHeightC.constant = accessAvailibleWidth
                self.allowAccessWidthC.constant = accessAvailibleWidth
                
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
                self.accessDescLabel.text = "You don't have permission to use the camera."
                self.shouldGoToSettings = true
                self.allowAccessButton.setTitle("Go to settings", for: .normal)
                
            case "DENIED":
//                print("AVAI::: \(availibleWidth), h: \(self.deviceSize.height - 100)")
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = self.deviceSize.height - 60
                self.allowAccessViewHeightC.constant = self.deviceSize.height - 100
                self.allowAccessWidthC.constant = accessAvailibleWidth
                self.allowAccessView.isHidden = false
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.allowAccessView.transform = CGAffineTransform.identity
                    self.allowAccessView.alpha = 1
                    if self.firstTimeDeny {
                        
                        
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
                    }
                    self.settingsPictureView.alpha = 1
                })
                self.allowAccessButton.setTitle("Go to settings", for: .normal)
                
            case "needPermissions":
                print("needPermissions")
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = availibleWidth
                self.allowAccessViewHeightC.constant = accessAvailibleWidth
                self.allowAccessWidthC.constant = accessAvailibleWidth
                
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
                
            case "onboarding":
                
                self.onboarding.dataSource = self
                self.onboarding.delegate = self
                self.onboarding.alpha = 0
                self.onboarding.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.onboarding.layer.cornerRadius = 14
                self.onboarding.clipsToBounds = true
                self.view.addSubview(self.onboarding)
                self.onboarding.snp.makeConstraints { (make) in
                    make.width.equalTo(accessAvailibleWidth)
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(50)
                    self.bottomOnboardingConstraint = make.bottom.equalToSuperview().offset(-50).constraint
                }
//                getStarter
                
                self.view.layoutIfNeeded()
                self.view.bringSubviewToFront(self.skipButton)
                
                
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = self.deviceSize.height - 60
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.onboarding.alpha = 1
                    self.onboarding.transform = CGAffineTransform.identity
                    
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
                    self.getStartedButton.isHidden = false
                    self.skipButton.isHidden = false
                    UIView.animate(withDuration: 0.2, animations: {
                        self.skipButton.alpha = 1
                    })
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
                    viewController.modalPresentationStyle = .overCurrentContext
                    viewController.modalPresentationCapturesStatusBarAppearance = true
//                    viewController.transitioningDelegate = self
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
        
}

extension LaunchViewController: PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index == 0 {
            skipButton.alpha = 0
            skipButton.isHidden = false
            UIView.animate(withDuration: 0.15, animations: {
                self.skipButton.alpha = 1
            })
        } else {
            skipButton.alpha = 1
            UIView.animate(withDuration: 0.15, animations: {
                self.skipButton.alpha = 0
            }) { _ in
                self.skipButton.isHidden = true
            }
        }
        if index == 5 {
            getStartedButton.alpha = 0
            self.bottomOnboardingConstraint?.update(offset: -120)
            UIView.animate(withDuration: 0.3, animations: {
                self.getStartedButton.transform = CGAffineTransform.identity
                self.view.layoutIfNeeded()
                self.getStartedButton.alpha = 1
            })
        } else {
            getStartedButton.alpha = 1
            self.bottomOnboardingConstraint?.update(offset: -50)
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
                self.getStartedButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.getStartedButton.alpha = 0
            })
            
        }
    }
    
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
      return [
        OnboardingItemInfo(informationImage: UIImage(named: "Swelcome")!,
                                      title: "Welcome to Find",
                                description: "Swipe to get started",
                                   pageIcon: UIImage(),
                                   color: UIColor(named: "OnboardingGray")!,
                                 titleColor: UIColor.black,
                           descriptionColor: UIColor.darkGray,
                           titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                            descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Swhatis")!,
                   title: "What is Find?",
             description: "Find is Command+F for camera. Find words in books, worksheets, nutrition labels... Anywhere as long as there's text!",
                pageIcon: UIImage(named: "1icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Ssearchfield")!,
                   title: "Find words",
             description: "Tap the Search Field at the top of the screen",
                pageIcon: UIImage(named: "2icon")!,
                color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

        OnboardingItemInfo(informationImage: UIImage(named: "Sshutter")!,
                   title: "Take photos",
             description: "Tap the shutter button. Later, you can come back to these and Find from them again and again and again...",
                pageIcon: UIImage(named: "3icon")!,
                   color: UIColor(named: "OnboardingGray")!,
              titleColor: UIColor.black,
        descriptionColor: UIColor.darkGray,
        titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
         descriptionFont: UIFont.systemFont(ofSize: 17)),

       OnboardingItemInfo(informationImage: UIImage(named: "Smenu")!,
                  title: "Access the Menu",
            description: "Your History, Lists, and Settings are here. Check it out!",
               pageIcon: UIImage(named: "4icon")!,
                  color: UIColor(named: "OnboardingGray")!,
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17)),
       
       OnboardingItemInfo(informationImage: UIImage(named: "Sjitter")!,
                  title: "Before you start...",
            description: "To ensure the most accurate results, please make sure to hold your phone as steady as possible.",
               pageIcon: UIImage(named: "5icon")!,
                  color: UIColor(named: "OnboardingGray")!,
             titleColor: UIColor.black,
       descriptionColor: UIColor.darkGray,
       titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
        descriptionFont: UIFont.systemFont(ofSize: 17))
        ][index]
    }

//    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
//        // config labels
//        item.informationImageWidthConstraint?.constant = 250
//        item.informationImageHeightConstraint?.constant = 250
//    }
    
    func onboardingItemsCount() -> Int {
       return 6
    }
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
