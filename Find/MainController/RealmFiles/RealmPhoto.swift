//
//  ListModel.swift
//  Find
//
//  Created by Andrew on 1/2/20.
//  Copyright © 2020 Andrew. All rights reserved.
//


import Foundation
import RealmSwift

class RealmPhoto: Object {
    @objc dynamic var filePath = ""
    @objc dynamic var isHearted = false
    @objc dynamic var contents = ""
    
  //@objc dynamic var created = Date()
}
