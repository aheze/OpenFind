//
//  ListModel.swift
//  Find
//
//  Created by Andrew on 1/2/20.
//  Copyright © 2020 Andrew. All rights reserved.
//


import UIKit
import RealmSwift

class FindList: Object {
    @objc dynamic var name = ""
    @objc dynamic var descriptionOfList = ""
    //@objc dynamic var contents = ""
    var contents = List<String>()
    @objc dynamic var iconImageName = ""
    @objc dynamic var iconColorName = ""
    @objc dynamic var dateCreated = Date()
}
class EditableFindList: NSObject {
    var name = ""
    var descriptionOfList = ""
    //@objc dynamic var contents = ""
    var contents = [String]()
    var iconImageName = ""
    var iconColorName = ""
}
