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
    let attributes: CameraIconAttributes
    
    var body: some View {
        Button {
            tabViewModel.changeTabState(newTab: tabType, animation: .clickedTabIcon)
        } label: {
            Group {
                Circle()
                    .fill(attributes.foregroundColor.color)
                    .overlay(
                        Circle()
                            .stroke(attributes.rimColor.color, lineWidth: attributes.rimWidth)
                    )
                    .frame(width: attributes.length, height: attributes.length)
            }
            .frame(maxWidth: .infinity)
            .frame(height: attributes.backgroundHeight)
        }
        .buttonStyle(CameraButtonStyle(isShutter: tabViewModel.tabState == tabType))
    }
}

struct ShutterShape: Shape {
    
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { self.progress = newValue }
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
        path.addLine(to: CGPoint(x: checkMidX, y: rect.maxY - 1.2))
        path.addLine(to: CGPoint(x: checkEndX, y: rect.minY + 0.5))
        return path
    }
    func createRoundedTriangle(circumference: CGFloat) -> CGPath {
        let cornerRadius = circumference / 10
        
        let width = circumference / 2
        let xLeft = width / 30
        let yOffset = sqrt(3) * (width / 2)
        
        let point1 = CGPoint(x: (-width / 2) - xLeft, y: -yOffset)
        let point2 = CGPoint(x: width - xLeft, y: 0)
        let point3 = CGPoint(x: (-width / 2) - xLeft, y: yOffset)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: (-width / 2) - xLeft, y: 0))
        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
        path.closeSubpath()
        
        return path
    }
    
//    func createRoundedCircle(circumference: CGFloat, cornerRadius: CGFloat) -> CGPath {
//        let yOffset = sqrt(3) * (circumference / 2)
//        
//        let point1 = CGPoint(x: -circumference / 2, y: -yOffset)
//        let point2 = CGPoint(x: circumference, y: 0)
//        let point3 = CGPoint(x: -circumference / 2, y: yOffset)
//        
//        let path = CGMutablePath()
//        path.move(to: CGPoint(x: -circumference / 2, y: 0))
//        
//        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
//        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
//        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
//        path.closeSubpath()
//        
//        return path
//    }
//    func createPath(circumference: CGFloat) {
//        let triangleCornerRadius = circumference / 10
//        let triangleYOffset = sqrt(3) * (circumference / 2)
//        let triangleWidth = circumference / 2
//        let triangleLeftOffset = triangleWidth / 30
//        let trianglePoint1 = CGPoint(x: (-triangleWidth / 2) - triangleLeftOffset, y: -triangleYOffset)
//        let trianglePoint2 = CGPoint(x: triangleWidth - triangleLeftOffset, y: 0)
//        let trianglePoint3 = CGPoint(x: (-triangleWidth / 2) - triangleLeftOffset, y: triangleYOffset)
//        
//        let circleCornerRadius = circumference / 2
//        
//        
//        
//        let path = CGMutablePath()
//        path.move(to: CGPoint(x: (-width / 2) - xLeft, y: 0))
//        path.addArc(tangent1End: point1, tangent2End: point2, radius: cornerRadius)
//        path.addArc(tangent1End: point2, tangent2End: point3, radius: cornerRadius)
//        path.addArc(tangent1End: point3, tangent2End: point1, radius: cornerRadius)
//        path.closeSubpath()
//        
//    }
}

//struct ShutterShapeAttributes: AnimatableAttributes {
//
//    let cornerRadius = circumference / 10
//    let yOffset = sqrt(3) * (circumference / 2)
//    let width = circumference / 2
//    let leftOffset = triangleWidth / 30
//    let point1 = CGPoint(x: (-triangleWidth / 2) - triangleLeftOffset, y: -triangleYOffset)
//    let point2 = CGPoint(x: triangleWidth - triangleLeftOffset, y: 0)
//    let point3 = CGPoint(x: (-triangleWidth / 2) - triangleLeftOffset, y: triangleYOffset)
//
//    static let triangle: Self = {
//        return .init(
//            cornerRadius: Constants.tabBarLightBackgroundColor,
//            yOffset: ConstantVars.tabBarTotalHeight,
//            width: 0,
//            leftOffset: -40,
//            point1: 0,
//            point2: CGPoint(x: triangleWidth - triangleLeftOffset, y: 0)
//            point3: CGPoint(x: (-triangleWidth / 2) - triangleLeftOffset, y: triangleYOffset)
//        )
//    }()
//
//
//    init(progress: CGFloat, from fromAttributes: ShutterShapeAttributes, to toAttributes: ShutterShapeAttributes) {
//        <#code#>
//    }
//}

struct CameraButtonStyle: ButtonStyle {
    var isShutter: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect((isShutter && configuration.isPressed) ? 0.9 : 1)
            .modifier(FadingButtonModifier(isPressed: !isShutter && configuration.isPressed))
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
