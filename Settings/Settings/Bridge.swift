//
//  Bridge.swift
//
//
//  Created by Zheng on 10/7/21.
//

import UIKit

public enum Bridge {
    public static var dismissed: (() -> Void)?
    public static var presentTopOfTheList: (() -> Void)?
    public static var presentRequiresSoftwareUpdate: ((String) -> Void)?
    public static var presentWhatsNew: (() -> Void)?
    public static var presentLicenses: (() -> Void)?
    public static var presentGeneralTutorial: (() -> Void)?
    public static var presentPhotosTutorial: (() -> Void)?
    public static var presentListsTutorial: (() -> Void)?
    public static var presentListsBuilderTutorial: (() -> Void)?
    public static var presentShareScreen: (() -> Void)?
}
