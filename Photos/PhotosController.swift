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
        
        configureTransitions(for: searchNavigationController)
    }
}

extension PhotosController {
    /// Override `SearchNavigationController`'s default transition animations
    func configureTransitions(for searchNavigationController: SearchNavigationController) {
        /// set a higher quality image once available, during the zoom transition
        model.imageUpdatedWhenPresentingSlides = { image in
            if let animator = searchNavigationController.pushAnimator as? PhotosTransitionPushAnimator {
                animator.transitionImageView.image = image
            }
        }
        
        /// called when presenting slides. Configure the dismissal animators too.
        model.transitionAnimatorsUpdated = { photos, slides in
            let pushAnimator = PhotosTransitionPushAnimator(fromDelegate: photos, toDelegate: slides)
            let popAnimator = PhotosTransitionPopAnimator(fromDelegate: slides, toDelegate: photos)
            let dismissAnimator = PhotosTransitionDismissAnimator(fromDelegate: slides, toDelegate: photos)
            
            searchNavigationController.pushAnimator = pushAnimator
            searchNavigationController.popAnimator = popAnimator
            searchNavigationController.dismissAnimator = dismissAnimator
            
            pushAnimator?.additionalSetup = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: slides)
                searchNavigationController.beginSearchBarTransitionAnimation(to: slides, targetPercentage: targetPercentage)
            }
            pushAnimator?.additionalAnimations = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: slides)
                searchNavigationController.continueSearchBarTransitionAnimation(targetPercentage: targetPercentage)
            }
            pushAnimator?.additionalCompletion = {
                searchNavigationController.finishSearchBarTransitionAnimation(to: slides)
            }
            
            popAnimator?.additionalSetup = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: photos)
                searchNavigationController.beginSearchBarTransitionAnimation(to: photos, targetPercentage: targetPercentage)
            }
            popAnimator?.additionalAnimations = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: photos)
                searchNavigationController.continueSearchBarTransitionAnimation(targetPercentage: targetPercentage)
            }
            popAnimator?.additionalCompletion = {
                searchNavigationController.finishSearchBarTransitionAnimation(to: photos)
            }
            
            dismissAnimator?.progressUpdated = { progress in
                searchNavigationController.setBlur(from: slides, to: photos, percentage: progress)
                searchNavigationController.setOffset(from: slides, to: photos, percentage: progress)
            }
            
            dismissAnimator?.additionalFinalSetup = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: photos)
                searchNavigationController.beginSearchBarTransitionAnimation(to: photos, targetPercentage: targetPercentage)
            }
            
            dismissAnimator?.additionalFinalAnimations = {
                let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: photos)
                searchNavigationController.continueSearchBarTransitionAnimation(targetPercentage: targetPercentage)
            }
            
            dismissAnimator?.additionalCompletion = { completed in
                if completed {
                    searchNavigationController.finishSearchBarTransitionAnimation(to: photos)
                } else {
                    searchNavigationController.cancelSearchBarPopAnimation()
                }
            }
        }
    }
}
