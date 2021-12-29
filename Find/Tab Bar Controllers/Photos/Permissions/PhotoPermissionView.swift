//
//  PhotoPermissionView.swift
//  Find
//
//  Created by Zheng on 1/4/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import Photos

enum PermissionAction {
    case notDetermined
    case goToSettings
    case restricted
    case allowed
    case limited
}
class PhotoPermissionView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel! /// Find from Photos
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var shouldGoToSettings = false
    
    /// true is full access
    /// false if limited
    var allowed: ((Bool) -> Void)?
    @IBOutlet weak var allowAccessButton: UIButton!
    @IBAction func allowAccessPressed(_ sender: Any) {
        if shouldGoToSettings {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        } else {
            requestAuthorization { allowed in
                if allowed {
                    self.allowed?(true)
                } else {
                    DispatchQueue.main.async {
                        self.shouldGoToSettings = true
                        
                        let goToSettings = NSLocalizedString("universal-goToSettings", comment: "")
                        self.allowAccessButton.setTitle(goToSettings, for: .normal)
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {

        Bundle.main.loadNibNamed("PhotoPermissionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        allowAccessButton.layer.cornerRadius = 12
        
        let status = self.checkAuthorizationStatus()
        
        if status == .shouldAsk {
            self.shouldGoToSettings = false
            self.allowAccessButton.setTitle("Allow Access", for: .normal)
        } else if status == .shouldGoToSettings {
            self.shouldGoToSettings = true
            
            let goToSettings = NSLocalizedString("universal-goToSettings", comment: "")
            self.allowAccessButton.setTitle(goToSettings, for: .normal)
        }
    }
    
    
    func checkAuthorizationStatus() -> PhotoPermissionAction {

        var action = PhotoPermissionAction.shouldGoToSettings
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            if status == .authorized || status == .limited {
                action = .allowed
            } else if status == .notDetermined {
                action = .shouldAsk
            } else {
                action = .shouldGoToSettings
            }
            
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .authorized {
                action = .allowed
            } else if status == .notDetermined {
                action = .shouldAsk
            } else {
                action = .shouldGoToSettings
            }
        }
        
        return action
    }
    
    func requestAuthorization(completion: @escaping ((Bool) -> Void)) {

        if #available(iOS 14, *) {
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                if status == .authorized || status == .limited {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
