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
            if
                let self = self,
                let slidesState = self.model.slidesState,
                slidesState.toolbarInformationOn
            {
                return self.getInfoHeight()
            }
            return 0
        }
        flowLayout.getTopExtraHeight = { [weak self] in
            if
                let self = self,
                let slidesState = self.model.slidesState,
                slidesState.toolbarInformationOn
            {
                let offset = self.scrollView.contentOffset.y
                let infoHeight = self.getInfoHeight()
                let extraHeight = infoHeight - offset

                return extraHeight
            }
            return 0
        }

        return flowLayout
    }
}
