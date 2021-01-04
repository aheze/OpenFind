//
//  SettingsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct SettingsView: View {
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
    }
    
    @State private var highlightColor = UserDefaults.standard.string(forKey: "highlightColor")
    @State private var showTextDetectIndicator = UserDefaults.standard.string(forKey: "showTextDetectIndicator")
    @State private var hapticFeedback = UserDefaults.standard.string(forKey: "hapticFeedback")
    
    
    
    
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 2) {
                        SectionHeaderView(text: "General")
                        
                        GeneralView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Camera")

                        CameraSettingsView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Support and Feedback")
                        
                        SupportView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Other")
                        
                        OtherView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    
                }
                .fixFlickering { scrollView in
                    scrollView
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
                        )
                }
            }
            
            .navigationBarTitle("Settings")
        }
    }
}

extension ScrollView {
    
    public func fixFlickering() -> some View {
        
        return self.fixFlickering { (scrollView) in
            
            return scrollView
        }
    }
    
    public func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        
        GeometryReader { geometryWithSafeArea in
            GeometryReader { geometry in
                configurator(
                ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
                    AnyView(
                    VStack {
                        self.content
                    }
                    .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                    .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                    .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                    .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                    )
                }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
