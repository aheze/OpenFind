//
//  PermissionsVC+Constraints.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import UIKit

extension PermissionsViewController {
    func configureConstraints() {
        if Positions.deviceHasNotch {
            searchBarTopC.constant = 50
        } else {
            searchBarTopC.constant = 26
        }
    }
}
