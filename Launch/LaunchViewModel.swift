//
//  LaunchViewModel.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/16/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    
import SwiftUI

class LaunchViewModel: ObservableObject {
    @Published var showingUI = false
    @Published var currentPage = LaunchPageIdentifier.empty {
        didSet {
            currentPageChanged?()
        }
    }
    var currentPageChanged: (() -> Void)?
    func setCurrentPage(to page: LaunchPageIdentifier) {
        withAnimation {
            currentPage = page
        }
    }
    
    var pages = LaunchPageIdentifier.allCases
    
    var on = true /// if false, stop looping animations.
    
    var tiles = [LaunchTile]()
    
    var textRows = [
        LaunchTextRow(
            text: [
                LaunchText(character: "∮"),
                LaunchText(character: "π"),
                LaunchText(character: "⧑"),
                LaunchText(character: "∞"),
                LaunchText(character: "∴"),
                LaunchText(character: "➤")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "♛"),
                LaunchText(character: "♣︎"),
                LaunchText(character: "♦︎"),
                LaunchText(character: "♥︎"),
                LaunchText(character: "♠︎"),
                LaunchText(character: "♜")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "✭"),
                LaunchText(character: "✣"),
                LaunchText(character: "✿"),
                LaunchText(character: "❂"),
                LaunchText(character: "❖"),
                LaunchText(character: "◼︎")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "𝛴"),
                LaunchText(character: "𝜽"),
                LaunchText(character: "𝛹"),
                LaunchText(character: "𝜔"),
                LaunchText(character: "𝛼"),
                LaunchText(character: "𝛺")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "❖"),
                LaunchText(character: "F", isPartOfFind: true),
                LaunchText(character: "I", isPartOfFind: true),
                LaunchText(character: "N", isPartOfFind: true),
                LaunchText(character: "D", isPartOfFind: true),
                LaunchText(character: "❖")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "∮"),
                LaunchText(character: "π"),
                LaunchText(character: "⧑"),
                LaunchText(character: "∞"),
                LaunchText(character: "∴"),
                LaunchText(character: "➤")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "♛"),
                LaunchText(character: "♣︎"),
                LaunchText(character: "♦︎"),
                LaunchText(character: "♥︎"),
                LaunchText(character: "♠︎"),
                LaunchText(character: "♜")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "✭"),
                LaunchText(character: "✣"),
                LaunchText(character: "✿"),
                LaunchText(character: "❂"),
                LaunchText(character: "❖"),
                LaunchText(character: "◼︎")
            ]
        ),
        LaunchTextRow(
            text: [
                LaunchText(character: "𝛴"),
                LaunchText(character: "𝜽"),
                LaunchText(character: "𝛹"),
                LaunchText(character: "𝜔"),
                LaunchText(character: "𝛼"),
                LaunchText(character: "𝛺")
            ]
        )
    ]
    
    var width: Int {
        textRows.first?.text.count ?? 0
    }
    
    var height: Int {
        textRows.count
    }
}
