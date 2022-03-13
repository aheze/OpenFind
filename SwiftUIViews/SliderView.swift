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
    static let font = UIFont.preferredCustomFont(forTextStyle: .body, weight: .semibold)
    static let height: CGFloat = {
        font.lineHeight + selectionEdgeInsets.top + selectionEdgeInsets.bottom + outerPadding
    }()
    
    static let outerPadding = CGFloat(5)
    static let bottomPadding = CGFloat(16)
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

    struct Selection: Identifiable {
        let id = UUID()
        var type: SelectionType
        var frame: CGRect?
    }

    @Published var selectionType: SelectionType?
    @Published var hoveringSelectionType: SelectionType?
    @Published var dragEnabled = true
    @Published var selections: [Selection] = [
        .init(type: .starred),
        .init(type: .screenshots),
        .init(type: .all)
    ]

    func change(to selectionType: SelectionType) {
        withAnimation(.spring()) {
            self.selectionType = selectionType
        }
    }

    init() {
        selectionType = selections.last?.type
    }
}

struct SliderView: View {
    @ObservedObject var model: SliderViewModel
    var body: some View {
        HStack(spacing: SliderConstants.spacing) {
            ForEach(model.selections.indices) { index in
                let selection = model.selections[index]

                Button {
                    model.change(to: selection.type)
                } label: {
                    Text(selection.type.getString())
                        .font(Font(SliderConstants.font as CTFont))
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity)
                        .padding(SliderConstants.selectionEdgeInsets)
                        .scaleEffect(getScale(for: selection.type))
                }
                .foregroundColor(.white)
                .colorMultiply(getForegroundColor(for: selection.type).color)
                .readFrame(in: .named("Slider")) { frame in
                    model.selections[index].frame = frame
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(SliderConstants.outerPadding)
        .coordinateSpace(name: "Slider")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named("Slider"))
                .onChanged { value in
                    model.onDragGestureChange(value: value, ended: false)
                }
                .onEnded { value in
                    model.onDragGestureChange(value: value, ended: true)
                    model.onDragGestureEnd(value: value)
                }
        )
        .background(
            UIColor.tertiaryLabel.color
                .mask(
                    Capsule()
                )
                .scaleEffect(model.hoveringSelectionType == nil ? 1 : 0.95)
                .frame(with: getFrame())
        )
        .background(
            ZStack {
                VisualEffectView(.prominent)
            }
            .mask(Capsule())
        )
        .padding()
    }

    func getForegroundColor(for type: SliderViewModel.SelectionType) -> UIColor {
        if let hoveringSelectionType = model.hoveringSelectionType {
            if hoveringSelectionType == type {
                return .white
            }
        } else {
            if
                let selectionType = model.selectionType,
                selectionType == type
            {
                return .white
            }
        }

        return .secondaryLabel
    }

    func getScale(for type: SliderViewModel.SelectionType) -> CGFloat {
        if let hoveringSelectionType = model.hoveringSelectionType {
            if hoveringSelectionType == type {
                return 0.95
            }
        }

        return 1
    }

    func getFrame() -> CGRect {
        if
            let hoveringSelectionType = model.hoveringSelectionType,
            let selection = model.selections.first(where: { $0.type == hoveringSelectionType })
        {
            return selection.frame ?? .zero
        } else if
            let selectionType = model.selectionType,
            let selection = model.selections.first(where: { $0.type == selectionType })
        {
            return selection.frame ?? .zero
        } else {
            return .zero
        }
    }
}

extension SliderViewModel {
    /// `ended` - call this once right before release, for predicted end
    func onDragGestureChange(value: DragGesture.Value, ended: Bool) {
        guard dragEnabled else { return }

        /// first time
        if hoveringSelectionType == nil {
            if
                let selectionType = selectionType,
                let selection = selections.first(where: { $0.type == selectionType }),
                let frame = selection.frame,
                (frame.minX ..< frame.maxX).contains(value.location.x)
            {
                dragEnabled = true
            } else {
                dragEnabled = false
                return
            }
        }

        if let selection = selections.first(where: {
            guard let frame = $0.frame else { return false }
            let range = frame.minX ..< frame.maxX
            return range.contains(ended ? value.predictedEndLocation.x : value.location.x)
        }) {
            if hoveringSelectionType != selection.type {
                withAnimation(.spring()) {
                    hoveringSelectionType = selection.type
                }
            }
        }
    }

    func onDragGestureEnd(value: DragGesture.Value) {
        withAnimation(.spring()) {
            if let hoveringSelectionType = hoveringSelectionType {
                selectionType = hoveringSelectionType
            }
            hoveringSelectionType = nil
            dragEnabled = true
        }
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
