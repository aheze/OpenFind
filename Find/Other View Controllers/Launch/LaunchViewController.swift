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

enum LaunchAction {
    case onboarding
    case fullScreenStart
    case needPermissions
    case denied
    case restricted
}
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
    
    @IBOutlet weak var allowAccessWidthC: NSLayoutConstraint!
    @IBOutlet weak var allowAccessViewHeightC: NSLayoutConstraint!
    
    var innerViewMaxWidth = CGFloat(0)
    var innerViewMaxHeight = CGFloat(0)
    var cornersViewMaxWidth = CGFloat(0)
    var cornersViewMaxHeight = CGFloat(0)
    
    let topHeight = CGFloat(70)
    
    
    
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
                            self.drawAnimation(type: .fullScreenStart)
                        }
                    }
                } else {
                    self.shouldGoToSettings = true
                    self.firstTimeDeny = false
                    DispatchQueue.main.async {
                        self.drawAnimation(type: .denied)
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
        defaults.set(1, forKey: "hapticFeedbackLevel")
        defaults.set(true, forKey: "swipeToNavigateEnabled")
        
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
            self.drawAnimation(type: .fullScreenStart)
        case .notDetermined:
            shouldGoToSettings = false
            self.drawAnimation(type: .needPermissions)
        case .denied:
            firstTimeDeny = true
            shouldGoToSettings = true
            self.drawAnimation(type: .denied)
        case .restricted:
            self.drawAnimation(type: .restricted)
        @unknown default:
            fatalError()
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
            self.drawAnimation(type: .fullScreenStart)
        case .notDetermined:
            print("ND")
            shouldGoToSettings = false
            self.drawAnimation(type: .needPermissions)
        case .denied:
            print("D")
            firstTimeDeny = true
            shouldGoToSettings = true
            self.drawAnimation(type: .denied)
        case .restricted:
            print("R")
            self.drawAnimation(type: .restricted)
        @unknown default:
            fatalError()
        }
        
    }
    
    @IBOutlet weak var onboardingTopC: NSLayoutConstraint!
    @IBOutlet weak var onboardingWidthC: NSLayoutConstraint!
    @IBOutlet weak var onboardingHeightC: NSLayoutConstraint!
    
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
//        if launchedBefore == false {
        
        if true {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.drawAnimation(type: .onboarding)
            })
        } else {
            onboarding.removeFromSuperview()
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                print("Authourized")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: .fullScreenStart)
                })
            case .notDetermined:
                shouldGoToSettings = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: .needPermissions)
                })
            case .denied:
                firstTimeDeny = true
                shouldGoToSettings = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: .denied)
                })
            case .restricted:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.drawAnimation(type: .restricted)
                })
            @unknown default:
                print("unknown default")
            }
        }
    }
    
    let goToSettings = NSLocalizedString("goToSettings", comment: "LaunchViewController def=Go to settings")
    
    
    func drawAnimation(type: LaunchAction) {
        
        innerViewMaxWidth = view.bounds.width - CGFloat(70)
        innerViewMaxHeight = view.bounds.height - CGFloat(topHeight * 2)
        cornersViewMaxWidth = view.bounds.width - CGFloat(30)
        cornersViewMaxHeight = view.bounds.height - CGFloat(topHeight * 2 - 40)
        
        let restrictedInnerViewWidth = min(500, innerViewMaxWidth)
        let restrictedInnerViewHeight = min(500 - 40, innerViewMaxHeight)
        let restrictedCornersViewWidth = min(500, cornersViewMaxWidth)
        let restrictedCornersViewHeight = min(500, cornersViewMaxHeight)
        
        
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.baseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            switch type {
            case .restricted:
                self.totalWidthC.constant = restrictedInnerViewWidth
                self.totalHeightC.constant = restrictedInnerViewWidth
                self.allowAccessViewHeightC.constant = restrictedCornersViewWidth
                self.allowAccessWidthC.constant = restrictedCornersViewWidth
                
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
            case .denied:
                self.allowAccessWidthC.constant = restrictedInnerViewWidth
                self.allowAccessViewHeightC.constant = self.innerViewMaxHeight
                self.totalWidthC.constant = restrictedCornersViewWidth
                self.totalHeightC.constant = self.cornersViewMaxHeight
                
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
                
            case .needPermissions:
                self.allowAccessWidthC.constant = restrictedInnerViewWidth
                self.allowAccessViewHeightC.constant = restrictedInnerViewHeight
                self.totalWidthC.constant = restrictedCornersViewWidth
                self.totalHeightC.constant = restrictedCornersViewHeight
                
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
                
            case .onboarding:
                
                self.onboarding.dataSource = self
                self.onboarding.delegate = self
                self.onboarding.alpha = 0
                self.onboarding.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                self.onboarding.layer.cornerRadius = 14
                self.onboarding.clipsToBounds = true
                
                self.onboardingTopC.constant = self.topHeight
                self.onboardingWidthC.constant = self.innerViewMaxWidth
                self.onboardingHeightC.constant = self.innerViewMaxHeight
                
                self.view.layoutIfNeeded()
                self.view.bringSubviewToFront(self.skipButton)
                
                self.totalWidthC.constant = self.cornersViewMaxWidth
                self.totalHeightC.constant = self.cornersViewMaxHeight
                
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
            case .fullScreenStart:
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
        if index == 3 {
            onboardingOnLastPage = true
            getStartedButton.alpha = 0
            onboardingHeightC.constant = self.innerViewMaxHeight - 60
            UIView.animate(withDuration: 0.15, animations: {
                self.getStartedButton.transform = CGAffineTransform.identity
                self.view.layoutIfNeeded()
                self.getStartedButton.alpha = 1
            })
        } else {
            if onboardingOnLastPage == true {
                onboardingOnLastPage = false
                getStartedButton.alpha = 1
                onboardingHeightC.constant = self.innerViewMaxHeight
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
            OnboardingItemInfo(informationImage: UIImage(named: "Intro1")!,
                               title: LaunchLocalization.welcomeToFind,
                               description: LaunchLocalization.swipeToGetStarted,
                               pageIcon: UIImage(),
                               color: UIColor(named: "OnboardBlue")!,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: UIFont.systemFont(ofSize: 30, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro2")!,
                               title: LaunchLocalization.camera,
                               description: LaunchLocalization.cameraDescription,
                               pageIcon: UIImage(named: "Page1")!,
                               color: UIColor(named: "OnboardBlue")!,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro3")!,
                               title: LaunchLocalization.photos,
                               description: LaunchLocalization.photosDescription,
                               pageIcon: UIImage(named: "Page2")!,
                               color: UIColor(named: "OnboardBlue")!,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17)),
            
            OnboardingItemInfo(informationImage: UIImage(named: "Intro4")!,
                               title: LaunchLocalization.lists,
                               description: LaunchLocalization.listsDescription,
                               pageIcon: UIImage(named: "Page3")!,
                               color: UIColor(named: "OnboardBlue")!,
                               titleColor: UIColor.white,
                               descriptionColor: UIColor.white,
                               titleFont: UIFont.systemFont(ofSize: 22, weight: .bold),
                               descriptionFont: UIFont.systemFont(ofSize: 17))
            ][index]
    }
    
    func onboardingItemsCount() -> Int {
        return 4
    }
}


