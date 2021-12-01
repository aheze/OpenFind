//
//  Bridge.swift
//  
//
//  Created by Zheng on 10/7/21.
//

import UIKit

struct Bridge {
    
    static var dismissed: (() -> Void)?
    static var presentTopOfTheList: (() -> Void)?
    static var presentRequiresSoftwareUpdate: ((String) -> Void)?
    static var presentWhatsNew: (() -> Void)?
    static var presentLicenses: (() -> Void)?
    static var presentGeneralTutorial: (() -> Void)?
    static var presentPhotosTutorial: (() -> Void)?
    static var presentListsTutorial: (() -> Void)?
    static var presentListsBuilderTutorial: (() -> Void)?
    static var presentShareScreen: (() -> Void)?
}
