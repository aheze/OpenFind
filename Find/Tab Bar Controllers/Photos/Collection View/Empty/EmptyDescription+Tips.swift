////
////  EmptyDescription+Tips.swift
////  Find
////
////  Created by Zheng on 1/27/21.
////  Copyright © 2021 Andrew. All rights reserved.
////
//
//import UIKit
//
//extension EmptyDescriptionView {
//    func showTutorial() {
//        makeTutorialButtonCurrentlyActive()
//        startTutorial?(currentDisplayedFilter)
//        let stopTutorial = NSLocalizedString("emptyDesc-stopTutorial", comment: "")
//        showMeHowButton.setTitle(stopTutorial, for: .normal)
//    }
//    func stopTutorial() {
//        makeTutorialButtonEnabled()
//        TipViews.finishTutorial()
//    }
//    
//    func makeTutorialButtonEnabled() {
//        DispatchQueue.main.async {
//            let showMeHow = NSLocalizedString("emptyDesc-showMeHow", comment: "")
//            self.showMeHowButton.setTitle(showMeHow, for: .normal)
//            switch self.currentDisplayedFilter {
//            case .local:
//                self.showMeHowButton.tintColor = UIColor(named: "100Blue")
//            case .starred:
//                self.showMeHowButton.tintColor = UIColor(named: "Gold")
//            case .cached:
//                self.showMeHowButton.tintColor = UIColor(named: "100Blue")
//            case .all:
//                break
//            }
//        }
//    }
//    func makeTutorialButtonCurrentlyActive() { /// stop tutorial
//        let stopTutorial = NSLocalizedString("emptyDesc-stopTutorial", comment: "")
//        showMeHowButton.setTitle(stopTutorial, for: .normal)
//    }
//}
