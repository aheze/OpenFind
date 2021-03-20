//
//  SymbolView+Strings.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import SwiftUI

struct SymbolList: Identifiable {
    let id = UUID()
    var symbols = [SymbolString]()
}
struct SymbolString: Identifiable {
    let id = UUID()
    var string: String
    
    init(_ string: String) {
        self.string = string
    }
}

extension SymbolsView {
    func populate() {
        var transportation = SymbolList()
        transportation.symbols = [
            SymbolString("car"),
            SymbolString("bus.doubledecker.fill"),
            SymbolString("bicycle"),
            SymbolString("bolt.car"),
            SymbolString("figure.walk"),
            SymbolString("airplane"),
            SymbolString("tram"),
            SymbolString("tram.tunnel.fill"),
            SymbolString("bus"),
            SymbolString("figure.wave")
        ]
        
        var nature = SymbolList()
        nature.symbols = [
            SymbolString("flame"),
            SymbolString("tortoise"),
            SymbolString("hare"),
            SymbolString("ant"),
            SymbolString("leaf"),
            SymbolString("bolt"),
            SymbolString("drop"),
            SymbolString("binoculars"),
            SymbolString("heart"),
            SymbolString("cross.case"),
            SymbolString("waveform.path.ecg"),
            SymbolString("pills"),
            SymbolString("lungs")
        ]
        
        var schoolSupplies = SymbolList()
        schoolSupplies.symbols = [
            SymbolString("pencil"),
            SymbolString("highlighter"),
            SymbolString("pencil.and.outline"),
            SymbolString("folder"),
            SymbolString("paperplane"),
            SymbolString("tray"),
            SymbolString("tray.full"),
            SymbolString("internaldrive"),
            SymbolString("archivebox"),
            SymbolString("doc"),
            SymbolString("doc.on.clipboard"),
            SymbolString("note.text"),
            SymbolString("doc.text.magnifyingglass"),
            SymbolString("tray.2"),
            SymbolString("studentdesk"),
            SymbolString("hourglass")
        ]
        
        var education = SymbolList()
        education.symbols = [
            SymbolString("book"),
            SymbolString("character.book.closed"),
            SymbolString("greetingcard"),
            SymbolString("bookmark"),
            SymbolString("rosette"),
            SymbolString("text.book.closed"),
            SymbolString("graduationcap"),
            SymbolString("ticket"),
            SymbolString("rectangle.and.paperclip"),
            SymbolString("calendar"),
            SymbolString("note"),
            SymbolString("scanner"),
            SymbolString("newspaper"),
            SymbolString("books.vertical"),
            SymbolString("book.closed"),
            SymbolString("flag"),
            SymbolString("tag"),
            SymbolString("wallet.pass"),
            SymbolString("scroll"),
            SymbolString("printer"),
            SymbolString("puzzlepiece")
        ]
        
        var work = SymbolList()
        work.symbols = [
            SymbolString("briefcase"),
            SymbolString("faxmachine"),
            SymbolString("ruler"),
            SymbolString("wrench"),
            SymbolString("hammer"),
            SymbolString("wrench.and.screwdriver"),
            SymbolString("key"),
            SymbolString("map"),
            SymbolString("camera.viewfinder"),
            SymbolString("shippingbox"),
            SymbolString("esim"),
            SymbolString("simcard"),
            SymbolString("lightbulb"),
            SymbolString("bag"),
            SymbolString("banknote")
        ]
        
        var privacy = SymbolList()
        privacy.symbols = [
            SymbolString("bubble.right"),
            SymbolString("text.bubble"),
            SymbolString("envelope"),
            SymbolString("waveform"),
            SymbolString("captions.bubble"),
            SymbolString("hand.raised"),
            SymbolString("shield.lefthalf.fill"),
            SymbolString("hand.thumbsup"),
            SymbolString("person.fill.checkmark"),
            SymbolString("person.and.arrow.left.and.arrow.right"),
            SymbolString("eye.slash"),
            SymbolString("face.smiling"),
            SymbolString("figure.stand.line.dotted.figure.stand")
        ]
        
        
        var editing = SymbolList()
        editing.symbols = [
            SymbolString("slider.vertical.3"),
            SymbolString("rectangle.dashed.badge.record"),
            SymbolString("skew"),
            SymbolString("aspectratio"),
            SymbolString("perspective"),
            SymbolString("selection.pin.in.out"),
            SymbolString("timeline.selection"),
            SymbolString("move.3d"),
            SymbolString("scale.3d"),
            SymbolString("rotate.3d"),
            SymbolString("paintbrush"),
            SymbolString("paintbrush.pointed"),
            SymbolString("scissors"),
            SymbolString("wand.and.stars"),
            SymbolString("dial.min"),
            SymbolString("loupe"),
            SymbolString("circle.lefthalf.fill")
        ]
        
        
        
        
        var home = SymbolList()
        home.symbols = [
            SymbolString("bed.double"),
            SymbolString("eyeglasses"),
            SymbolString("lifepreserver"),
            SymbolString("mustache"),
            SymbolString("face.dashed"),
            SymbolString("eyes"),
            SymbolString("hands.sparkles"),
            SymbolString("deskclock"),
            SymbolString("timer"),
            SymbolString("gamecontroller"),
            SymbolString("circle.grid.cross.left.fill"),
            SymbolString("dpad.right.fill"),
            SymbolString("circle.circle"),
            SymbolString("house")
        ]
        
        var math = SymbolList()
        math.symbols = [
            SymbolString("plus"),
            SymbolString("minus"),
            SymbolString("sum"),
            SymbolString("percent"),
            SymbolString("function"),
            SymbolString("lessthan"),
            SymbolString("greaterthan"),
            SymbolString("multiply"),
            SymbolString("divide"),
            SymbolString("equal"),
            SymbolString("x.squareroot"),
            SymbolString("number")
        ]
        
        
        var keyboard = SymbolList()
        keyboard.symbols = [
            SymbolString("command"),
            SymbolString("keyboard"),
            SymbolString("eject"),
            SymbolString("mount"),
            SymbolString("option"),
            SymbolString("alt"),
            SymbolString("power"),
            SymbolString("globe"),
            SymbolString("sun.min"),
            SymbolString("light.max")
        ]
        
        let numberOfRows = Int(UIScreen.main.bounds.size.width / 30) + 6
        let halfRowsFloat = CGFloat(numberOfRows) / 2
        let halfRows = Int(halfRowsFloat.rounded(.up))
        
        let symbolSource = [transportation, nature, schoolSupplies, education, work, privacy, editing, home, math, keyboard]
        
        var expandedSymbolList = [SymbolList]()
        
        for row in 0..<numberOfRows {
            
            let repeatedRow = row % symbolSource.count
            
            var symbolList = symbolSource[repeatedRow]
            
            let extraIcons: Int
            if row < halfRows {
                extraIcons = row * 2
            } else {
                extraIcons = (numberOfRows - row) * 2
            }
            
            while symbolList.symbols.count <= 30 + extraIcons {
                let repeatedSymbols = symbolList.symbols.map { SymbolString($0.string) }
                symbolList.symbols += repeatedSymbols
            }
            
            expandedSymbolList.append(symbolList)
        }
        
        self.symbols = expandedSymbolList
    }
}
