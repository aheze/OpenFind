//
//  PhotosVC+EmptyView.swift
//  Find
//
//  Created by Zheng on 6/7/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

class PhotosEmptyViewModel: ObservableObject {
    @Published var cards = [PhotoTutorialCard]()
    var startTutorial: ((PhotoTutorialType) -> Void)?
    
    static var allCards = [
        PhotoTutorialCard(type: .starred),
        PhotoTutorialCard(type: .cached),
        PhotoTutorialCard(type: .local),
        PhotoTutorialCard(type: .screenshots),
        PhotoTutorialCard(type: .all)
    ]
}

extension PhotosViewController {
    func showEmptyView(for types: [PhotoTutorialType]) {
        if photosEmptyViewModel == nil {
            photosEmptyViewModel = PhotosEmptyViewModel()
            let emptyListView = EmptyListView(model: photosEmptyViewModel!)
            let viewController = UIHostingController(rootView: emptyListView)
            addChild(viewController, in: emptyListContainerView)
        }
        
        withAnimation {
            photosEmptyViewModel?.cards = PhotosEmptyViewModel.allCards.filter { types.contains($0.type) }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.emptyListContainerView.alpha = 1
        }
        photosEmptyViewModel?.startTutorial = pressedTutorial
        view.bringSubviewToFront(segmentedSlider)
        
        if quickTourView != nil {
            emptyListContainerTopC.constant = 50
        } else {
            emptyListContainerTopC.constant = 0
        }
    }

    func hideEmptyView() {
        UIView.animate(withDuration: 0.3) {
            self.emptyListContainerView.alpha = 0
        }
    }
}
