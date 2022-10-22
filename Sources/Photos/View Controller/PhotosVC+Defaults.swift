//
//  PhotosVC+Defaults.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/23/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosViewController {
    func listenToDefaults() {
        self.listen(
            to: RealmModelData.photosMinimumCellLength.key,
            selector: #selector(self.photosMinimumCellLengthChanged)
        )
    }

    @objc func photosMinimumCellLengthChanged() {
        Debouncer.debounce(queue: .main, delay: .seconds(1)) {
            self.flowLayout.invalidateLayout()
        }
    }
}
