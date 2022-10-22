//
//  ColorPickerView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct ColorColumn: Identifiable, Hashable {
    let id = UUID()
    var colors = [UIColor]()
}

class ColorPickerViewModel: ObservableObject {
    /// for the color picker icon
    @Published var tintColor = UIColor.systemBackground
    @Published var selectedColor = UIColor(hex: 0x00a1d8)
    var selectedColorChanged: (() -> Void)?

    @Published var selectedIndex = (0, 0)
    let colorColumns: [ColorColumn]

    init(selectedColor: UIColor?) {
        var colorColumns = [ColorColumn]()

        /// leftmost color, vertically centered
        let baseColor = UIColor(hex: 0x00a1d8)
        for column in 0..<12 {
            let columnColor = baseColor.offset(by: -CGFloat(column) / CGFloat(12))

            var colors = [UIColor]()
            for row in -3..<5 {
                let color = columnColor.adjust(by: CGFloat(row) / CGFloat(6))
                colors.append(color)
            }

            let colorColumn = ColorColumn(colors: colors)
            colorColumns.append(colorColumn)
        }
        self.colorColumns = colorColumns

        if let selectedColor = selectedColor {
            self.selectedColor = selectedColor
        }

        for (column, columnColors) in colorColumns.enumerated() {
            if let row = columnColors.colors.firstIndex(where: { $0.hex == self.selectedColor.hex }) {
                self.selectedIndex = (column, row)
            }
        }
    }
}

class ColorPickerNavigationViewController: UIViewController {
    var model: ColorPickerViewModel
    init(model: ColorPickerViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var colorPickerViewController: ColorPickerViewController?
    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground

        let colorPickerViewController = ColorPickerViewController(model: model)
        let navigationController = UINavigationController(rootViewController: colorPickerViewController)
        self.colorPickerViewController = colorPickerViewController
        addChildViewController(navigationController, in: view)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewController = colorPickerViewController {
            viewController.title = "Colors"
            viewController.navigationItem.largeTitleDisplayMode = .never
            viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.menuButton(self, action: #selector(self.dismissSelf), imageName: "Dismiss")
        }
    }

    @objc func dismissSelf() {
        self.dismiss(animated: true)
    }
}

class ColorPickerViewController: UIViewController {
    var model: ColorPickerViewModel
    init(model: ColorPickerViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var viewController: UIViewController?
    override func loadView() {
        /**
         Instantiate the base `view`.
         */
        view = UIView()
        view.backgroundColor = .systemBackground

        let containerView = ColorPickerView(model: model)
        let hostingController = UIHostingController(rootView: containerView)
        addChildViewController(hostingController, in: view)
    }
}

struct ColorPickerView: View {
    @ObservedObject var model: ColorPickerViewModel

    var body: some View {
        VStack {
            ColorPaletteView(model: model)

            Spacer()
        }
        .padding(16)
    }
}

struct ColorPaletteView: View {
    @ObservedObject var model: ColorPickerViewModel
    @State var colorPaletteSize = CGSize.zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                ForEach(model.colorColumns, id: \.self) { colorColumn in
                    VStack(spacing: 0) {
                        ForEach(colorColumn.colors, id: \.self) { color in
                            Color(color)
                        }
                    }
                }
            }

            .aspectRatio(CGFloat(12) / 8, contentMode: .fit)
            .coordinateSpace(name: "Color")
            .readSize {
                colorPaletteSize = $0
            }
            .cornerRadius(12)
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("Color"))
                    .onChanged { value in
                        let x = value.location.x / colorPaletteSize.width
                        let y = value.location.y / colorPaletteSize.height

                        let column = min(11, Int(x * 12))
                        let row = min(7, Int(y * 8))

                        if
                            model.colorColumns.indices.contains(column),
                            model.colorColumns[column].colors.indices.contains(row)
                        {
                            model.selectedColor = model.colorColumns[column].colors[row]
                            model.selectedIndex = (column, row)
                            model.selectedColorChanged?()
                        }
                    }
            )

            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.white, lineWidth: 4)
                .frame(width: colorPaletteSize.width / 12, height: colorPaletteSize.width / 12)
                .allowsHitTesting(false)
                .offset(
                    CGSize(
                        width: CGFloat(model.selectedIndex.0) * colorPaletteSize.width / 12,
                        height: CGFloat(model.selectedIndex.1) * colorPaletteSize.height / 8
                    )
                )
        }
    }
}
