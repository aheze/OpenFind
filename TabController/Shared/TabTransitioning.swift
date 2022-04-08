//
//  TabTransitioning.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/22/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension TabState {
    /// progress from <camera to photos> or <camera to lists> is going up
    static var progressGoingUpNow = false
    static var isLandscape = false

    var index: Int {
        switch self {
        case .photos:
            return 0
        case .camera:
            return 1
        case .lists:
            return 2
        case .cameraToPhotos:
            return 1
        case .cameraToLists:
            return 1
        }
    }

    var name: String {
        switch self {
        case .photos:
            return "Photos"
        case .camera:
            return "Camera"
        case .lists:
            return "Lists"
        case .cameraToPhotos:
            return ""
        case .cameraToLists:
            return ""
        }
    }

    func getAnimatorProgress() -> CGFloat {
        switch self {
        case .photos:
            return 1
        case .camera:
            return 0
        case .lists:
            return 1
        case .cameraToPhotos(let transitionProgress):
            return transitionProgress
        case .cameraToLists(let transitionProgress):
            return transitionProgress
        }
    }

    func tabBarAttributes() -> TabBarAttributes {
        let lightTabBarAttributes: TabBarAttributes = TabState.isLandscape ? .lightBackgroundLandscape : .lightBackground
        let darkTabBarAttributes: TabBarAttributes = TabState.isLandscape ? .darkBackgroundLandscape : .darkBackground

        switch self {
        case .photos:
            return lightTabBarAttributes
        case .camera:
            return darkTabBarAttributes
        case .lists:
            return lightTabBarAttributes
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: darkTabBarAttributes, to: lightTabBarAttributes)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: darkTabBarAttributes, to: lightTabBarAttributes)
        }
    }

    func photosIconAttributes() -> PhotosIconAttributes {
        switch self {
        case .photos:
            return .active
        case .camera:
            return .inactiveDarkBackground
        case .lists:
            return .inactiveLightBackground
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .active)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .inactiveLightBackground)
        }
    }

    
    
    func cameraIconAttributes() -> CameraIconAttributes {
        let activeCameraIconAttributes: CameraIconAttributes = TabState.isLandscape ? .activeLandscape : .active
        switch self {
        case .photos:
            return .inactive
        case .camera:
            return activeCameraIconAttributes
        case .lists:
            return .inactive
        case .cameraToPhotos(let transitionProgress):

            /// camera is opposite (camera to photos, so need to reverse)
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: activeCameraIconAttributes)
        case .cameraToLists(let transitionProgress):
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: activeCameraIconAttributes)
        }
    }
    
    func cameraLandscapeIconAttributes() -> CameraIconAttributes {
        let activeCameraIconAttributes: CameraIconAttributes = .active
        switch self {
        case .photos:
            return .inactive
        case .camera:
            return activeCameraIconAttributes
        case .lists:
            return .inactive
        case .cameraToPhotos(let transitionProgress):

            /// camera is opposite (camera to photos, so need to reverse)
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: activeCameraIconAttributes)
        case .cameraToLists(let transitionProgress):
            let cameraProgress = max(0, 1 - transitionProgress)
            return .init(progress: cameraProgress, from: .inactive, to: activeCameraIconAttributes)
        }
    }

    func listsIconAttributes() -> ListsIconAttributes {
        switch self {
        case .photos:
            return .inactiveLightBackground
        case .camera:
            return .inactiveDarkBackground
        case .lists:
            return .active
        case .cameraToPhotos(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .inactiveLightBackground)
        case .cameraToLists(let transitionProgress):
            return .init(progress: transitionProgress, from: .inactiveDarkBackground, to: .active)
        }
    }
}

/// for the progress swiping animations
extension TabState {
    static func modifyProgress(current previous: TabState? = nil, new: TabState) {
        switch new {
        case .photos:
            progressGoingUpNow = true
        case .camera:
            progressGoingUpNow = false
        case .lists:
            progressGoingUpNow = true
        case .cameraToPhotos(let newProgress):
            guard let previousTab = previous else { return }
            switch previousTab {
            case .cameraToPhotos(let previousProgress):
                guard newProgress <= 1 else {
                    progressGoingUpNow = true
                    break
                }
                progressGoingUpNow = newProgress > previousProgress
            case .cameraToLists:
                progressGoingUpNow = true
            default: break
            }

        case .cameraToLists(let newProgress):
            guard let previousTab = previous else { return }
            switch previousTab {
            case .cameraToPhotos:
                progressGoingUpNow = true
            case .cameraToLists(let previousProgress):
                guard newProgress <= 1 else {
                    progressGoingUpNow = true
                    break
                }
                progressGoingUpNow = newProgress > previousProgress
            default: break
            }
        }
    }

    /// detect a change in swiping
    static func notifyBeginChange(current: TabState, new: TabState) -> TabState? {
        let progressGoingUpPreviously = progressGoingUpNow
        modifyProgress(current: current, new: new)

        switch current {
        case .cameraToPhotos:
            switch new {
            case .cameraToPhotos:
                if !progressGoingUpPreviously, progressGoingUpNow {
                    /// previously going to camera, now going to photos
                    return .photos
                } else if progressGoingUpPreviously, !progressGoingUpNow {
                    /// previously going to photos, now going to camera
                    return .camera
                }

            case .cameraToLists:
                return .lists
            default: break
            }

        case .cameraToLists:
            switch new {
            case .cameraToPhotos:
                return .photos
            case .cameraToLists:
                if !progressGoingUpPreviously, progressGoingUpNow {
                    /// previously going to camera, now going to lists
                    return .lists
                } else if progressGoingUpPreviously, !progressGoingUpNow {
                    /// previously going to lists, now going to camera
                    return .camera
                }
            default: break
            }
        default: break
        }

        return nil
    }
}
