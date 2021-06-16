//
//  Extensions.swift
//  Haptica
//
//  Created by Lasha Efremidze on 8/16/18.
//  Copyright © 2018 efremidze. All rights reserved.
//

import UIKit

extension UIControl.Event: Hashable {
    public var hashValue: Int {
        return Int(rawValue)
    }
}

func == (lhs: UIControl.Event, rhs: UIControl.Event) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension OperationQueue {
    static var serial: OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }
}
