//
//  SettingsView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI
import Combine
import WhatsNewKit

struct SettingsHoster {
    static var viewController: SettingsViewHoster?
}


class Settings: ObservableObject {
    @Published var highlightColor: String { didSet { UserDefaults.standard.set(highlightColor, forKey: "highlightColor") } }
    @Published var showTextDetectIndicator: Bool { didSet { UserDefaults.standard.set(showTextDetectIndicator, forKey: "showTextDetectIndicator") } }
    @Published var hapticFeedbackLevel: Int { didSet { UserDefaults.standard.set(hapticFeedbackLevel, forKey: "hapticFeedbackLevel") } }
    @Published var swipeToNavigateEnabled: Bool { didSet { UserDefaults.standard.set(swipeToNavigateEnabled, forKey: "swipeToNavigateEnabled") } }
    
    init() {
        self.highlightColor = UserDefaults.standard.string(forKey: "highlightColor") ?? "00AEEF"
        self.showTextDetectIndicator = UserDefaults.standard.bool(forKey: "showTextDetectIndicator")
        self.hapticFeedbackLevel = UserDefaults.standard.integer(forKey: "hapticFeedbackLevel")
        self.swipeToNavigateEnabled = UserDefaults.standard.bool(forKey: "swipeToNavigateEnabled")
    }
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

func localize() {
    NSLocalizedString("General", comment: "")
    NSLocalizedString("Default Highlight Color", comment: "")
    NSLocalizedString("Camera", comment: "")
    NSLocalizedString("Text Detection Indicator", comment: "")
    
    NSLocalizedString("ON", comment: "")
    NSLocalizedString("OFF", comment: "")
    
    NSLocalizedString("Haptic Feedback", comment: "")
    NSLocalizedString("None", comment: "")
    NSLocalizedString("Light", comment: "")
    NSLocalizedString("Heavy", comment: "")
    
    NSLocalizedString("Support & Feedback", comment: "")
    NSLocalizedString("Help", comment: "")
    NSLocalizedString("Help Center", comment: "")
    NSLocalizedString("Tutorials", comment: "")
    
    NSLocalizedString("Feedback", comment: "")
    NSLocalizedString("Rate the app", comment: "")
    NSLocalizedString("Report a bug", comment: "")
    NSLocalizedString("Questions & Suggestions", comment: "")
    
    NSLocalizedString("Other", comment: "")
    NSLocalizedString("Swipe to Navigate", comment: "")
    NSLocalizedString("Reset Settings", comment: "")
    NSLocalizedString("Reset", comment: "")
    
    NSLocalizedString("Credits", comment: "")
    NSLocalizedString("People", comment: "")
    NSLocalizedString("Licenses", comment: "")
    
    NSLocalizedString("See what's new", comment: "")
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
                        
                        SectionHeaderView(text: "Support & Feedback")
                        
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
            .configureBar()
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
