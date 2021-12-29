//
//  Utilities.swift
//
//
//  Created by Zheng on 10/7/21.
//

import SupportDocs
import SwiftUI

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String {
    func getDescription() -> (String, Double) {
        var colorName = ""
        var pitch = 0.0
        
        switch self {
        case "#eb2f06":
            colorName = "red"
            pitch = 0.08
        case "#e55039":
            colorName = "mahogany"
            pitch = 0.16
        case "#f7b731":
            colorName = "dark yellow"
            pitch = 0.24
        case "#fed330":
            colorName = "yellow"
            pitch = 0.32
        case "#78e08f":
            colorName = "light green"
            pitch = 0.4
        case "#fc5c65":
            colorName = "strawberry"
            pitch = 0.48
        case "#fa8231":
            colorName = "orange"
            pitch = 0.56
        case "#b8e994":
            colorName = "mint green"
            pitch = 0.64
        case "#2bcbba":
            colorName = "teal"
            pitch = 0.72
        case "#ff6348":
            colorName = "red-orange"
            pitch = 0.8
        case "#b71540":
            colorName = "dark red"
            pitch = 0.88
        case "#00aeef":
            colorName = "Find blue"
            pitch = 0.96
        case "#579f2b":
            colorName = "dark green"
            pitch = 1.04
        case "#778ca3":
            colorName = "dark gray"
            pitch = 1.12
        case "#e84393":
            colorName = "magenta"
            pitch = 1.2
        case "#a55eea":
            colorName = "purple"
            pitch = 1.28
        case "#5352ed":
            colorName = "indigo"
            pitch = 1.36
        case "#70a1ff":
            colorName = "cornflower blue"
            pitch = 1.44
        case "#40739e":
            colorName = "navy blue"
            pitch = 1.52
        case "#45aaf2":
            colorName = "light blue"
            pitch = 1.6
        case "#2d98da":
            colorName = "dark blue"
            pitch = 1.68
        case "#d1d8e0":
            colorName = "light gray"
            pitch = 1.76
        case "#4b6584":
            colorName = "blue-gray"
            pitch = 1.84
        case "#0a3d62":
            colorName = "midnight blue"
            pitch = 1.92
        default:
            colorName = "Color"
        }
        
        return (colorName, pitch)
    }
}

struct AccessibilityText {
    var text = ""
    var isRaised = false
    var customPitch: Double? = nil
    var customPronunciation: String? = nil
}

extension UIAccessibility {
    static func postAnnouncement(_ texts: [AccessibilityText], delay: Double = 0.5) {
        let string = makeAttributedText(texts)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: string)
        }
    }
    
    static func makeAttributedText(_ texts: [AccessibilityText]) -> NSMutableAttributedString {
        let pitch = [NSAttributedString.Key.accessibilitySpeechPitch: 1.2]
        let string = NSMutableAttributedString()
        
        for text in texts {
            if let customPitch = text.customPitch {
                let pitch = [NSAttributedString.Key.accessibilitySpeechPitch: customPitch]
                let customRaisedString = NSMutableAttributedString(string: text.text, attributes: pitch)
                string.append(customRaisedString)
            } else if let customPronunciation = text.customPronunciation {
                print("custom!!")
                let pronunciation = [NSAttributedString.Key.accessibilitySpeechIPANotation: NSString(string: customPronunciation)]
                let customPronunciationString = NSMutableAttributedString(string: text.text, attributes: pronunciation)
                string.append(customPronunciationString)
            } else if text.isRaised {
                let raisedString = NSMutableAttributedString(string: text.text, attributes: pitch)
                string.append(raisedString)
            } else {
                let normalString = NSAttributedString(string: text.text)
                string.append(normalString)
            }
        }
        
        return string
    }
}

/**
 ViewModifier that applies SupportOptions' `NavigationBar` and `SearchBar` configurations.
 */
struct BarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay( /// Workaround to apply the `ViewControllerResolver`
                ViewControllerResolver { viewController in
                
                    /**
                     Now set the Navigation Bar's configuration
                     */
                    let navBarAppearance = UINavigationBarAppearance()
                    navBarAppearance.configureWithDefaultBackground()
                    navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                
                    navBarAppearance.backgroundColor = UIColor.black.withAlphaComponent(0.9)
                    viewController.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                
                    viewController.navigationController?.navigationBar.standardAppearance = navBarAppearance
                
                    viewController.navigationController?.navigationBar.barTintColor = UIColor.black.withAlphaComponent(0.9)
                    viewController.navigationController?.navigationBar.tintColor = UIColor.white
                }
                .frame(width: 0, height: 0)
            )
    }
}

/**
 For easier usage of the bar modifier.
 */
extension View {
    func configureBar() -> some View {
        return modifier(BarModifier())
    }
}

/**
 Access the parent view controller of the SwiftUI View.
 */
internal final class ViewControllerResolver: UIViewControllerRepresentable {
    /// Closure to call when `didMove`
    let onResolve: (UIViewController) -> Void
        
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
    }
    
    func makeUIViewController(context: Context) -> ParentResolverViewController {
        ParentResolverViewController(onResolve: onResolve)
    }
    
    func updateUIViewController(_ uiViewController: ParentResolverViewController, context: Context) {}
}

internal class ParentResolverViewController: UIViewController {
    let onResolve: (UIViewController) -> Void
    
    init(onResolve: @escaping (UIViewController) -> Void) {
        self.onResolve = onResolve
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Use init(onResolve:) to instantiate ParentResolverViewController.")
    }
        
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        if let parent = parent {
            onResolve(parent)
        }
    }
}
