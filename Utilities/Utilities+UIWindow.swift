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
