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

    /// number of photos count
    static let countFont = UIFont.preferredCustomFont(forTextStyle: .caption1, weight: .semibold)
    static let countPadding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)

    static let outerPadding = CGFloat(5)
    static let bottomPadding = CGFloat(12)

    static let maxWidth = CGFloat(500)
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

        func getVoiceOverHint() -> String {
            switch self {
            case .starred:
                return "Display starred photos only"
            case .screenshots:
                return "Display screenshots only"
            case .all:
                return "Display all photos"
            }
        }
    }

    /// A UI selection (wraps a filter)
    struct Selection: Identifiable {
        let id = UUID()
        var filter: Filter
        var frame: CGRect?
        var count: Int?
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
            ForEach(model.selections.indices, id: \.self) { index in
                let selection = model.selections[index]

                HStack {
                    if let count = selection.count {
                        let text = count > 9 ? "9+" : "\(count)"
                        let (foregroundColor, backgroundColor) = getCountColor(for: selection.filter)

                        Text(text)
                            .foregroundColor(foregroundColor.color)
                            .font(Font(SliderConstants.countFont as CTFont))
                            .padding(SliderConstants.countPadding)
                            .background(
                                Capsule()
                                    .fill(backgroundColor.color)
                            )
                            .fixedSize(horizontal: true, vertical: true)
                            .transition(.scale(scale: 0.5).combined(with: .opacity))
                    }

                    Text(selection.filter.getString())
                        .font(Font(SliderConstants.font as CTFont))
                        .colorMultiply(getForegroundColor(for: selection.filter).color)
                        .fixedSize(horizontal: true, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(SliderConstants.selectionEdgeInsets)
                .accessibilityElement()
                .accessibilityLabel(selection.filter.getString())
                .accessibilityHint(selection.filter.getVoiceOverHint())
                .scaleEffect(getScale(for: selection.filter))
                .foregroundColor(.white)
                .opacity(getAlpha(for: selection.filter))
                .readFrame(in: .named("Slider")) { frame in
                    model.selections[index].frame = frame
                }
            }
        }
        .frame(maxWidth: SliderConstants.maxWidth)
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

    /// 1. foreground, 2. background
    func getCountColor(for filter: SliderViewModel.Filter) -> (UIColor, UIColor) {
        return (.white, .black.withAlphaComponent(0.5))
    }

    func getForegroundColor(for filter: SliderViewModel.Filter) -> UIColor {
        if
            model.indicatorMovable && model.hoveringFilter == filter
            || !model.indicatorMovable && model.selectedFilter == filter
            || model.hoveringFilter == nil && model.selectedFilter == filter
        {
            return .white
        }
        return UIColor(named: "SliderActiveBackground")!
    }

    func getAlpha(for filter: SliderViewModel.Filter) -> CGFloat {
        if !model.indicatorMovable && model.hoveringFilter == filter {
            return 0.5
        }

        return 1
    }

    func getScale(for filter: SliderViewModel.Filter) -> CGFloat {
        if
            let hoveringFilter = model.hoveringFilter,
            hoveringFilter == filter,
            model.indicatorMovable
        {
            return 0.95
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
        VStack {
            SliderView(model: model)
            Button {
                withAnimation {
                    model.selections[0].count = 50
                    model.selections[1].count = 190
                    model.selections[2].count = 1
                }
            } label: {
                Text("add")
            }

            Button {
                withAnimation {
                    model.selections[0].count = nil
                    model.selections[1].count = nil
                    model.selections[2].count = nil
                }
            } label: {
                Text("remove")
            }
        }
    }
}

struct SliderViewTester_Previews: PreviewProvider {
    static var previews: some View {
        SliderViewTester()
    }
}
