//
//  SettingsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import Combine
import WhatsNewKit

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
struct SettingsHoster {
    static var viewController: SettingsViewHoster?
}

class Settings: ObservableObject {
    @Published(key: "highlightColor") var highlightColor = "00AEEF"
    @Published(key: "showTextDetectIndicator") var showTextDetectIndicator = true
    @Published(key: "hapticFeedbackLevel") var hapticFeedbackLevel = 1
    @Published(key: "swipeToNavigateEnabled") var swipeToNavigateEnabled = true
}

class SettingsViewHoster: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var dismissed: (() -> Void)?
    
    override func loadView() {
        
        /**
         Instantiate the base `view`.
         */
        view = UIView()

        /**
         Create a `SupportDocsView`.
         */
        var settingsView = SettingsView()
        
        /**
         Set the dismiss button handler.
         */
        settingsView.donePressed = { [weak self] in
            self?.dismissed?()
            self?.dismiss(animated: true, completion: nil)
        }
        
        /**
         Host `supportDocsView` in a view controller.
         */
        let hostedSettings = UIHostingController(rootView: settingsView)
        
        /**
         Embed `hostedSupportDocs`.
         */
        self.addChild(hostedSettings)
        view.addSubview(hostedSettings.view)
        hostedSettings.view.frame = view.bounds
        hostedSettings.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedSettings.didMove(toParent: self)
        
        
        SettingsHoster.viewController = self
    }
}


struct SettingsView: View {

    
    @ObservedObject var settings = Settings()
    var donePressed: (() -> Void)?
    
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 2) {
                        SectionHeaderView(text: "General")
                        
                        GeneralView(selectedHighlightColor: $settings.highlightColor)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Camera")

                        CameraSettingsView(
                            textDetectionIsOn: $settings.showTextDetectIndicator,
                            hapticFeedbackLevel: $settings.hapticFeedbackLevel
                        )
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Support and Feedback")
                        
                        SupportView()
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        
                        SectionHeaderView(text: "Other")
                        
                        OtherView(swipeToNavigateEnabled: $settings.swipeToNavigateEnabled, allSettings: settings)
                            .padding(EdgeInsets(top: 6, leading: 16, bottom: 16, trailing: 16))
                        
                        HStack {
                            
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                                .foregroundColor(Color.white.opacity(0.75))
                                .font(Font.system(size: 15, weight: .medium))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8))
                            
                            
                                Button(action: {
                                    let (whatsNew, configuration) = WhatsNewConfig.getWhatsNew()
                                    if let whatsNewPresent = whatsNew {
                                        let whatsNewViewController = WhatsNewViewController(whatsNew: whatsNewPresent, configuration: configuration)
                                        SettingsHoster.viewController?.present(whatsNewViewController, animated: true)
                                    }
                                }) {
                                    Text("See what's new")
                                        .foregroundColor(Color.white.opacity(0.5))
                                        .font(Font.system(size: 15, weight: .medium))
                                }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                    }
                    
                }
                .fixFlickering { scrollView in
                    scrollView
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
                        )
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing:
                                    Button(action: {
                                        donePressed?()
                                    }) {
                                        Text("Done")
                                            .font(Font.system(size: 19, weight: .regular, design: .default))
                                    }
            )
            .navigationViewStyle(StackNavigationViewStyle())
            .configureBar()
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
