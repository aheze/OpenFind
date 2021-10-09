//
//  SwipeToNavigateView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct SwipeToNavigateView: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Swipe to Navigate")
                    .accessibility(hint: Text("Allow swiping between tabs. Ignored when VoiceOver is active."))
                
                HStack(spacing: 0) {
                    if isOn {
                        Label(text: "ON")
                            .accessibility(hidden: true)
                    } else {
                        Label(text: "OFF")
                            .accessibility(hidden: true)
                    }
                    
                    Spacer()
                    
                    Toggle(isOn: $isOn, label: {
                        Text("Toggle")
                    }).labelsHidden()

                }
                .edgePadding(6)
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}
