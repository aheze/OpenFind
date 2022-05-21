//
//  LaunchSceneView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/20/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum LaunchSceneConstants {
    static let tileFlipDuration = CGFloat(0.9)
}

class LaunchSceneModel: ObservableObject {
    @Published var rowVisibleIndex = 0
    @Published var sceneState = SwiftUISceneState.initial
    @Published var characterHighlightIndex = 0
    @Published var showing = true /// hide when entering
    
    var entering: (() -> Void)? /// called when just about to show the main content
    var done: (() -> Void)?

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
                
                let rotation: CGFloat = launchSceneModel.rowVisibleIndex > rowIndex ? 0 : 60
                
                HStack(spacing: spacing) {
                    ForEach(Array(zip(textRow.text.indices, textRow.text)), id: \.1.id) { columnIndex, text in
                        let location = LaunchSceneModel.Location(row: rowIndex, column: columnIndex)
                        
                        LaunchSceneTextView(
                            model: model,
                            launchSceneModel: launchSceneModel,
                            location: location,
                            text: text
                        )
                    }
                }
                .opacity(launchSceneModel.rowVisibleIndex > rowIndex ? 1 : 0)
                .rotation3DEffect(.degrees(rotation), axis: (1, 0, 0))
            }
        }
        .edgesIgnoringSafeArea(.all)
        .rotation3DEffect(.degrees(get3DAngle()), axis: get3DAxis())
        .scaleEffect(getScale())
        .opacity(launchSceneModel.showing ? 1 : 0)
        .onAppear {
            start()
        }
        .onValueChange(of: model.entered) { _, _ in
            
            withAnimation(
                .spring(
                    response: 0.8,
                    dampingFraction: 1,
                    blendDuration: 0
                )
            ) {
                launchSceneModel.sceneState = .overlook
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(
                    Animation.timingCurve(0.6, 0, 1, 0, duration: 1.5)
                ) {
                    launchSceneModel.sceneState = .entered
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.08) {
                    launchSceneModel.entering?()
                    
                    withAnimation(.easeIn(duration: 0.4)) {
                        launchSceneModel.showing = false
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    launchSceneModel.done?()
                }
            }
        }
    }
    
    func getSpacing() -> CGFloat {
        switch launchSceneModel.sceneState {
        case .initial:
            return 120
        case .stable:
            return 18
        case .overlook:
            return 18
        case .entered:
            return 400
        }
    }
    
    func getScale() -> CGFloat {
        switch launchSceneModel.sceneState {
        case .initial:
            return 2
        case .stable:
            return 1
        case .overlook:
            return 1.2
        case .entered:
            return 5
        }
    }
    
    func get3DAngle() -> CGFloat {
        switch launchSceneModel.sceneState {
        case .initial:
            return 30
        case .stable:
            return 5
        case .overlook:
            return 90
        case .entered:
            return 135
        }
    }
    
    func get3DAxis() -> (CGFloat, CGFloat, CGFloat) {
        switch launchSceneModel.sceneState {
        case .initial:
            return (1, 0, 0.74)
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
                response: 5,
                dampingFraction: 0.7,
                blendDuration: 0
            )
        ) {
            launchSceneModel.sceneState = .stable
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            for index in 0 ..< model.height {
                let delay = CGFloat(index) * 0.2
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeIn(duration: 0.18)) {
                        launchSceneModel.rowVisibleIndex += 1
                    }
                }
            }
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                flipRandomNormalTile()
            }
        }
    }
    
    func flipRandomNormalTile() {
        func flip(locations: [LaunchSceneModel.Location], reversed: Bool) {
            let multiplier = CGFloat(reversed ? -1 : 1)
            
            withAnimation(.easeIn(duration: LaunchSceneConstants.tileFlipDuration)) {
                let angle = CGFloat(181) * multiplier
                
                for location in locations {
                    model.textRows[location.row].text[location.column].angle = angle
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + LaunchSceneConstants.tileFlipDuration) {
                withAnimation(.easeOut(duration: LaunchSceneConstants.tileFlipDuration)) {
                    let angle = CGFloat(360) * multiplier
                    for location in locations {
                        model.textRows[location.row].text[location.column].angle = angle
                    }
                }
            }
        }

        guard let location = model.locationsOfNormalText.randomElement() else { return }
        let mirroringLocation = LaunchSceneModel.Location(
            row: model.height - 1 - location.row,
            column: model.width - 1 - location.column
        )
        let locations = [location, mirroringLocation]
        
        flip(locations: locations, reversed: false)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + LaunchConstants.tilesRepeatingAnimationDelay * 2) {
            self.flipRandomNormalTile()
        }
    }
}

struct LaunchSceneTextView: View {
    @ObservedObject var model: LaunchViewModel
    @ObservedObject var launchSceneModel: LaunchSceneModel
    let location: LaunchSceneModel.Location
    let text: LaunchText
    let cornerRadius = CGFloat(16)
    
    var body: some View {
        let textOpacity = getTextOpacity()
        let borderOpacity = getBorderOpacity()
        
        Button {
            withAnimation(.easeIn(duration: LaunchSceneConstants.tileFlipDuration)) {
                let angle = CGFloat(180) * 1
                
                model.textRows[location.row].text[location.column].angle = angle
            }
            
        } label: {
            Color.white.opacity(0.03)
                .frame(width: 70, height: 70)
                .overlay(
                    Text(text.character)
                        .font(.system(size: 54, weight: .bold))
                        .foregroundColor(.white)
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
