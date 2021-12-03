//
//  FlashIconView.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI

struct FlashIconView: View {
    @Binding var isOn: Bool
    @Binding var isDisabled: Bool
    @State var scaleAnimationActive = false
    
    var body: some View {
        Button {
            withAnimation {
                isOn.toggle()
            }
            
            /// small scale animation
            withAnimation(.spring()) { scaleAnimationActive = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.toolbarIconDeactivateAnimationDelay) {
                withAnimation(.easeOut(duration: Constants.toolbarIconDeactivateAnimationSpeed)) { scaleAnimationActive = false }
            }
        } label: {
            Image(systemName: "bolt.fill")
                .frame(width: 40, height: 40)
                .foregroundColor(isOn ? Color(Constants.activeIconColor) : .white)
                .opacity(isOn && !isDisabled ? 1 : 0.5)
                .font(.system(size: 19))
                .mask(
                    Rectangle()
                        .fill(Color.white)
                        .overlay(
                            LineShape(progress: !isOn || isDisabled ? 1 : 0)
                                .stroke(Color.black, style: .init(lineWidth: 5, lineCap: .round))
                                .padding(14)
                        )
                        .compositingGroup()
                        .luminanceToAlpha()
                    //                            .background(isOn ? Color.clear : Color.black) /// maybe add this to ensure shape is not cut out when `isOn`
                )
                .overlay(
                    LineShape(progress: !isOn || isDisabled ? 1 : 0)
                        .stroke(Color.white, style: .init(lineWidth: 2, lineCap: .round))
                        .padding(14)
                        .opacity(!isOn || isDisabled ? 1 : 0)
                )
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .background(
                    Color.white.opacity(0.15)
                )
                .cornerRadius(20)
        }
        .disabled(isDisabled)
        
    }
}

struct LineShape: Shape {
    var progress = CGFloat(1)
    var animatableData: CGFloat {
        get { progress }
        set { self.progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX * progress, y: rect.maxY * progress))
        return path
    }
}

struct FlashIconViewTester: View {
    @State var isOn = false
    var body: some View {
        FlashIconView(isOn: $isOn, isDisabled: .constant(false))
    }
}

struct FlashIconView_Previews: PreviewProvider {
    @State var isOn = true
    static var previews: some View {
        FlashIconViewTester()
            .padding()
            .background(Color.blue)
            .scaleEffect(4)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
