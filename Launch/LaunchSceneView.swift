//
//  LaunchSceneView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class LaunchSceneModel: ObservableObject {
    @Published var sceneState = SwiftUISceneState.initial
    @Published var characterHighlightIndex = 0

    struct Location: Equatable {
        var row: Int
        var column: Int
    }
    
    enum SwiftUISceneState {
        case initial /// scattered tiles
        case stable /// tiles together
        case overlook /// above the tiles
        case entered /// entered the tiles
    }
}

struct LaunchSceneView: View {
    @ObservedObject var model: LaunchViewModel
    @ObservedObject var launchSceneModel: LaunchSceneModel
    
    var body: some View {
        let spacing = getSpacing()
        
        VStack(spacing: spacing) {
            ForEach(Array(zip(model.textRows.indices, model.textRows)), id: \.1.id) { rowIndex, textRow in
                HStack(spacing: spacing) {
                    ForEach(Array(zip(textRow.text.indices, textRow.text)), id: \.1.id) { columnIndex, text in
                        
                        LaunchSceneTextView(launchSceneModel: launchSceneModel, text: text)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .rotation3DEffect(.degrees(get3DAngle()), axis: get3DAxis())
        .scaleEffect(getScale())
        .onAppear {
            start()
        }
    }
    
    func getSpacing() -> CGFloat {
        if launchSceneModel.sceneState == .initial {
            return 120
        } else {
            return 18
        }
    }
    
    func getScale() -> CGFloat {
        switch launchSceneModel.sceneState {
        case .initial:
            return 2
        case .stable:
            return 1
        case .overlook:
            return 0.6
        case .entered:
            return 1
        }
    }
    
    func get3DAngle() -> CGFloat {
        switch launchSceneModel.sceneState {
        case .initial:
            return 25
        case .stable:
            return 5
        case .overlook:
            return 0
        case .entered:
            return 0
        }
    }
    
    func get3DAxis() -> (CGFloat, CGFloat, CGFloat) {
        switch launchSceneModel.sceneState {
        case .initial:
            return (0.08, 0, 0.08)
        case .stable:
            return (0.08, 0, 0.08)
        case .overlook:
            return (0, 0, 1)
        case .entered:
            return (0, 0, 1)
        }
    }
}

extension LaunchSceneView {
    func start() {
        withAnimation(
            .spring(
                response: 4,
                dampingFraction: 0.9,
                blendDuration: 1
            )
        ) {
            launchSceneModel.sceneState = .stable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
            for index in 0 ..< 4 {
                let delay = CGFloat(index) * 0.4
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        launchSceneModel.characterHighlightIndex += 1
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                flipRandomNormalTile()
            }
        }
    }
    
    func flipRandomNormalTile() {
        let duration = 0.9
        
        func flip(locations: [LaunchSceneModel.Location], reversed: Bool) {
            let multiplier = CGFloat(reversed ? -1 : 1)
            
            withAnimation(.easeIn(duration: duration)) {
                let angle = CGFloat(180) * multiplier
                
                for location in locations {
                    model.textRows[location.row].text[location.column].angle = angle
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: duration)) {
                    let angle = CGFloat(360) * multiplier
                    for location in locations {
                        model.textRows[location.row].text[location.column].angle = angle
                    }
                }
            }
        }

        guard let randomRow = (0 ..< model.height).randomElement() else { return }
        guard let randomColumn = (0 ..< model.width).randomElement() else { return }
            
        let location = LaunchSceneModel.Location(row: randomRow, column: randomColumn)
        let mirroringLocation = LaunchSceneModel.Location(
            row: model.height - 1 - randomRow,
            column: model.width - 1 - randomColumn
        )
        let locations = [location, mirroringLocation]
        
        flip(locations: locations, reversed: false)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.tilesRepeatingAnimationDelay * 2) {
            self.flipRandomNormalTile()
        }
    }
}

struct LaunchSceneTextView: View {
    @ObservedObject var launchSceneModel: LaunchSceneModel
    let text: LaunchText
    
    let cornerRadius = CGFloat(16)
    
    var body: some View {
        let textOpacity = getTextOpacity()
        let borderOpacity = getBorderOpacity()
        
        Color.white.opacity(0.05)
            .frame(width: 70, height: 70)
            .overlay(
                Text(text.character)
                    .foregroundColor(.white)
                    .font(.system(size: 54, weight: .bold))
                    .opacity(textOpacity)
            )
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.white, lineWidth: 2)
                    .opacity(borderOpacity)
            )
            .rotation3DEffect(.degrees(text.angle), axis: (0, 1, 0), perspective: 0.4)
    }
    
    func getTextOpacity() -> CGFloat {
        if let index = text.isPartOfFindIndex {
            if launchSceneModel.characterHighlightIndex > index {
                return 1
            }
        }
        if text.angle > 0 && text.angle < 360 {
            return 0.8
        }
        
        return 0.3
    }
    
    func getBorderOpacity() -> CGFloat {
        if text.angle > 0 && text.angle < 360 {
            return 0.8
        }
    
        return 0.2
    }
}
