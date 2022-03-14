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
    @Published var show = false
    @Published var resultsText = ""
    @Published var resetText: String?
    
    func show(_ show: Bool) {
        withAnimation {
            self.show = show
        }
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
            VStack(alignment: .leading) {
                if let resetText = model.resetText {
                    Text(model.resultsText)
                        .font(Font(SearchPromptConstants.font as CTFont))

                        + Text(#"Reset to "\#(resetText)""#)
                        .font(Font(SearchPromptConstants.font as CTFont))
                        .foregroundColor(.accent)
                } else {
                    Text(model.resultsText)
                        .font(Font(SearchPromptConstants.font as CTFont))
                }
            }
            .padding(SearchPromptConstants.padding),
            alignment: .top
        )
        .clipped()
        .opacity(model.show ? 1 : 0)
    }
}
