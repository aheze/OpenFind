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
        if
            startTime == nil,
            let queuedRun = queuedRuns.first,
            prioritizedAction == nil || prioritizedAction == queuedRun.action
        {
            startTime = Date()
            Task {
                let sentences = await run(in: queuedRun.image, options: queuedRun.options)
                queuedRun.completion?(sentences)
                queuedRuns.removeFirst()
                startTime = nil
            }
        }
    }
}
