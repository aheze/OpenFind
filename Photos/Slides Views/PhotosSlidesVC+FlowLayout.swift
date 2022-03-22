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
        flowLayout.getBottomPadding = { [weak self] in
            guard let self = self else { return 0 }
            
            if let slidesState = self.model.slidesState {
                if slidesState.toolbarInformationOn {
                    return self.getInfoHeight()
                }
            }
            return 0
        }
        
        return flowLayout
    }
}
