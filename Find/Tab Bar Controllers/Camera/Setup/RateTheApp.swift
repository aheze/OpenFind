//
//  RateTheApp.swift
//  Find
//
//  Created by Zheng on 4/1/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import StoreKit

enum AppStoreReviewManager {
  static let minimumReviewWorthyActionCount = 15

  static func requestReviewIfAppropriate() {
    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    var actionCount = defaults.integer(forKey: "reviewWorthyActionCount")

    actionCount += 1

    // 4.
    defaults.set(actionCount, forKey: "reviewWorthyActionCount")

    // 5.
    guard actionCount >= minimumReviewWorthyActionCount else {
      return
    }

    // 6.
    let bundleVersionKey = kCFBundleVersionKey as String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: "lastReviewRequestAppVersion")

    // 7.
    guard lastVersion == nil || lastVersion != currentVersion else {
      return
    }

    // 8.
    SKStoreReviewController.requestReview()

    // 9.
    defaults.set(0, forKey: "reviewWorthyActionCount")
    defaults.set(currentVersion, forKey: "lastReviewRequestAppVersion")
  }
}
