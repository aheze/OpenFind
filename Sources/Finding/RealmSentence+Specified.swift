//
//  Finding+RealmPoint.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/31/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import RealmSwift
import UIKit

extension RealmSwift.List where Element: RealmSentence {
    func getSentences() -> [Sentence] {
        return self.map {
            $0.getSentence()
        }
    }
}
