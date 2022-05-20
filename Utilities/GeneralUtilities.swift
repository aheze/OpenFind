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

    /// version of the app, for example `2.0.3`
    static func getVersionString() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
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

    /// stop and print
    func end() {
        let string = stop()
        Swift.print(string)
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

    static var topmostViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        return nil
    }
}

/// from https://github.com/boraseoksoon/Throttler
/// struct debouncing successive works with provided options.
public enum Debouncer {
    typealias WorkIdentifier = String

    private static var workers: [WorkIdentifier: Worker] = [:]

    /// Debounce a work
    ///
    ///     for i in 0...100000 {
    ///         Debouncer.debounce {
    ///             prin("your work : \(i)")
    ///         }
    ///     }
    ///
    ///     prin("done!")
    ///
    ///     1. if shouldRunImmediately is true,
    ///     => "your work : 0"
    ///     otherwise, ignored.
    ///     2. .... suppressing all the works, and the last
    ///     3. "your work : 100000"
    ///     4. "done!"
    ///
    /// - Note: Pay special attention to the identifier parameter. the default identifier is \("Thread.callStackSymbols") to make api trailing closure for one liner for the sake of brevity. However, it is highly recommend that a developer should provide explicit identifier for their work to debounce. Also, please note that the default queue is global queue, it may cause thread explosion issue if not explicitly specified, so use at your own risk.
    ///
    /// - Parameters:
    ///   - identifier: the identifier to group works to debounce. Throttler must have equivalent identifier to each work in a group to debounce.
    ///   - queue: a queue to run a work on. dispatch global queue will be chosen by default if not specified.
    ///   - delay: delay for debounce. time unit is second. given default is 1.0 sec.
    ///   - shouldRunImmediately: a boolean type where true will run the first work immediately regardless.
    ///   - work: a work to run
    /// - Returns: Void
    public static func debounce(identifier: String = "\(Thread.callStackSymbols)",
                                queue: DispatchQueue? = nil,
                                delay: DispatchQueue.SchedulerTimeType.Stride = .seconds(1),
                                shouldRunImmediately: Bool = true,
                                work: @escaping () -> Void)
    {
        var worker: Worker?
        let isFirstRun = workers[identifier] == nil ? true : false

        if let w = workers[identifier] {
            worker = w
        } else {
            workers[identifier] = Worker(queue: queue, delay: delay)
            worker = workers[identifier]
        }

        worker!.deploy(
            work: work,
            shouldRunImmediately: shouldRunImmediately && isFirstRun
        )
    }

    private class Worker {
        private let queue: DispatchQueue?
        private let delay: DispatchQueue.SchedulerTimeType.Stride
        private var workItem: DispatchWorkItem?

        fileprivate init(queue: DispatchQueue? = nil,
                         delay: DispatchQueue.SchedulerTimeType.Stride)
        {
            self.queue = queue
            self.delay = delay
        }

        fileprivate func deploy(work: @escaping () -> Void,
                                shouldRunImmediately: Bool)
        {
            if shouldRunImmediately, workItem == nil {
                workItem = DispatchWorkItem(block: work)
                work()
            } else {
                debounce(work)
            }
        }

        private func debounce(_ work: @escaping () -> Void) {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: work)

            let q = queue == nil ? DispatchQueue.global() : queue

            q?.asyncAfter(
                deadline: DispatchTime.now() + delay.timeInterval,
                execute: workItem!
            )
        }
    }
}
