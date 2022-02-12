//
//  FlashIconView.swift
//  TabBarControllerTesting
//
//  Created by Zheng on 11/10/21.
//

import SwiftUI

struct FlashIconView: View {
    @Binding var isOn: Bool
    @Binding var isEnabled: Bool
    @State var scaleAnimationActive = false
    
    var body: some View {
        Button {
            scale(scaleAnimationActive: $scaleAnimationActive)
            toggle()
        } label: {
            Image(systemName: "bolt.fill")
                .frame(width: 40, height: 40)
                .foregroundColor(isOn ? Color(Constants.activeIconColor) : .white)
                .font(.system(size: 19))
                .enabledModifier(isEnabled: isEnabled, linePadding: 13)
                .scaleEffect(scaleAnimationActive ? 1.2 : 1)
                .cameraToolbarIconBackground()
        }
        .disabled(!isEnabled)
    }
    
    func toggle() {
        withAnimation {
            isOn.toggle()
        }
    }
}


struct FlashIconViewTester: View {
    @State var isOn = false
    var body: some View {
        FlashIconView(isOn: $isOn, isEnabled: .constant(true))
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
