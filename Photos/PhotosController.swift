//
//  PhotosController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class PhotosController {
    var model: PhotosViewModel
    var toolbarViewModel: ToolbarViewModel
    var realmModel: RealmModel
    
    var searchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: PhotosViewController
    
    init(model: PhotosViewModel, toolbarViewModel: ToolbarViewModel, realmModel: RealmModel) {
        self.model = model
        self.toolbarViewModel = toolbarViewModel
        self.realmModel = realmModel
        
        self.model.realmModel = realmModel
        
        let searchViewModel = SearchViewModel(configuration: .photos)
        self.searchViewModel = searchViewModel
        
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "PhotosViewController") { coder in
            PhotosViewController(
                coder: coder,
                model: model,
                toolbarViewModel: toolbarViewModel,
                realmModel: realmModel,
                searchViewModel: searchViewModel
            )
        }
        self.viewController = viewController
        viewController.loadViewIfNeeded() /// needed to initialize outlets
    
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        searchNavigationController.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationController.onDidBecomeActive = { viewController.didBecomeActive() }
        searchNavigationController.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationController.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationController.onBoundsChange = { size, safeAreaInset in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInset)
        }
        
        self.searchNavigationController = searchNavigationController
        
        viewController.loadViewIfNeeded() /// needed to initialize outlets
        viewController.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
            Tab.Frames.excluded[.photosSearchBar] = searchNavigationController.searchContainerView.windowFrame()
        }
        
        model.transitionAnimatorsUpdated = { photos, slides in
            searchNavigationController.pushAnimator = PhotosTransitionPushAnimator(fromDelegate: photos, toDelegate: slides)
            searchNavigationController.popAnimator = PhotosTransitionPopAnimator(fromDelegate: slides, toDelegate: photos)
        }
        
        model.imageUpdatedWhenPresentingSlides = { image in
            if let animator = searchNavigationController.pushAnimator as? PhotosTransitionPushAnimator {
                animator.transitionImageView.image = image
            }
        }
    }
}
