//
//  ViewController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI
import Popovers

class ViewController: UIViewController {
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    
    var fields = [
        Field(text: .init(value: .string(""), colorIndex: 0)),
        Field(text: .init(value: .list(
            List(
                name: "List",
                desc: "Desc",
                contents: ["Word", "Branch", "Water", "Dirt"],
                iconImageName: "plus",
                iconColorName: 0x00aeef,
                dateCreated: Date()
            )
        ), colorIndex: 1)),
        Field(text: .init(value: .addNew(""), colorIndex: 2))
    ]
    
    @IBAction func wordPressed(_ sender: Any) {
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "WORD"
        fieldSettingsModel.defaultColor = self.fields[0].text.color
        fieldSettingsModel.selectedColor = self.fields[0].text.color
        fieldSettingsModel.alpha = self.fields[0].text.colorAlpha
        fieldSettingsModel.words = []
        fieldSettingsModel.showingWords = false
        fieldSettingsModel.editListPressed = nil
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel)

        var popover = Popover(attributes: .init()) {
            popoverView
        }
        
        popover.attributes.sourceFrame = { [weak wordLabel] in wordLabel.windowFrame() }
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = {
            [
                self.purpleButton.windowFrame(),
                self.listButton.windowFrame(),
                self.listLabel.windowFrame(),
                self.tipButton.windowFrame(),
                self.holdButton.windowFrame()
            ]
        }
        popover.attributes.tag = "Field Popover"
        Popovers.present(popover)
    }
    
    @IBOutlet weak var listButton: UIButton!
    @IBAction func listPressed(_ sender: Any) {
        
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "LIST"
        fieldSettingsModel.defaultColor = self.fields[1].text.color
        fieldSettingsModel.selectedColor = self.fields[1].text.color
        fieldSettingsModel.alpha = self.fields[1].text.colorAlpha
        fieldSettingsModel.words = ["Hello", "Other word", "Ice", "Water", "Context", "Popover", "Mud"]
        
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel)
        
        var popover = Popover(attributes: .init()) {
            popoverView
        }
        
        fieldSettingsModel.editListPressed = {
            Popovers.dismiss(popover)
        }
        
        popover.attributes.sourceFrame = { [weak listLabel] in listLabel.windowFrame() }
        popover.attributes.presentation.animation = .spring()
        popover.attributes.presentation.transition = .opacity
        popover.attributes.dismissal.animation = .spring()
        popover.attributes.dismissal.transition = .opacity
        popover.attributes.dismissal.excludedFrames = {
            [
                self.purpleButton.windowFrame(),
                self.listButton.windowFrame(),
                self.listLabel.windowFrame()
            ]
        }
        popover.attributes.tag = "Field Popover"
        
        if let oldPopover = Popovers.popover(tagged: "Field Popover") {
            Popovers.replace(oldPopover, with: popover)
        } else {
            Popovers.present(popover)
        }
    }
    
    @IBOutlet weak var tipButton: UIButton!
    @IBAction func tipPressed(_ sender: Any) {
    }
    
    @IBOutlet weak var holdButton: UIButton!
    @IBAction func holdDown(_ sender: Any) {
    }
    
    @IBAction func holdUp(_ sender: Any) {
    }
    
    @IBOutlet weak var purpleButton: UIButton!
    @IBAction func purpleButtonPressed(_ sender: Any) {
        print("purple pressed")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


