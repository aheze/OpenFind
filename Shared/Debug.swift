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
    static var disableCameraSwipingBlur = false
    static var collectionViewScrollDisabled = false
    static var photosTestEmptyLoading = false /// if true, `sleep` instead of calling `loadPhotoMetadatas`
    static var skipLaunchIntro = false
    static var overrideLaunch = false /// override launch screen, go directly to main content
    static var photosLoadManyImages = false /// make all images scanned
}

extension UIView {
    /// add a border to a view
    func addDebugBorders(_ color: UIColor, width: CGFloat = 0.75) {
        backgroundColor = color.withAlphaComponent(0.2)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension Debug {
    static func show(_ title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(defaultAction)

        guard let viewController = UIApplication.topmostViewController else { return }
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = viewController.view
            popoverPresentationController.sourceRect = CGRect(
                x: viewController.view.bounds.width / 2,
                y: 50,
                width: 1,
                height: 1
            )
        }

        viewController.present(alert, animated: true, completion: nil)
    }
}

extension Debug {
    enum Level: String {
        case error = "Error"
        case warning = "Warning"
        case log = "Log"
    }

    static func log(_ item: Any, _ level: Level? = .log) {
        if let level = level {
            Swift.print("[\(level)] - \(item)")
        } else {
            Swift.print(item)
        }
    }
}
