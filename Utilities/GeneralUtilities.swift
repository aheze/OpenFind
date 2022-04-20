//
//  Utilities.swift
//  Find
//
//  Created by Zheng on 11/18/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

enum Utilities {
    static func deviceVersion() -> Int {
        if #available(iOS 14, *) {
            return 14
        } else {
            return 13
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

/// https://stackoverflow.com/a/29109176/14351818
extension Set {
    func mapSet<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(lazy.map(transform))
    }
}

/// set a symbol configuration
extension UIImageView {
    func setIconFont(font: UIFont) {
        contentMode = .center
        preferredSymbolConfiguration = .init(font: font)
    }
}

enum AnimatableUtilities {
    static func mixedValue(from: CGFloat, to: CGFloat, progress: CGFloat) -> CGFloat {
        let value = from + (to - from) * progress
        return value
    }

    static func mixedValue(from: CGPoint, to: CGPoint, progress: CGFloat) -> CGPoint {
        let valueX = from.x + (to.x - from.x) * progress
        let valueY = from.y + (to.y - from.y) * progress
        return CGPoint(x: valueX, y: valueY)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

class TimeElapsed {
    let startTime: CFAbsoluteTime
    var endTime: CFAbsoluteTime?

    init() {
        startTime = CFAbsoluteTimeGetCurrent()
    }

    func stop() -> String {
        endTime = CFAbsoluteTimeGetCurrent()
        if let duration = getDuration() {
            return String(format: "Time: %.5f", duration)
        }
        return "[No Time]"
    }

    func getDuration() -> CFAbsoluteTime? {
        if let endTime = endTime {
            return endTime - startTime
        } else {
            return nil
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}

extension UIApplication {
    static var rootViewController: UIViewController? {
        UIApplication.shared.windows.first?.rootViewController
    }
}
