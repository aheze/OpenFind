//
//  CameraButton.swift
//  TabController
//
//  Created by Zheng on 12/2/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct CameraButton: View {
    let tabType = TabState.camera
    @ObservedObject var tabViewModel: TabViewModel
    @ObservedObject var cameraViewModel: CameraViewModel
    var attributes: CameraIconAttributes

    var body: some View {
        Button {
            /// is current camera
            if tabViewModel.tabState == tabType {
                if cameraViewModel.loaded {
                    withAnimation(.spring()) {
                        cameraViewModel.shutterOn.toggle()
                    }
                    cameraViewModel.shutterPressed?()
                }
            } else {
                tabViewModel.changeTabState(newTab: tabType, animation: .clickedTabIcon)
            }
        } label: {
            ShutterShape(progress: cameraViewModel.shutterOn ? 1 : 0)
                .fill(attributes.foregroundColor.color)
                .overlay(
                    attributes.rimColor.color
                        .mask(
                            Rectangle()
                                .fill(.black) /// the mask seems to need to be a solid, not changing color
                                .mask(
                                    ShutterShape(progress: cameraViewModel.shutterOn ? 1 : 0)
                                        .stroke(.white, lineWidth: attributes.rimWidth)
                                )
                                .padding(30)
                        )
                        .padding(-30) /// extra canvas padding since the shutter shape content can overflow its bounds
                )
                .frame(width: attributes.length, height: attributes.length)
                .frame(maxWidth: .infinity)
                .frame(height: attributes.backgroundHeight)
                .contentShape(Rectangle())
        }
        .buttonStyle(CameraButtonStyle(isShutter: tabViewModel.tabState == tabType))
        .accessibilityLabel(getVoiceOverLabel())
        .accessibilityValue(getVoiceOverValue())
        .accessibilityHint(getVoiceOverHint())
    }
    
    func getVoiceOverLabel() -> String {
        if tabViewModel.tabState == tabType {
            return "Shutter"
        } else {
            return "Camera"
        }
    }
    func getVoiceOverValue() -> String {
        if tabViewModel.tabState == tabType {
            if cameraViewModel.shutterOn {
                return "Paused"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }

    
    func getVoiceOverHint() -> String {
        if tabViewModel.tabState == tabType {
            if cameraViewModel.shutterOn {
                return "Double-tap to resume the shutter"
            } else {
                return "Double-tap to pause the shutter and take a photo"
            }
        } else {
            return "Navigate to the camera and change this button into a shutter"
        }
    }
}

struct ShutterShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let attributes = ShutterShapeAttributes(progress: progress, from: .circle, to: .triangle, multiplier: rect.width)
        var path = Path()

        path.move(to: attributes.origin)
        path.addArc(tangent1End: attributes.point1, tangent2End: attributes.point2, radius: attributes.cornerRadius)
        path.addArc(tangent1End: attributes.point2, tangent2End: attributes.point3, radius: attributes.cornerRadius)
        path.addArc(tangent1End: attributes.point3, tangent2End: attributes.point1, radius: attributes.cornerRadius)
        path.addLine(to: attributes.origin)
        path = path.offsetBy(dx: rect.width / 2, dy: rect.height / 2)

        return path
    }
}

/// don't conform to protocol, since have custom multiplier function
struct ShutterShapeAttributes {
    let origin: CGPoint
    let cornerRadius: CGFloat
    let yOffset: CGFloat
    let width: CGFloat
    let leftOffset: CGFloat
    let point1: CGPoint
    let point2: CGPoint
    let point3: CGPoint

    static let triangle: Self = {
        let circumference = CGFloat(1) /// set 1 for now, later multiply by the width of the button

        let cornerRadius = circumference / 6

        let width = circumference / 1.4
        let yOffset = sqrt(3) * (width / 2)
        let leftOffset = width / 22
        let point1 = CGPoint(x: (-width / 2) - leftOffset, y: -yOffset)
        let point2 = CGPoint(x: width - leftOffset, y: 0)
        let point3 = CGPoint(x: (-width / 2) - leftOffset, y: yOffset)

        return .init(
            origin: CGPoint(x: (-width / 2) - leftOffset, y: 0),
            cornerRadius: cornerRadius,
            yOffset: yOffset,
            width: width,
            leftOffset: leftOffset,
            point1: point1,
            point2: point2,
            point3: point3
        )
    }()

    static let circle: Self = {
        let circumference = CGFloat(1) /// set 1 for now, later multiply by the width of the button

        let cornerRadius = circumference / 2
        let yOffset = sqrt(3) * (circumference / 2)

        let point1 = CGPoint(x: -circumference / 2, y: -yOffset)
        let point2 = CGPoint(x: circumference, y: 0)
        let point3 = CGPoint(x: -circumference / 2, y: yOffset)

        return .init(
            origin: CGPoint(x: -circumference / 2, y: 0),
            cornerRadius: cornerRadius,
            yOffset: yOffset,
            width: 0,
            leftOffset: 0,
            point1: point1,
            point2: point2,
            point3: point3
        )
    }()
}

extension ShutterShapeAttributes {
    /// don't conform to protocol, since have custom multiplier
    init(progress: CGFloat, from fromAttributes: ShutterShapeAttributes, to toAttributes: ShutterShapeAttributes, multiplier: CGFloat) {
        origin = AnimatableUtilities.mixedValue(from: fromAttributes.origin, to: toAttributes.origin, progress: progress) * multiplier
        cornerRadius = AnimatableUtilities.mixedValue(from: fromAttributes.cornerRadius, to: toAttributes.cornerRadius, progress: progress) * multiplier
        yOffset = AnimatableUtilities.mixedValue(from: fromAttributes.yOffset, to: toAttributes.yOffset, progress: progress) * multiplier
        width = AnimatableUtilities.mixedValue(from: fromAttributes.width, to: toAttributes.width, progress: progress) * multiplier
        leftOffset = AnimatableUtilities.mixedValue(from: fromAttributes.leftOffset, to: toAttributes.leftOffset, progress: progress) * multiplier
        point1 = AnimatableUtilities.mixedValue(from: fromAttributes.point1, to: toAttributes.point1, progress: progress) * multiplier
        point2 = AnimatableUtilities.mixedValue(from: fromAttributes.point2, to: toAttributes.point2, progress: progress) * multiplier
        point3 = AnimatableUtilities.mixedValue(from: fromAttributes.point3, to: toAttributes.point3, progress: progress) * multiplier
    }
}

struct CameraButtonStyle: ButtonStyle {
    var isShutter: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect((isShutter && configuration.isPressed) ? 0.9 : 1)
            .modifier(FadingButtonModifier(isPressed: !isShutter && configuration.isPressed))
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct TabBarViewTester: View {
    @ObservedObject var tabViewModel = TabViewModel()
    @ObservedObject var toolbarViewModel = ToolbarViewModel()
    @ObservedObject var cameraViewModel = CameraViewModel()

    var body: some View {
        TabBarView(
            tabViewModel: tabViewModel,
            toolbarViewModel: toolbarViewModel,
            cameraViewModel: cameraViewModel
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.edgesIgnoringSafeArea(.all))
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        TabBarViewTester()
    }
}
