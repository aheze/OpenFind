//
//  SettingsWidgets.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct GeneralView: View {
    @Binding var selectedHighlightColor: String
    var body: some View {
        VStack {
            DefaultColorView(selectedColor: $selectedHighlightColor)
            LanguagesSummaryView()
        }
    }
}

struct CameraSettingsView: View {
    @Binding var textDetectionIsOn: Bool
    @Binding var hapticFeedbackLevel: Int
    @Binding var shutterStyle: Int
    
    var body: some View {
        VStack {
            TextDetectionView(isOn: $textDetectionIsOn)
            HapticFeedbackView(level: $hapticFeedbackLevel)
            ShutterStyleView(style: $shutterStyle)
        }
    }
}

struct SupportView: View {
    var body: some View {
        VStack {
            ExternalLinks()
            HelpView()
            FeedbackView()
        }
    }
}

struct OtherView: View {
    @Binding var swipeToNavigateEnabled: Bool
    @Binding var isShowingQR: Bool
    @ObservedObject var allSettings: Settings
    
    var body: some View {
        VStack {
            SwipeToNavigateView(isOn: $swipeToNavigateEnabled)
            ResetSettingsView(allSettings: allSettings)
            CreditsView()
            ShareView(isShowingQR: $isShowingQR)
        }
    }
}
