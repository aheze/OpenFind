//
//  ViewController.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import UIKit
import SwiftUI

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
        } background: {
            PopoverReader { context in
//                let _ = print("--- Word context \(context.isReady): \(context.frame)")
                Color.green.opacity(0.3)
                    .offset(x: context.frame.origin.x, y: context.frame.origin.y)
                    .frame(width: context.isReady ? context.frame.width : nil, height: context.isReady ? context.frame.height : nil)
            }
        }
        
        popover.position = .relative(
            .init(
                containerFrame: { return self.view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 20, dy: 20) },
                popoverAnchor: .left
            )
        )
        print("new position set. \(popover.position)")
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
        //        var popover = Popover { popoverView }
        var popover = Popover(attributes: .init()) {
            popoverView
        } background: {
            PopoverReader { context in
                let _ = print("--- List context \(context.isReady): \(context.frame)")
                Color.blue.opacity(0.3)
                    .offset(x: context.frame.origin.x, y: context.frame.origin.y)
                    .frame(width: context.isReady ? context.frame.width : nil, height: context.isReady ? context.frame.height : nil)
            }
        }
        
        fieldSettingsModel.editListPressed = {
            Popovers.dismiss(popover)
        }
        
        popover.position = .absolute(
            .init(
                originFrame: listLabel.popoverOriginFrame(),
                originAnchor: .bottomLeft,
                popoverAnchor: .topLeft
            )
        )
        popover.attributes.presentation.animation = .easeOut(duration: 4)
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
        if let wordPopover = Popovers.popover(tagged: "Field Popover") {
            var newPopover = wordPopover
            newPopover.position = .relative(
                .init(
                    containerFrame: { self.view.safeAreaLayoutGuide.layoutFrame },
                    popoverAnchor: .bottom
                )
            )
            Popovers.replace(wordPopover, with: newPopover)
        }
    }
    
    @IBOutlet weak var holdButton: UIButton!
    @IBAction func holdDown(_ sender: Any) {
        if let wordPopover = Popovers.popover(tagged: "Field Popover") {
            var newPopover = wordPopover
            newPopover.position = .relative(
                .init(
                    containerFrame: { self.view.safeAreaLayoutGuide.layoutFrame },
                    popoverAnchor: .top
                )
            )
            Popovers.replace(wordPopover, with: newPopover)
        }
    }
    
    @IBAction func holdUp(_ sender: Any) {
        if let wordPopover = Popovers.popover(tagged: "Field Popover") {
            var newPopover = wordPopover
            newPopover.position = .relative(
                .init(
                    containerFrame: { self.view.safeAreaLayoutGuide.layoutFrame },
                    popoverAnchor: .bottom
                )
            )
            Popovers.replace(wordPopover, with: newPopover)
        }
    }
    
    @IBOutlet weak var purpleButton: UIButton!
    @IBAction func purpleButtonPressed(_ sender: Any) {
        print("purple pressed")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


