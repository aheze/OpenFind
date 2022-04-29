//
//  Callback.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/9/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

enum ViewControllerCallback {
    static var getListDetailController: ((ToolbarViewModel, List) -> UIViewController?)?
    
    /// confirmed already, delete now
    static var deleteAllScannedData: ((Bool) -> Void)?
}
