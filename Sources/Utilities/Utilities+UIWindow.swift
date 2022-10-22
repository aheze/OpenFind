//
//  Utilities+UIWindow.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension UIWindow {
    /// without async
    static var currentInterfaceOrientation: UIInterfaceOrientation? {
        return UIApplication.shared.windows
            .first?
            .windowScene?
            .interfaceOrientation
    }

    /// with async
    static var interfaceOrientation: UIInterfaceOrientation? {
        get async {
            await MainActor.run {
                UIApplication.shared.windows
                    .first?
                    .windowScene?
                    .interfaceOrientation
            }
        }
    }
}

extension UIInterfaceOrientation {
    func getVisionOrientation() -> CGImagePropertyOrientation {
        switch self {
        case .portrait:
            return .right
        case .landscapeRight: /// home button right
            return .up
        case .landscapeLeft: /// home button left
            return .down
        case .portraitUpsideDown:
            return .left
        default:
            return .right
        }
    }

    func getMask() -> UIInterfaceOrientationMask? {
        switch self {
        case .unknown:
            return nil
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        @unknown default:
            return nil
        }
    }
}
