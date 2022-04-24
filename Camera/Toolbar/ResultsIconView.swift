//
//  ResultsIconView.swift
//  Camera
//
//  Created by Zheng on 11/18/21.
//

import SwiftUI

struct ResultsIconView: View {
    @ObservedObject var model: CameraViewModel
    @State var scaleAnimationActive = false

    var body: some View {
        let voiceOverLabel = getLabel()
        Button {
            scale(scaleAnimationActive: $scaleAnimationActive)

            if model.loaded {
                model.resultsOn.toggle()
                model.resultsPressed?()
            }

        } label: {
            Text("\(model.displayedResultsCount)")
                .foregroundColor(model.resultsOn ? .activeIconColor : .white)
                .font(.system(size: 19))
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(5) /// add some padding constraints to the text when it's long
                .frame(width: 40, height: 40)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground(toolbarState: model.toolbarState)
        }
        .accessibilityLabel(voiceOverLabel)
        .accessibilityHint("Double-tap for more information")
        .onValueChange(of: model.displayedResultsCount) { _, _ in
            UIAccessibility.post(notification: .announcement, argument: voiceOverLabel)
        }
        .opacity(model.loaded ? 1 : 0.5)
    }

    func getLabel() -> String {
        if model.displayedResultsCount == 1 {
            return "\(model.displayedResultsCount) result"
        } else {
            return "\(model.displayedResultsCount) results"
        }
    }
}
