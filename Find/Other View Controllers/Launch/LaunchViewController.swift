//
//  LaunchViewController.swift
//  Find
//
//  Created by Zheng on 3/31/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class LaunchViewController: UIViewController {
    
    let loc = LaunchLocalization()
    
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
    
    var onboardingOnLastPage = false
    
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
                            self.drawAnimation(type: "fullScreenStart")
                        }
                    }
                } else {
                    self.shouldGoToSettings = true
                    self.firstTimeDeny = false
                    DispatchQueue.main.async {
                        self.drawAnimation(type: "DENIED")
                    }
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
            self.skipButton.alpha = 0
        })
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Authourized")
            self.drawAnimation(type: "fullScreenStart")
        case .notDetermined:
            shouldGoToSettings = false
            self.drawAnimation(type: "needPermissions")
        case .denied:
            firstTimeDeny = true
            shouldGoToSettings = true
            self.drawAnimation(type: "DENIED")
        case .restricted:
            self.drawAnimation(type: "Restricted")
        }
    }
    @IBOutlet weak var onboarding: PaperOnboarding!
    
    @IBOutlet weak var getStartedButton: UIButton!
    @IBAction func getStartedPressed(_ sender: Any) {
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
            self.skipButton.alpha = 0
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
    
    @IBOutlet weak var onboardingBottomC: NSLayoutConstraint!
    @IBOutlet weak var onboardingWidthC: NSLayoutConstraint!
    
    let loadingImages = (0...10).map { UIImage(named: "\($0)")! }
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.alpha = 0
        
        getStartedButton.alpha = 0
        getStartedButton.layer.cornerRadius = 6
        getStartedButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        allowAccessView.alpha = 0
        allowAccessView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        settingsPictureView.alpha = 0
        
        allowAccessButton.layer.cornerRadius = 6
        allowAccessView.layer.cornerRadius = 14
        
        topRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-270).degreesToRadians)
        bottomLeftImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-90).degreesToRadians)
        bottomRightImageView.transform = CGAffineTransform(rotationAngle: CGFloat(-180).degreesToRadians)
        
        let defaults = UserDefaults.standard
        let launchedBefore = defaults.bool(forKey: "launchedBefore")
        if launchedBefore == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.drawAnimation(type: "onboarding")
            })
        } else {
            onboarding.removeFromSuperview()
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                print("Authourized")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "fullScreenStart")
                })
            case .notDetermined:
                shouldGoToSettings = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "needPermissions")
                })
            case .denied:
                firstTimeDeny = true
                shouldGoToSettings = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "DENIED")
                })
            case .restricted:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: "Restricted")
                })
            @unknown default:
                print("unknown default")
            }
        }
    }
    
    let goToSettings = NSLocalizedString("goToSettings", comment: "LaunchViewController def=Go to settings")
    
    
    func drawAnimation(type:String = "onboarding") {
        let availibleWidth = view.bounds.width - 60
        let accessAvailibleWidth = view.bounds.width - 100
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.baseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            switch type {
            case "Restricted":
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
                    
                    self.skipButton.alpha = 0
                    
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
                
                let noPermissionToUseCamera = NSLocalizedString("noPermissionToUseCamera", comment: "LaunchViewController def=You don't have permission to use the camera.")
                
                self.accessDescLabel.text = noPermissionToUseCamera
                self.shouldGoToSettings = true
                self.allowAccessButton.setTitle(self.goToSettings, for: .normal)
            case "DENIED":
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = self.view.bounds.height - 60
                self.allowAccessViewHeightC.constant = self.view.bounds.height - 100
                self.allowAccessWidthC.constant = accessAvailibleWidth
                
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.allowAccessView.transform = CGAffineTransform.identity
                    self.allowAccessView.alpha = 1
                    self.settingsPictureView.alpha = 1
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
                    
                })
                self.allowAccessButton.setTitle(self.goToSettings, for: .normal)
                
            case "needPermissions":
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = availibleWidth
                self.allowAccessViewHeightC.constant = accessAvailibleWidth
                self.allowAccessWidthC.constant = accessAvailibleWidth
                
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
                self.onboardingWidthC.constant = accessAvailibleWidth
                
                self.view.layoutIfNeeded()
                self.view.bringSubviewToFront(self.skipButton)
                
                self.totalWidthC.constant = availibleWidth
                self.totalHeightC.constant = self.view.bounds.height - 60
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                    self.baseView.transform = CGAffineTransform.identity
                    self.onboarding.alpha = 1
                    self.onboarding.transform = CGAffineTransform.identity
                    
                    self.skipButton.alpha = 1
                    
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
            case "fullScreenStart":
                let finalWidth = self.view.bounds.width
                let finalHeight = self.view.bounds.height
                self.totalWidthC.constant = finalWidth
                self.totalHeightC.constant = finalHeight
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
                    viewController.modalTransitionStyle = .crossDissolve
                    viewController.modalPresentationStyle = .overCurrentContext
                    
                    viewController.modalPresentationCapturesStatusBarAppearance = true
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
            UIView.animate(withDuration: 0.15, animations: {
                self.skipButton.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.skipButton.alpha = 0
            })
        }
        if index == 6 {
            onboardingOnLastPage = true
            getStartedButton.alpha = 0
            onboardingBottomC.constant = 120
            UIView.animate(withDuration: 0.15, animations: {
                self.getStartedButton.transform = CGAffineTransform.identity
                self.view.layoutIfNeeded()
                self.getStartedButton.alpha = 1
            })
        } else {
            if onboardingOnLastPage == true {
                onboardingOnLastPage = false
                getStartedButton.alpha = 1
                onboardingBottomC.constant = 50
                UIView.animate(withDuration: 0.15, animations: {
                    self.view.layoutIfNeeded()
                    self.getStartedButton.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                    self.getStartedButton.alpha = 0
                })
            }
        }
    }
}


extension LaunchViewController {
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return [
            OnboardingItemInfo(informationImage: UIImage(named: "Swelcome")!,
                               title: loc.welcomeToFind,
                               description: loc.swipeToGetStarted,
                               pageIcon: UIImage(),
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Swhatis")!,
                               title: loc.whatIsFind,
                               description: loc.findIsCommandFForCamera,
                               pageIcon: UIImage(named: "1icon")!,
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Ssearchfield")!,
                               title: loc.findWords,
                               description: loc.tapSearchField,
                               pageIcon: UIImage(named: "2icon")!,
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Slists")!,
            title: loc.lists,
            description: loc.makeLists,
            pageIcon: UIImage(named: "3icon")!,
            color: UIColor(named: "OnboardingGray")!,
            titleColor: UIColor.black,
            descriptionColor: UIColor.darkGray,
            titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
            descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            
            OnboardingItemInfo(informationImage: UIImage(named: "Sshutter")!,
                               title: loc.takePhotos,
                               description: loc.tapShutterButton,
                               pageIcon: UIImage(named: "4icon")!,
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Smenu")!,
                               title: loc.accessMenu,
                               description: loc.yourPhotosListsAndSettingsHere,
                               pageIcon: UIImage(named: "5icon")!,
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Sjitter")!,
                               title: loc.beforeYouStart,
                               description: loc.ensureAccuracy,
                               pageIcon: UIImage(named: "6icon")!,
                               color: UIColor(named: "OnboardingGray")!,
                               titleColor: UIColor.black,
                               descriptionColor: UIColor.darkGray,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
            ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 7
    }
}


