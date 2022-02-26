//
//  Model.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Photos
import UIKit

struct Photo: Hashable {
    var asset: PHAsset
    var metadata: PhotoMetadata?

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.asset)
    }

    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.asset == rhs.asset
    }
}

struct PhotoMetadata {
    var assetIdentifier = ""
    var sentences = [Sentence]()
    var isScanned = false
    var isStarred = false
}

struct Sentence {
    var letters = [Letter]()
    var confidence: Double

    /// combine the letters
    func getString() -> String {
        return self.letters.map { $0.string }.joined()
    }

    func getFrameAndRotation(for range: Range<Int>) -> (CGRect, CGFloat) {
        let letters = Array(letters[range])
        guard
            let firstLetter = letters.first,
            let lastLetter = letters.last
        else {
            return (.zero, 0)
        }

        let frame = firstLetter.frame.union(lastLetter.frame)

        let firstLetterMidpoint = CGPoint(x: firstLetter.frame.midX, y: firstLetter.frame.midY)
        let lastLetterMidpoint = CGPoint(x: lastLetter.frame.midX, y: lastLetter.frame.midY)

        /// from the x axis. 0° is no rotation.
        let angle = firstLetterMidpoint.angle(to: lastLetterMidpoint)

//        print("frame: \(frame), angle: \(angle). First: \(firstLetterMidpoint) to \(lastLetterMidpoint)")
        return (frame, angle)
    }
}

struct Letter {
    var string = ""
    var frame: CGRect
}

/**
 Models for the search bar. Includes color.
 */

enum Value {
    case word(Word)
    case list(List)
}

struct Word: Equatable {
    var id = UUID()
    var string = ""
    var color: UInt = 0x00AEEF
}

struct List: Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var desc = ""
    var icon = "bubble.left"
    var color: UInt = 0x007EEF
    var words: [String] = [""]
    var dateCreated = Date()

    func getEditableList() -> EditableList {
        let editableList = EditableList(
            id: self.id,
            name: self.name,
            desc: self.desc,
            icon: self.icon,
            color: self.color,
            words: self.words.map { EditableWord(string: $0) },
            dateCreated: self.dateCreated
        )
        return editableList
    }

    /// false if words is empty
    var containsWords: Bool {
        let joined = self.words.joined()
        return !joined.isEmpty
    }

    var displayedName: String {
        return self.name.isEmpty ? "Untitled" : self.name
    }
}

struct EditableList {
    var id: UUID
    var name: String
    var desc: String
    var icon: String
    var color: UInt
    var words: [EditableWord]
    var dateCreated: Date

    func getList() -> List {
        let list = List(
            id: self.id,
            name: self.name,
            desc: self.desc,
            icon: self.icon,
            color: self.color,
            words: self.words.map { $0.string },
            dateCreated: self.dateCreated
        )
        return list
    }
}

struct EditableWord {
    let id = UUID()
    var string: String
}
