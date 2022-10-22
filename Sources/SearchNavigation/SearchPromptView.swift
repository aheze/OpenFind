//
//  SearchPromptView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/13/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SearchPromptConstants {
    static var padding = EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
    static var font = UIFont.preferredFont(forTextStyle: .body)
}

class SearchPromptViewModel: ObservableObject {
    /// don't set directly, instead use `show()`
    @Published private(set) var show = false
    @Published private(set) var resultsString = ""
    @Published private(set) var numberOfResultsInText: Int?
    @Published private(set) var numberOfResultsInNote: Int?

    @Published private(set) var resetString: String?

    @Published private(set) var voiceOverString = ""

    var updateBarHeight: (() -> Void)?
    var showNote: (() -> Void)?
    var resetPressed: (() -> Void)?

    func update(
        show: Bool,
        resultsString: String? = nil,
        numberOfResultsInText: Int? = nil,
        numberOfResultsInNote: Int? = nil,
        resetString: String? = nil
    ) {
        var voiceOverString = ""
        withAnimation(.easeOut(duration: 0.3)) {
            self.show = show
            self.numberOfResultsInText = numberOfResultsInText
            self.numberOfResultsInNote = numberOfResultsInNote
            self.resetString = resetString
        }

        if let resultsString = resultsString {
            self.resultsString = resultsString
            voiceOverString.append(resultsString)
        }

        if let resetString = resetString {
            voiceOverString.append(". Tap to reset to \(resetString)")
        }

        UIAccessibility.post(notification: .announcement, argument: voiceOverString)
        self.voiceOverString = voiceOverString
    }

    func totalText() -> String {
        var text = resultsString
        if let resetString = resetString {
            text += resetString
        }
        return text
    }

    func height() -> CGFloat {
        let width = UIScreen.main.bounds.width - SearchPromptConstants.padding.leading - SearchPromptConstants.padding.trailing
        let textHeight = totalText().height(
            withConstrainedWidth: width,
            font: SearchPromptConstants.font
        )
        let height = textHeight + SearchPromptConstants.padding.top + SearchPromptConstants.padding.bottom
        return height
    }
}

struct SearchPromptView: View {
    @ObservedObject var model: SearchPromptViewModel
    var body: some View {
        Color.clear.overlay(
            HStack {
                Text(model.resultsString)

                if let numberOfResultsInNote = model.numberOfResultsInNote, numberOfResultsInNote > 0 {
                    Circle()
                        .fill(UIColor.secondaryLabel.color)
                        .frame(width: 2, height: 2)

                    Button {
                        model.showNote?()
                    } label: {
                        Group {
                            if let numberOfResultsInText = model.numberOfResultsInText, numberOfResultsInText > 0 {
                                Text("(\(numberOfResultsInText) in text, \(numberOfResultsInNote) in note)")
                            } else {
                                Text("(\(numberOfResultsInNote) in note)")
                            }
                        }
                        .foregroundColor(UIColor.secondaryLabel.color)
                    }
                }

                if let resetString = model.resetString {
                    Circle()
                        .fill(UIColor.secondaryLabel.color)
                        .frame(width: 2, height: 2)

                    Button {
                        model.resetPressed?()
                    } label: {
                        Text("Reset to \(resetString)")
                            .foregroundColor(.accent)
                    }
                }

                Spacer()
            }
            .font(Font(SearchPromptConstants.font as CTFont))
            .accessibilityElement()
            .accessibilityLabel(model.voiceOverString)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(SearchPromptConstants.padding),
            alignment: .top
        )
        .clipped()
        .opacity(model.show ? 1 : 0)
    }
}
