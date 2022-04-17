//
//  LaunchViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class LaunchViewModel: ObservableObject {
    var textRows = [
        LaunchTextRow(
            text: [
                LaunchText(character: "✭", color: .secondaryLabel),
                LaunchText(character: "✣", color: .secondaryLabel),
                LaunchText(character: "✿", color: .secondaryLabel),
                LaunchText(character: "❂", color: .secondaryLabel),
                LaunchText(character: "❖", color: .secondaryLabel),
                LaunchText(character: "◼︎", color: .secondaryLabel)
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "𝛴", color: .secondaryLabel),
                LaunchText(character: "𝜽", color: .secondaryLabel),
                LaunchText(character: "𝛹", color: .secondaryLabel),
                LaunchText(character: "𝜔", color: .secondaryLabel),
                LaunchText(character: "𝛼", color: .secondaryLabel),
                LaunchText(character: "𝛺", color: .secondaryLabel)
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "❖", color: .secondaryLabel),
                LaunchText(character: "F", color: Colors.accent),
                LaunchText(character: "I", color: Colors.accent),
                LaunchText(character: "N", color: Colors.accent),
                LaunchText(character: "D", color: Colors.accent),
                LaunchText(character: "❖", color: .secondaryLabel)
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "∮", color: .secondaryLabel),
                LaunchText(character: "π", color: .secondaryLabel),
                LaunchText(character: "⧑", color: .secondaryLabel),
                LaunchText(character: "∞", color: .secondaryLabel),
                LaunchText(character: "∴", color: .secondaryLabel),
                LaunchText(character: "➤", color: .secondaryLabel)
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "♛", color: .secondaryLabel),
                LaunchText(character: "♣︎", color: .secondaryLabel),
                LaunchText(character: "♦︎", color: .secondaryLabel),
                LaunchText(character: "♥︎", color: .secondaryLabel),
                LaunchText(character: "♠︎", color: .secondaryLabel),
                LaunchText(character: "♜", color: .secondaryLabel)
            ]
        )
    ]
}
