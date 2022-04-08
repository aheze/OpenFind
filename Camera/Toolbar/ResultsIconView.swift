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
        Button {
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toolbarIconDeactivateAnimationDelay) {
                withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) { scaleAnimationActive = false }
            }
            model.resultsOn.toggle()
            model.resultsPressed?()
        } label: {
            Text("\(model.displayedResultsCount)")
                .foregroundColor(model.resultsOn ? Color(Constants.activeIconColor) : .white)
                .font(.system(size: 19))
                .lineLimit(1)
                .minimumScaleFactor(0.3)
                .padding(5) /// add some padding constraints to the text when it's long
                .frame(width: 40, height: 40)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground(toolbarState: model.toolbarState)
        }
        .frameTag(CameraStatusConstants.sourceViewIdentifier)
    }
}
