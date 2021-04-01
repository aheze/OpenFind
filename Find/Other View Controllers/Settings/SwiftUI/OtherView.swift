//
//  OtherView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import Combine

struct OtherView: View {
    @Binding var swipeToNavigateEnabled: Bool
    @ObservedObject var allSettings: Settings
    var body: some View {
        VStack(spacing: 20) {
            SwipeToNavigateView(isOn: $swipeToNavigateEnabled)
            ResetSettingsView(allSettings: allSettings)
            CreditsView()
        }
    }
}

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
                .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
    }
}

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
                    .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 6))
                }
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

struct CreditsView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Credits")
                
                NavigationLink(destination:
                                PeopleView()
                                .navigationBarTitle(Text("People"), displayMode: .inline)
                ) {
                    HStack(spacing: 0) {
                        Label(text: "People")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Navigate to the credits page"))
                
                Rectangle()
                    .fill(Color(UIColor.white.withAlphaComponent(0.3)))
                    .frame(height: 1)
                
                Button(action: {
                    SettingsHoster.viewController?.presentLicenses()
                }) {
                    HStack(spacing: 0) {
                        Label(text: "Licenses")
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Present the open-source licenses that Find uses"))
            }
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        
    }
}
