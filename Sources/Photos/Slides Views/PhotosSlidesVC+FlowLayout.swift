//
//  PhotosSlidesVC+FlowLayout.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension PhotosSlidesViewController {
    func makeFlowLayout() -> PhotosSlidesCollectionLayout {
        let flowLayout = PhotosSlidesCollectionLayout(model: model)
        flowLayout.getTopInset = { [weak self] in
            guard let self = self else { return .zero }

            return self.scrollView.contentOffset.y
        }

        return flowLayout
    }
}
