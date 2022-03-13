//
//  SliderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SliderConstants {
    static let selectionEdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    static let spacing = CGFloat(8)
}

class SliderViewModel: ObservableObject {
    enum SelectionType {
        case starred
        case screenshots
        case all

        func getString() -> String {
            switch self {
            case .starred:
                return "Starred"
            case .screenshots:
                return "Screenshots"
            case .all:
                return "All"
            }
        }
    }

    struct Selection: Identifiable, Equatable {
        let id = UUID()
        var type: SelectionType
        var frame: CGRect?
        
        static func == (lhs: Selection, rhs: Selection) -> Bool {
            lhs.type == rhs.type
        }
    }

    @Published var selection: Selection?
    @Published var selections: [Selection] = [
        .init(type: .starred),
        .init(type: .screenshots),
        .init(type: .all)
    ]
    
    func change(to selection: Selection) {
        withAnimation(.spring()) {
            self.selection = selection
        }
    }
    
    init() {
        selection = selections.last
    }
}

struct SliderView: View {
    @ObservedObject var model: SliderViewModel
    var body: some View {
        HStack(spacing: SliderConstants.spacing) {
            ForEach(model.selections.indices) { index in
                let selection = model.selections[index]
                
                Button {
                    model.change(to: selection)
                } label: {
                    Text(selection.type.getString())
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity)
                        .padding(SliderConstants.selectionEdgeInsets)
                        .background(
                            Capsule()
                                .fill(UIColor.secondarySystemBackground.color)
                        )
                }
                .foregroundColor(
                    model.selection == selection
                    ? UIColor.systemBlue.color
                    : UIColor.secondaryLabel.color
                )
                .readFrame { frame in
                    model.selections[index].frame = frame
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(4)
        .background(
            Capsule()
                .fill(UIColor.systemBackground.color)
        )
        .padding()
    }
}

struct SliderViewTester: View {
    @StateObject var model = SliderViewModel()
    var body: some View {
        SliderView(model: model)
    }
}

struct SliderViewTester_Previews: PreviewProvider {
    static var previews: some View {
        SliderViewTester()
    }
}
