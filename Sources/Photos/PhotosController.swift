//
//  PhotosController.swift
//  Photos
//
//  Created by Zheng on 11/18/21.
//

import UIKit

class PhotosController {
    var model: PhotosViewModel
    var realmModel: RealmModel
    var tabViewModel: TabViewModel
    var photosPermissionsViewModel: PhotosPermissionsViewModel
    var toolbarViewModel: ToolbarViewModel
    
    var searchNavigationModel: SearchNavigationModel
    var searchViewModel: SearchViewModel
    var searchNavigationProgressViewModel: ProgressViewModel
    var slidesSearchPromptViewModel: SearchPromptViewModel
    
    /// for the slides. This will only be up to date when the slides are presented.
    var slidesSearchViewModel: SearchViewModel
    var searchNavigationController: SearchNavigationController
    var viewController: PhotosViewController
    
    init(
        model: PhotosViewModel,
        realmModel: RealmModel,
        tabViewModel: TabViewModel,
        photosPermissionsViewModel: PhotosPermissionsViewModel,
        toolbarViewModel: ToolbarViewModel
    ) {
        self.model = model
        self.realmModel = realmModel
        self.tabViewModel = tabViewModel
        self.photosPermissionsViewModel = photosPermissionsViewModel
        self.toolbarViewModel = toolbarViewModel
        
        let searchNavigationModel = SearchNavigationModel()
        let searchViewModel = SearchViewModel(configuration: .photos)
        let searchNavigationProgressViewModel = ProgressViewModel()
        let slidesSearchViewModel = SearchViewModel(configuration: .photosSlides)
        let slidesSearchPromptViewModel = SearchPromptViewModel()
        
        self.searchNavigationModel = searchNavigationModel
        self.searchViewModel = searchViewModel
        self.searchNavigationProgressViewModel = searchNavigationProgressViewModel
        self.slidesSearchViewModel = slidesSearchViewModel
        self.slidesSearchPromptViewModel = slidesSearchPromptViewModel
        
        let storyboard = UIStoryboard(name: "PhotosContent", bundle: nil)
        
        let viewController = storyboard.instantiateViewController(identifier: "PhotosViewController") { coder in
            PhotosViewController(
                coder: coder,
                model: model,
                realmModel: realmModel,
                tabViewModel: tabViewModel,
                photosPermissionsViewModel: photosPermissionsViewModel,
                toolbarViewModel: toolbarViewModel,
                searchNavigationModel: searchNavigationModel,
                searchViewModel: searchViewModel,
                searchNavigationProgressViewModel: searchNavigationProgressViewModel,
                slidesSearchViewModel: slidesSearchViewModel,
                slidesSearchPromptViewModel: slidesSearchPromptViewModel
            )
        }
        self.viewController = viewController
        
        let searchNavigationController = SearchNavigationController.make(
            rootViewController: viewController,
            searchNavigationModel: searchNavigationModel,
            searchViewModel: searchViewModel,
            realmModel: realmModel,
            tabType: .lists
        )
        
        /// set the details search view model
        searchNavigationController.detailsSearchViewModel = slidesSearchViewModel
        searchNavigationController.detailsSearchPromptViewModel = slidesSearchPromptViewModel
        searchNavigationController.progressViewModel = searchNavigationProgressViewModel
        
        searchNavigationModel.onWillBecomeActive = { viewController.willBecomeActive() }
        searchNavigationModel.onDidBecomeActive = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                if searchViewModel.enabled {
                    UIAccessibility.post(notification: .screenChanged, argument: searchNavigationController.searchContainerView)
                } else {
                    UIAccessibility.post(notification: .screenChanged, argument: viewController.view)
                }
            }
            viewController.didBecomeActive()
        }
        searchNavigationModel.onWillBecomeInactive = { viewController.willBecomeInactive() }
        searchNavigationModel.onDidBecomeInactive = { viewController.didBecomeInactive() }
        searchNavigationModel.onBoundsChange = { size, safeAreaInset in
            viewController.boundsChanged(to: size, safeAreaInsets: safeAreaInset)
        }
        
        self.searchNavigationController = searchNavigationController
        
        viewController.updateNavigationBar = { [weak self] in
            guard let self = self else { return }
            self.searchNavigationController.updateSearchBarOffset()
            tabViewModel.excludedFrames[.photosSearchBar] = searchNavigationController.searchContainerView.windowFrame()
        }
        
        configureTransitions(for: searchNavigationController)
        
        model.getRealmModel = { [weak self] in
            self?.realmModel ?? RealmModel()
        }
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
       
        model.updateSearchCollectionView = {
            searchNavigationController.searchViewController.collectionViewModel.highlightingAddWordField = false
            searchNavigationController.searchViewController.collectionViewModel.focusedCellIndex = 0
            searchNavigationController.searchViewController?.reload()
        }
        
        model.updateSlidesSearchCollectionView = {
            /// reload the details search bar.
            searchNavigationController.detailsSearchViewController?.collectionViewModel.replaceInPlace(
                with: searchNavigationController.searchViewController.collectionViewModel
            )
            
            /// update the focused index.
            searchNavigationController.detailsSearchViewController?.collectionViewModel.focusedCellIndex = searchNavigationController.searchViewController?.collectionViewModel.focusedCellIndex
            
            /// reload the collection view.
            searchNavigationController.detailsSearchViewController?.reload()
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
                searchNavigationController.continueSearchBarTransitionAnimation(to: slides, targetPercentage: targetPercentage)
                searchNavigationController.showDetailsSearchBar(true)
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
                searchNavigationController.continueSearchBarTransitionAnimation(to: photos, targetPercentage: targetPercentage)
                searchNavigationController.showDetailsSearchBar(false)
            }
            popAnimator?.additionalCompletion = {
                searchNavigationController.finishSearchBarTransitionAnimation(to: photos)
            }
            
            /// progress is from 0 to 1. 0 = just started dismissing, 1 = fully dismissed.
            dismissAnimator?.progressUpdated = { progress in
                searchNavigationController.setBlur(from: slides, to: photos, percentage: progress)
                searchNavigationController.setOffset(from: slides, to: photos, percentage: progress)
                searchNavigationController.adjustShowingDetailsSearchBar(percentage: 1 - progress)
            }
            
            dismissAnimator?.additionalFinalAnimations = { completed in
                if completed {
                    let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: photos)
                    searchNavigationController.beginSearchBarTransitionAnimation(to: photos, targetPercentage: targetPercentage)
                    searchNavigationController.continueSearchBarTransitionAnimation(to: photos, targetPercentage: targetPercentage)
                    searchNavigationController.showDetailsSearchBar(false)
                } else {
                    let targetPercentage = searchNavigationController.getViewControllerBlurPercentage(for: slides)
                    searchNavigationController.beginSearchBarTransitionAnimation(to: slides, targetPercentage: targetPercentage)
                    searchNavigationController.continueSearchBarTransitionAnimation(to: slides, targetPercentage: targetPercentage)
                    searchNavigationController.showDetailsSearchBar(true)
                }
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
