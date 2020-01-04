//
//  ListModel.swift
//  Find
//
//  Created by Andrew on 1/2/20.
//  Copyright © 2020 Andrew. All rights reserved.
//


import UIKit
import RealmSwift

class List: Object {
  @objc dynamic var name = ""
  @objc dynamic var descriptionOfList = ""
  @objc dynamic var contents = ""
  @objc dynamic var iconImageName = ""
  //@objc dynamic var created = Date()
}
