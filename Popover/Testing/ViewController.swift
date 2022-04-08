//
//  ViewController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Popovers
import SwiftUI
import UIKit

class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var listLabel: UILabel!
    
    var fields = [
        Field(
            value: .word(
                .init(
                    string: "",
                    color: Constants.defaultHighlightColor.getFieldColor(for: 0).hex
                )
            )
        ),
        Field(
            value: .list(
                .init(
                    title: "List",
                    description: "Desc",
                    icon: "plus",
                    color: 0x00AEEF,
                    words: ["Word", "Branch", "Water", "Dirt"],
                    dateCreated: Date()
                )
            )
        ),
        Field(
            value: .addNew(
                .init(
                    string: "",
                    color: Constants.defaultHighlightColor.getFieldColor(for: 2).hex
                )
            )
        )
    ]
    
    @IBAction func wordPressed(_ sender: Any) {
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "WORD"
        fieldSettingsModel.defaultColor = UIColor(hex: fields[0].value.getColor())
        fieldSettingsModel.selectedColor = fields[0].overrides.selectedColor
        fieldSettingsModel.alpha = fields[0].overrides.alpha
        fieldSettingsModel.words = []
        fieldSettingsModel.editListPressed = nil
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel, configuration: SearchConfiguration())

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
        present(popover)
    }
    
    @IBOutlet var listButton: UIButton!
    @IBAction func listPressed(_ sender: Any) {
        let fieldSettingsModel = FieldSettingsModel()
        fieldSettingsModel.header = "LIST"
        fieldSettingsModel.defaultColor = UIColor(hex: fields[1].value.getColor())
        fieldSettingsModel.selectedColor = fields[1].overrides.selectedColor
        fieldSettingsModel.alpha = fields[1].overrides.alpha
        fieldSettingsModel.words = ["Hello", "Other word", "Ice", "Water", "Context", "Popover", "Mud"]
        
        let popoverView = FieldSettingsView(model: fieldSettingsModel, configuration: SearchConfiguration.lists)
        
        var popover = Popover(attributes: .init()) {
            popoverView
        }
        
        fieldSettingsModel.editListPressed = {
            self.dismiss(popover)
        }
        
        popover.attributes.sourceFrame = { [weak listLabel] in listLabel.windowFrame() }
        popover.attributes.rubberBandingMode = .none
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
        
        if let oldPopover = self.popover(tagged: "Field Popover") {
            replace(oldPopover, with: popover)
        } else {
            present(popover)
        }
    }
    
    @IBOutlet var tipButton: UIButton!
    @IBAction func tipPressed(_ sender: Any) {}
    
    @IBOutlet var holdButton: UIButton!
    @IBAction func holdDown(_ sender: Any) {}
    
    @IBAction func holdUp(_ sender: Any) {}
    
    @IBOutlet var purpleButton: UIButton!
    @IBAction func purpleButtonPressed(_ sender: Any) {
        let model = CameraViewModel()
        var popover = Popover(attributes: .init()) {
            CameraStatusView(model: model)
        }
        
        popover.attributes.sourceFrame = { [weak purpleButton] in purpleButton.windowFrame() }
        popover.attributes.rubberBandingMode = .none
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
        popover.attributes.tag = "Status Popover"
        
        if let oldPopover = self.popover(tagged: "Status Popover") {
            replace(oldPopover, with: popover)
        } else {
            present(popover)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
