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
            print("nil!")
            self.photosEmptyViewModel = PhotosEmptyViewModel()
            let emptyListView = EmptyListView(model: photosEmptyViewModel!)
            let viewController = UIHostingController(rootView: emptyListView)
            addChild(viewController, in: emptyListContainerView)
        }
        
        withAnimation {
            photosEmptyViewModel?.cards = PhotosEmptyViewModel.allCards.filter { types.contains($0.type) }
        }
        
        print("animating!!")
        UIView.animate(withDuration: 0.3) {
            self.emptyListContainerView.alpha = 1
        }
        photosEmptyViewModel?.startTutorial = pressedTutorial
        
//        if let emptyDescriptionView = emptyDescriptionView {
//            emptyDescriptionView.change(from: previously, to: to)
//            UIView.animate(withDuration: 0.3) {
//                emptyDescriptionView.alpha = 1
//            }
//        } else {
//            let emptyView = EmptyDescriptionView()
//            emptyView.alpha = 0
//            view.addSubview(emptyView)
//            emptyView.snp.makeConstraints { (make) in
//                make.edges.equalTo(view.safeAreaLayoutGuide)
//            }
//
//            emptyView.change(from: previously, to: to)
//            UIView.animate(withDuration: 0.3) {
//                emptyView.alpha = 1
//            }
//
//            emptyView.startTutorial = startTutorial
//
//            self.emptyDescriptionView = emptyView
//        }
        
        view.bringSubviewToFront(segmentedSlider)
    }
    func hideEmptyView() {
        UIView.animate(withDuration: 0.3) {
            self.emptyListContainerView.alpha = 0
        }
//        if let emptyDescriptionView = emptyDescriptionView {
//            UIView.animate(withDuration: 0.1) {
//                emptyDescriptionView.alpha = 0
//            }
//        }
    }
}
