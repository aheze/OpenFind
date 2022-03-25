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
    static let height: CGFloat = font.lineHeight + selectionEdgeInsets.top + selectionEdgeInsets.bottom + outerPadding

    static let outerPadding = CGFloat(5)
    static let bottomPadding = CGFloat(12)
}

class SliderViewModel: ObservableObject {
    enum Filter {
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

    /// A UI selection (wraps a filter)
    struct Selection: Identifiable {
        let id = UUID()
        var filter: Filter
        var frame: CGRect?
    }

    @Published var selectedFilter: Filter? {
        didSet {
            if let selectedFilter = selectedFilter {
                filterChanged?(selectedFilter)
            }
        }
    }

    /// selection changed
    var filterChanged: ((Filter) -> Void)?

    @Published var hoveringFilter: Filter?

    /// if false, just change opacity
    @Published var indicatorMovable = true
    @Published var selections: [Selection] = [
        .init(filter: .starred),
        .init(filter: .screenshots),
        .init(filter: .all)
    ]

    func change(to filter: Filter) {
        withAnimation(.spring()) {
            self.selectedFilter = filter
        }
    }

    init() {
        selectedFilter = selections.last?.filter
    }
}

struct SliderView: View {
    @ObservedObject var model: SliderViewModel
    var body: some View {
        HStack(spacing: SliderConstants.spacing) {
            ForEach(model.selections.indices) { index in
                let selection = model.selections[index]

                Text(selection.filter.getString())
                    .font(Font(SliderConstants.font as CTFont))
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(maxWidth: .infinity)
                    .padding(SliderConstants.selectionEdgeInsets)
                    .scaleEffect(getScale(for: selection.filter))
                    .foregroundColor(.white)
                    .colorMultiply(getForegroundColor(for: selection.filter).color)
                    .readFrame(in: .named("Slider")) { frame in
                        model.selections[index].frame = frame
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(SliderConstants.outerPadding)
        .coordinateSpace(name: "Slider")
        .contentShape(Rectangle())
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
                .scaleEffect(model.indicatorMovable ? (model.hoveringFilter == nil ? 1 : 0.95) : 1)
                .frame(with: getFrame())
        )
        .background(
            ZStack {
                VisualEffectView(.regular)
            }
            .mask(Capsule())
        )
        .padding()
    }

    func getForegroundColor(for filter: SliderViewModel.Filter) -> UIColor {
        if model.indicatorMovable {
            if let hoveringFilter = model.hoveringFilter {
                if hoveringFilter == filter {
                    return .white
                }
            } else if
                let selectedFilter = model.selectedFilter,
                selectedFilter == filter
            {
                return .white
            }
        } else {
            if
                let hoveringFilter = model.hoveringFilter,
                hoveringFilter == filter
            {
                return .secondaryLabel.toColor(.systemBackground, percentage: 0.5)
            } else if
                let selectedFilter = model.selectedFilter,
                selectedFilter == filter
            {
                return .white
            }
        }

        return .secondaryLabel
    }

    func getScale(for filter: SliderViewModel.Filter) -> CGFloat {
        if let hoveringFilter = model.hoveringFilter {
            if
                model.indicatorMovable,
                hoveringFilter == filter
            {
                return 0.95
            }
        }

        return 1
    }

    func getFrame() -> CGRect {
        var frame: CGRect?
        if
            model.indicatorMovable,
            let hoveringFilter = model.hoveringFilter,
            let selection = model.selections.first(where: { $0.filter == hoveringFilter })
        {
            frame = selection.frame
        } else if
            let selectedFilter = model.selectedFilter,
            let selection = model.selections.first(where: { $0.filter == selectedFilter })
        {
            frame = selection.frame
        }
        return frame ?? .zero
    }
}

extension SliderViewModel {
    /// `ended` - call this once right before release, for predicted end
    func onDragGestureChange(value: DragGesture.Value, ended: Bool) {
        /// first time
        if hoveringFilter == nil {
            if
                let selectedFilter = selectedFilter,
                let selection = selections.first(where: { $0.filter == selectedFilter }),
                let frame = selection.frame,
                (frame.minX ..< frame.maxX).contains(value.location.x)
            {
                indicatorMovable = true
            } else {
                indicatorMovable = false
            }
        }

        if let selection = selections.first(where: {
            guard let frame = $0.frame else { return false }
            let range = frame.minX ..< frame.maxX
            return range.contains(ended ? value.predictedEndLocation.x : value.location.x)
        }) {
            if hoveringFilter != selection.filter {
                withAnimation(.spring()) {
                    hoveringFilter = selection.filter
                }
            }
        }
    }

    func onDragGestureEnd(value: DragGesture.Value) {
        withAnimation(.spring()) {
            if let hoveringFilter = hoveringFilter {
                selectedFilter = hoveringFilter
            }
            hoveringFilter = nil
            indicatorMovable = true
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
