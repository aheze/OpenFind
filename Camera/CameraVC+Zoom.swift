//
//  CameraVC+Zoom.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 12/28/21.
//  Copyright © 2021 A. Zheng. All rights reserved.
//
    
import SwiftUI

extension CameraViewController {
    func setupZoom() {
        zoomContainerHeightC.constant = (ZoomConstants.zoomFactorLength + ZoomConstants.edgePadding * 2) + ZoomConstants.bottomPadding
        let zoomView = ZoomView(zoomViewModel: zoomViewModel)
        
        let hostingController = UIHostingController(rootView: zoomView)
        hostingController.view.backgroundColor = .clear
        addChildViewController(hostingController, in: zoomContainerView)
        zoomContainerView.backgroundColor = .clear
        
        zoomViewModel.zoomChanged = { [weak self] in
            guard let self = self else { return }
            
            self.livePreviewViewController.changeZoom(to: self.zoomViewModel.zoom, animated: true)
            let scrollViewZoom = self.getScrollViewZoomFrom(percentage: self.zoomViewModel.percentage)
            self.scrollZoomViewController.scrollView.zoomScale = scrollViewZoom
        }
        aspectProgressCancellable = zoomViewModel.$aspectProgress.sink { [weak self] aspectProgress in
            self?.livePreviewViewController.changeAspectProgress(to: aspectProgress, animated: true)
        }
        
        if let camera = livePreviewViewController.cameraDevice {
            zoomViewModel.configureZoomFactors(
                minZoom: camera.minAvailableVideoZoomFactor,
                maxZoom: camera.maxAvailableVideoZoomFactor,
                switchoverFactors: camera.virtualDeviceSwitchOverVideoZoomFactors
            )
        }
    }
    func showZoomView() {
        UIView.animate(withDuration: 0.5) {
            self.zoomContainerView.alpha = 1
            self.zoomContainerView.transform = .identity
        }
    }
    func hideZoomView() {
        UIView.animate(withDuration: 0.3) {
            self.zoomContainerView.alpha = 0
            self.zoomContainerView.transform = .init(scaleX: 0.9, y: 0.9)
        }
    }
    
    /// With scroll
    func hookScrollViewForZooming(_ shouldHook: Bool) {
        if shouldHook {
            scrollZoomViewController.scrollView.minimumZoomScale = ZoomConstants.scrollViewMinZoom
            scrollZoomViewController.scrollView.maximumZoomScale = ZoomConstants.scrollViewMaxZoom
        } else {
            scrollZoomViewController.scrollView.minimumZoomScale = 0.5
            scrollZoomViewController.scrollView.maximumZoomScale = 2
        }
    }
    
    /// get the fraction (0 to 1) of the current zoom
    func getPercentageFrom(zoom: CGFloat) -> CGFloat {
        var percentage = (zoom - zoomViewModel.minZoom) / (zoomViewModel.maxZoom - zoomViewModel.minZoom)
        percentage = max(0, min(1, percentage))
        return percentage
    }
    
    /// get the fraction (0 to 1) of the current scroll view scale
    func getPercentageFrom(scrollViewZoom: CGFloat) -> CGFloat {
        var percentage = (scrollViewZoom - ZoomConstants.scrollViewMinZoom) / (ZoomConstants.scrollViewMaxZoom - ZoomConstants.scrollViewMinZoom)
        percentage = max(0, min(1, percentage))
        return percentage
    }
    
    /// get the scroll view scale for a fraction
    func getScrollViewZoomFrom(percentage: CGFloat) -> CGFloat {
        let scrollViewZoom = ZoomConstants.scrollViewMinZoom + percentage * (ZoomConstants.scrollViewMaxZoom - ZoomConstants.scrollViewMinZoom)
        
        return scrollViewZoom
    }
}
