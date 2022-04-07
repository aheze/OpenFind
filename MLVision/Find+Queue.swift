//
//  Find+Queue.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import UIKit

extension Find {
    static func continueQueue() {
        guard startTime == nil else { return }

        for queuedRun in queuedRuns.reversed() {
            if prioritizedAction == nil || prioritizedAction == queuedRun.findOptions.action {
                startTime = Date()
                Task {
                    let sentences = await run(
                        in: queuedRun.image,
                        visionOptions: queuedRun.visionOptions,
                        findOptions: queuedRun.findOptions
                    )

                    /// check if the run still exists (should be unnecessary)
                    guard queuedRuns.contains(where: { $0.image == queuedRun.image }) else { return }

                    queuedRun.completion?(sentences)
                    queuedRuns = queuedRuns.filter { $0.image != queuedRun.image } /// remove image
                    startTime = nil
                }
                break
            }
        }
    }
}
