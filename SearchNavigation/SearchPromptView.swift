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
    @Published private(set) var resultsText = ""
    @Published private(set) var resetText: String?

    @Published private(set) var voiceOverString = ""
    var updateBarHeight: (() -> Void)?
    var resetPressed: (() -> Void)?

    func update(show: Bool, resultsText: String? = nil, resetText: String? = nil) {
        var voiceOverString = ""
        withAnimation {
            self.show = show
            self.resetText = resetText
        }

        if let resetText = resetText {
            voiceOverString.append(resetText)
        }

        if let resultsText = resultsText {
            self.resultsText = resultsText
            voiceOverString.append(". \(resultsText)")
        }

        UIAccessibility.post(notification: .announcement, argument: voiceOverString)
        self.voiceOverString = voiceOverString
    }

    func totalText() -> String {
        var text = resultsText
        if let resetText = resetText {
            text += resetText
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
                Text(model.resultsText)
                    .font(Font(SearchPromptConstants.font as CTFont))

                if let resetText = model.resetText {
                    Circle()
                        .fill(UIColor.secondaryLabel.color)
                        .frame(width: 2, height: 2)

                    Button {
                        model.resetPressed?()
                    } label: {
                        Text("Reset to \(resetText)")
                            .font(Font(SearchPromptConstants.font as CTFont))
                            .foregroundColor(.accent)
                    }
                }

                Spacer()
            }
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
