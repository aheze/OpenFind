//
//  Pattern.swift
//  Haptica
//
//  Created by Lasha Efremidze on 1/17/19.
//  Copyright © 2019 efremidze. All rights reserved.
//

import Foundation

public extension Haptic {
    static let queue: OperationQueue = .serial
    
    static func play(_ notes: [Note]) {
        guard #available(iOS 10, *), queue.operations.isEmpty else { return }
        
        for note in notes {
            let operation = note.operation
            if let last = queue.operations.last {
                operation.addDependency(last)
            }
            queue.addOperation(operation)
        }
    }
    
    static func play(_ pattern: String, delay: TimeInterval) {
        let notes = pattern.compactMap { Note($0, delay: delay) }
        play(notes)
    }
}

public enum Note {
    case haptic(Haptic)
    case wait(TimeInterval)
    
    init?(_ char: Character, delay: TimeInterval) {
        switch String(char) {
        case "O":
            self = .haptic(.impact(.heavy))
        case "o":
            self = .haptic(.impact(.medium))
        case ".":
            self = .haptic(.impact(.light))
        case "-":
            self = .wait(delay)
        default:
            return nil
        }
    }
    
    var operation: Operation {
        switch self {
        case .haptic(let haptic):
            return HapticOperation(haptic)
        case .wait(let interval):
            return WaitOperation(interval)
        }
    }
}

class HapticOperation: Operation {
    let haptic: Haptic
    init(_ haptic: Haptic) {
        self.haptic = haptic
    }
    override func main() {
        DispatchQueue.main.sync {
            self.haptic.generate()
        }
    }
}
class WaitOperation: Operation {
    let duration: TimeInterval
    init(_ duration: TimeInterval) {
        self.duration = duration
    }
    override func main() {
        Thread.sleep(forTimeInterval: duration)
    }
}
