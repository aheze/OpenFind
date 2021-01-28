//
//  ProgressBar.swift
//  SupportDocsSwiftUI
//
//  Created by Zheng on 10/17/20.
//

import SwiftUI

/**
 The progress bar used as the loading indicator.
 - Fades out at 0.0 and 1.0.
 
 # Customizable parts:
 - `foregroundColor` - color of the loading bar.
 - `foregroundColor` - color of the bar's background.
 
 Source: [https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/]( https://www.simpleswiftguide.com/how-to-build-linear-progress-bar-in-swiftui/).
*/
internal struct ProgressBar: View {
    
    /// From 0.0 to 1.0
    @Binding var value: Float
    
    /// Stores the background and foreground color.
    var progressBarOptions: SupportOptions.ProgressBar
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor((value == 0.0 || value == 1.0) ? Color.clear : Color(progressBarOptions.backgroundColor)) /// If progress is at 0 or 1, hide the progress bar background.
                
                Rectangle().frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor((value == 0.0 || value == 1.0) ? Color.clear : Color(progressBarOptions.foregroundColor)) /// If progress is at 0 or 1, hide the progress bar foreground.
                    .animation(.easeOut)
            }
        }
    }
}
