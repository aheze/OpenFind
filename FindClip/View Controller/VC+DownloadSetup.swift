//
//  VC+DownloadSetup.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import StoreKit
import SwiftUI

extension ViewController {
    func setupDownloadView() {
        let downloadViewController = UIHostingController(rootView: DownloadView())
        addChildViewController(downloadViewController, in: downloadReferenceView)
    }

    func displayOverlay() {
        CurrentState.presentingOverlay = true
        guard let scene = view.window?.windowScene else { return }
        
        let config = SKOverlay.AppClipConfiguration(position: .bottom)
        let overlay = SKOverlay(configuration: config)
        overlay.present(in: scene)
        overlay.delegate = self
    }

    func dismissOverlay() {
        CurrentState.presentingOverlay = false
        guard let scene = view.window?.windowScene else { return }
        DispatchQueue.global().async {
            SKOverlay.dismiss(in: scene)
        }
    }
}

extension ViewController: SKOverlayDelegate {
    func storeOverlayDidFinishDismissal(_ overlay: SKOverlay, transitionContext: SKOverlay.TransitionContext) {
        if CurrentState.currentlyPresenting, CurrentState.presentingOverlay {
            displayOverlay()
        }
    }
}
