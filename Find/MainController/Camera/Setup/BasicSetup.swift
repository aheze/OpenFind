//
//  BasicSetup.swift
//  Find
//
//  Created by Andrew on 10/13/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

enum CurrentModeToggle {
    case classic
    case focused
    case fast
}

//MARK: Set Up the floating buttons, classic timer

extension ViewController {
    func setUpFilePath() {
        guard let url = URL.createFolder(folderName: "historyImages") else {
            print("no create")
            return }
        globalUrl = url
    }
}

