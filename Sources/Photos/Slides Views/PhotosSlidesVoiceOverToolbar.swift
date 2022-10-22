//
//  PhotosSlidesVoiceOverToolbar.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/19/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct PhotosSlidesVoiceOverToolbar: View {
    @ObservedObject var model: PhotosViewModel
    @ObservedObject var tabViewModel: TabViewModel
    var increment: (() -> Void)?
    var decrement: (() -> Void)?
    var sizeChanged: ((CGSize) -> Void)?
    var body: some View {
        let index = getCurrentIndex()
        let total = getPhotosCount()
        let isFullScreen = getIsFullScreen()
        let label = getLabel(currentIndex: index, total: total, isFullScreen: isFullScreen)

        Color.clear.overlay(
            VStack {
                Text("\(index + 1) / \(total)")
                    .foregroundColor(UIColor.label.color)

                    + Text(isFullScreen ? " (Show Controls)" : " (Hide Controls)")
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .padding(.bottom, tabViewModel.tabBarAttributes.backgroundHeight)
            .accessibilityLabel(label)
            .accessibilityAction {
                model.slidesUpdateFullScreenStateTo?(!isFullScreen)
            }
            .accessibilityAdjustableAction { direction in
                switch direction {
                    case .increment:
                        increment?()
                    case .decrement:
                        decrement?()
                    @unknown default:
                        break
                }
            }
            .background(
                VisualEffectView(.regular)
            )
            .readSize {
                sizeChanged?($0)
            }
        )
        .edgesIgnoringSafeArea(.all)
    }

    func getCurrentIndex() -> Int {
        guard let slidesState = model.slidesState else { return 0 }
        if let currentIndex = slidesState.getCurrentIndex() {
            return currentIndex
        }
        return 0
    }

    func getPhotosCount() -> Int {
        guard let slidesState = model.slidesState else { return 0 }
        return slidesState.slidesPhotos.count
    }

    func getLabel(currentIndex: Int, total: Int, isFullScreen: Bool) -> String {
        let fullScreenText = isFullScreen ? "exit" : "enter"
        if total == 1 {
            return "\(currentIndex + 1) out of \(total) photo. Double-tap to \(fullScreenText) full screen."
        } else {
            return "\(currentIndex + 1) out of \(total) photos. Double-tap to \(fullScreenText) full screen mode"
        }
    }

    func getIsFullScreen() -> Bool {
        return model.slidesState?.isFullScreen ?? false
    }
}

/// for VoiceOver
class PhotosSlidesCollectionToolbar: UIView {
    var model: PhotosViewModel?
    var increment: (() -> Void)?
    var decrement: (() -> Void)?

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return .adjustable
        } set {
            super.accessibilityTraits = newValue
        }
    }

    override var accessibilityValue: String? {
        get {
            guard let slidesState = model?.slidesState else { return nil }
            if let currentIndex = slidesState.getCurrentIndex() {
                if slidesState.slidesPhotos.count == 1 {
                    return "\(currentIndex) out of \(slidesState.slidesPhotos.count) photo"
                } else {
                    return "\(currentIndex) out of \(slidesState.slidesPhotos.count) photos"
                }
            }
            return nil
        } set {
            super.accessibilityValue = newValue
        }
    }

    override func accessibilityIncrement() {
        increment?()
    }

    override func accessibilityDecrement() {
        decrement?()
    }
}
