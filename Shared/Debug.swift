//
//  Debug.swift
//  Find
//
//  Created by Zheng on 11/23/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit

enum Debug {
    /// Everything should be false on release
    static var tabBarAlwaysTransparent = false
    static var navigationBarAlwaysTransparent = false
    static var collectionViewScrollDisabled = false
    static var photosTestEmptyLoading = false /// if true, `sleep` instead of calling `loadPhotoMetadatas`
    static var skipLaunchIntro = false
}

extension UIView {
    /// add a border to a view
    func addDebugBorders(_ color: UIColor, width: CGFloat = 0.75) {
        backgroundColor = color.withAlphaComponent(0.3)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension Debug {
    static func show(_ title: String, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
}
