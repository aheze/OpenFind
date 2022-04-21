//
//  SnapshotView.swift
//  Camera
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct SnapshotConstants {
    /// for a circle with a small gap, as a progress indicator.
    static var loadingStartTrim = CGFloat(0.18)
    static var checkStartTrim = CGFloat(0.644) /// I guessed this number - it's the percentage where the circle becomes the checkmark
}

struct SnapshotView: View {
    @ObservedObject var model: CameraViewModel
    @Binding var isEnabled: Bool

    @State var scaleAnimationActive = false /// scale up/down animation flag

    var body: some View {
        Button {
            scale(scaleAnimationActive: $scaleAnimationActive)

            if model.loaded {
                model.snapshotPressed?()
            }
        } label: {
            Color.clear
                .overlay(
                    Image("CameraRim") /// rim of camera
                        .foregroundColor(model.snapshotState == .saved ? .activeIconColor : .white)
                )
                .overlay(
                    Color(model.snapshotState == .saved ? Colors.activeIconColor : .white)

                        /// prevent animation glitches
                        .mask(
                            CameraInnerShape()
                                .trim(from: startTrim(), to: endTrim())
                                .stroke(
                                    .black,
                                    style: .init(
                                        lineWidth: 1.5,
                                        lineCap: .round,
                                        lineJoin: .round
                                    )
                                )
                                .rotationEffect(.degrees(isSaving ? 360 : 0))
                                .animation(isSaving ? .easeInOut(duration: 0.8).repeatForever(autoreverses: false) : .default, value: model.snapshotState)
                                .padding(EdgeInsets(top: 6, leading: 6, bottom: 4, trailing: 6))
                        )
                )
                .frame(width: 40, height: 40)
                .enabledModifier(isEnabled: isEnabled, linePadding: 11)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground(toolbarState: model.toolbarState)
        }
        .accessibilityLabel("Save to photos.")
        .accessibilityHint("Save photo to the photo library.")
        .disabled(!isEnabled)
    }
    
    func getVoiceOverHint() -> String {
        if model.shutterOn {
            return "Save captured photo to the photo library. Double-tap the shutter to pause and take photo."
        } else {
            return "Save captured photo to the photo library"
        }
    }

    var isSaving: Bool {
        return model.snapshotState == .startedSaving || model.snapshotState == .noImageYet
    }

    func startTrim() -> CGFloat {
        switch model.snapshotState {
        case .inactive:
            return 0
        case .startedSaving:
            return SnapshotConstants.loadingStartTrim
        case .noImageYet:
            return SnapshotConstants.loadingStartTrim
        case .saved:
            return SnapshotConstants.checkStartTrim
        }
    }

    func endTrim() -> CGFloat {
        switch model.snapshotState {
        case .inactive:
            return SnapshotConstants.checkStartTrim
        case .startedSaving:
            return SnapshotConstants.checkStartTrim
        case .noImageYet:
            return SnapshotConstants.checkStartTrim
        case .saved:
            return 1
        }
    }
}

struct ActivityIndicator: UIViewRepresentable {
    typealias UIView = UIActivityIndicatorView
    var isAnimating: Bool
    fileprivate var configuration = { (indicator: UIView) in }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let view = UIView()
        view.style = .medium
        view.color = .white
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
        configuration(uiView)
    }
}

struct CameraInnerShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let circleRadius = CGFloat(4)
        let circleCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)

        path.addArc(
            center: circleCenter,
            radius: circleRadius,
            startAngle: .degrees(179.999999),
            endAngle: .degrees(180),
            clockwise: true
        )

        let checkStartX = rect.width / 2 - 4
        let checkMidX = rect.width / 2 - 0.95
        let checkEndX = rect.width / 2 + 4
        path.move(to: CGPoint(x: checkStartX, y: rect.midY))
        path.addLine(to: CGPoint(x: checkMidX, y: rect.midY + 3.4))
        path.addLine(to: CGPoint(x: checkEndX, y: rect.midY - 4.0))
        return path
    }
}

struct SnapshotViewTester: View {
    @State var isOn = false
    var body: some View {
        SnapshotView(model: CameraViewModel(), isEnabled: .constant(true))
    }
}

struct SnapshotView_Previews: PreviewProvider {
    static var previews: some View {
        SnapshotViewTester()
            .padding()
            .background(Color.blue)
            .scaleEffect(4)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
