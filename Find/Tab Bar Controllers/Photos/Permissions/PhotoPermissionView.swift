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
    
    var permissionAction = PermissionAction.notDetermined
    
    /// true is full access
    /// false if limited
    var allowed: ((Bool) -> Void)?
    @IBOutlet weak var allowAccessButton: UIButton!
    @IBAction func allowAccessPressed(_ sender: Any) {
        switch permissionAction {
        case .notDetermined:
            if #available(iOS 14, *) {
                getAdvancedPhotoAccess()
            } else {
                getPhotoAccess()
            }
        case .goToSettings:
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        default:
            print("None of the above")
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
        
        switch permissionAction {
        
        case .notDetermined:
            allowAccessButton.setTitle("Allow Access", for: .normal)
        case .goToSettings:
            allowAccessButton.setTitle("Go To Settings", for: .normal)
        case .restricted:
            allowAccessButton.isEnabled = false
            descriptionLabel.text = "Find is unable to access the Photo library"
        case .allowed, .limited:
            break
        }
    }
    
    @available(iOS 14, *)
    func getAdvancedPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            switch status {
            case .notDetermined:
                print("not determined")
                self.permissionAction = .notDetermined
                self.allowAccessButton.setTitle("Allow Access", for: .normal)
            case .restricted:
                print("restricted")
                self.permissionAction = .restricted
                self.allowAccessButton.isEnabled = false
            case .denied:
                print("denied")
                self.permissionAction = .goToSettings
                self.allowAccessButton.setTitle("Go To Settings", for: .normal)
            case .authorized:
                self.allowed?(true)
            case .limited:
                self.allowed?(false)
            @unknown default:
                print("default")
            }
        }
    }
    
    func getPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .notDetermined:
                print("not determined")
                self.permissionAction = .notDetermined
                self.allowAccessButton.setTitle("Allow Access", for: .normal)
            case .restricted:
                print("restricted")
                self.permissionAction = .restricted
                self.allowAccessButton.isEnabled = false
            case .denied:
                print("denied")
                self.permissionAction = .goToSettings
                self.allowAccessButton.setTitle("Go To Settings", for: .normal)
            case .authorized:
                self.allowed?(true)
            case .limited:
                self.allowed?(false)
            @unknown default:
                print("default")
            }
        }
    }
}
