//
//  SettingsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import Combine

private var cancellables = [String: AnyCancellable]()

extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}

class Settings: ObservableObject {
    @Published(key: "highlightColor") var highlightColor = "00AEEF"
    @Published(key: "showTextDetectIndicator") var showTextDetectIndicator = true
    @Published(key: "hapticFeedbackLevel") var hapticFeedbackLevel = 0
    @Published(key: "livePreviewEnabled") var livePreviewEnabled = true
    @Published(key: "swipeToNavigateEnabled") var swipeToNavigateEnabled = true
}

struct SettingsView: View {
    init() {
        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        //Use this if NavigationBarTitle is with displayMode = .inline
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.3)
        
//        UIScrollView.appearance().backgroundColor = UIColor.clear
        
    }
    
    @ObservedObject var settings = Settings()
    
//    @State private var highlightColor = UserDefaults.standard.string(forKey: "highlightColor")
//
//    @State private var showTextDetectIndicator = UserDefaults.standard.bool(forKey: "showTextDetectIndicator")
//    @State private var hapticFeedbackLevel = UserDefaults.standard.integer(forKey: "hapticFeedbackLevel")
//    @State private var livePreviewEnabled = UserDefaults.standard.bool(forKey: "livePreviewEnabled")
//
//    @State private var swipeToNavigateEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 2) {
                        SectionHeaderView(text: "General")
                        
                        GeneralView(selectedHighlightColor: $settings.highlightColor)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
//                        let _ = print("feedback level: \(settings.hapticFeedbackLevel)")
                        SectionHeaderView(text: "Camera")

                        CameraSettingsView(
                            textDetectionIsOn: $settings.showTextDetectIndicator,
                            hapticFeedbackLevel: $settings.hapticFeedbackLevel,
                            livePreviewEnabled: $settings.livePreviewEnabled
                        )
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Support and Feedback")
                        
                        SupportView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Other")
                        
                        OtherView(swipeToNavigateEnabled: $settings.swipeToNavigateEnabled)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    
                }
                .fixFlickering { scrollView in
                    scrollView
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
//                            Color.clear
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
