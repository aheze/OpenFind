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
    var contents = List<SingleHistoryContent>()
    @objc dynamic var isDeepSearched = false
    @objc dynamic var isHearted = false
}
//class HistoryContent: Object {
//    var contents = List<SingleHistoryContent>()
//}

class SingleHistoryContent: Object {
    @objc dynamic var x = Double(0)
    @objc dynamic var y = Double(0)
    @objc dynamic var text = ""
}
