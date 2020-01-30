//
//  Item.swift
//  To-Do
//
//  Created by Andrew on 6/8/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit
import RealmSwift

class RealmComponent: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    @objc dynamic var x: Float = 0
    @objc dynamic var y: Float = 0
    @objc dynamic var height: Float = 0
    @objc dynamic var width: Float = 0
    @objc dynamic var text = ""
//    var parentCategory = LinkingObjects(fromType: Photo.self, property: "items")
    @objc dynamic var photo: RealmPhoto!
}
