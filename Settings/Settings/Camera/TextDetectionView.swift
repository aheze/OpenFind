//
//  CameraSettings.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct TextDetectionView: View {
    @Binding var isOn: Bool
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Text Detection Indicator")
                    .accessibility(hint: Text("Flash a temporary blue-gray highlight on top of detected sentences"))
                
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
