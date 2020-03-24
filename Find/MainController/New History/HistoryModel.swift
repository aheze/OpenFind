//
//  HistoryModel.swift
//  Find
//
//  Created by Zheng on 2/22/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit
import RealmSwift

//class EditableH
class HistoryModel: Object {
    @objc dynamic var filePath = ""
    @objc dynamic var dateCreated = Date()
    let contents = List<SingleHistoryContent>()
    @objc dynamic var isDeepSearched = false
    @objc dynamic var isHearted = false
}

class EditableHistoryModel: NSObject {
    var filePath = ""
    var dateCreated = Date()
    var contents = [SingleHistoryContent]()
    var isDeepSearched = false
    var isHearted = false
}

class SingleHistoryContent: Object {
    @objc dynamic var x = Double(0)
    @objc dynamic var y = Double(0)
    @objc dynamic var width = Double(0)
    @objc dynamic var height = Double(0)

    @objc dynamic var text = ""
}
