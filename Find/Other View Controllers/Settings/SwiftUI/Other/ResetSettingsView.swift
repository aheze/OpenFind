//
//  ResetSettingsView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct ResetSettingsView: View {
    @ObservedObject var allSettings: Settings
    @State var resetSettingsSheetPresented = false
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Reset Settings")
                
                Button(action: {
                    resetSettingsSheetPresented = true
                }) {
                    HStack {
                        Label(text: "Reset")
                        Spacer()
                    }
                }
                .edgePadding()
                .accessibility(hint: Text("Resets all settings to default"))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        .actionSheet(isPresented: $resetSettingsSheetPresented, content: {
            ActionSheet(title: Text("resetSettings"), message: Text("settingsResetToDefault"), buttons: [
                .default(Text("reset")) {
                    allSettings.highlightColor = "00AEEF"
                    allSettings.showTextDetectIndicator = true
                    allSettings.shutterStyle = 1
                    allSettings.hapticFeedbackLevel = 2
                    allSettings.swipeToNavigateEnabled = true
                },
                .cancel()
            ])
        })
    }
}
