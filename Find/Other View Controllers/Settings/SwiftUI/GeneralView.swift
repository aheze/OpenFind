//
//  GeneralView.swift
//  NewSettings
//
//  Created by Zheng on 1/2/21.
//

import SwiftUI

struct GeneralView: View {
    @Binding var selectedHighlightColor: String
    var body: some View {
        DefaultColorView(selectedColor: $selectedHighlightColor)
        LanguagesSummaryView()
    }
}

struct DefaultColorView: View {
    @Binding var selectedColor: String
    
    let colorArray: [String] = [
        "#eb2f06", "#e55039", "#f7b731", "#fed330", "#78e08f",
        "#fc5c65", "#fa8231", "#b8e994", "#2bcbba",
        "#ff6348", "#b71540", "#00aeef", "#579f2b", "#778ca3",
        "#e84393", "#a55eea", "#5352ed", "#70a1ff", "#40739e",
        "#45aaf2", "#2d98da", "#d1d8e0", "#4b6584", "#0a3d62"
    ]
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
            VStack(spacing: 0) {
                HeaderView(text: "Default Highlight Color")
                if UIAccessibility.isVoiceOverRunning {
                    VStack(spacing: 0) {
                        ForEach(0..<3) { row in // create number of rows
                            HStack(spacing: 0) {
                                ForEach(0..<8) { column in // create 3 columns
                                    RectangleViewButton(selectedColor: $selectedColor, color: colorArray[row * 8 + column])
                                }
                            }
                        }
                    }
                } else {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            RectangleButton(selectedColor: $selectedColor, color: .customRed)
                            RectangleButton(selectedColor: $selectedColor, color: .customOrange)
                            RectangleButton(selectedColor: $selectedColor, color: .customYellow)
                            RectangleButton(selectedColor: $selectedColor, color: .customGreen)
                            RectangleButton(selectedColor: $selectedColor, color: .customBlue)
                            RectangleButton(selectedColor: $selectedColor, color: .customDarkBlue)
                            RectangleButton(selectedColor: $selectedColor, color: .customPurple)
                            RectangleButton(selectedColor: $selectedColor, color: .customMagenta)
                        }
                        HStack(spacing: 0) {
                            RectangleButton(selectedColor: $selectedColor, color: .customSalmon)
                            RectangleButton(selectedColor: $selectedColor, color: .customYellorange)
                            RectangleButton(selectedColor: $selectedColor, color: .customLime)
                            RectangleButton(selectedColor: $selectedColor, color: .customNeon)
                            RectangleButton(selectedColor: $selectedColor, color: .customLightBlue)
                            RectangleButton(selectedColor: $selectedColor, color: .customMediumBlue)
                            RectangleButton(selectedColor: $selectedColor, color: .customLightPurple)
                            RectangleButton(selectedColor: $selectedColor, color: .customPink)
                        }
                    }
                }
            }
        }.cornerRadius(12)
    }
}

struct LanguagesSummaryView: View {
    
    @State var languagesPresented = false
    @State var languagesString = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView(text: "Recognition Languages")
                
                NavigationLink(
                    destination:
                        
                        /**
                         Push to the web view when tapped.
                         */
                        LanguagesView(readLanguages: readDefaults)
                ) {
                    HStack(spacing: 0) {
                        VerbatimLabel(text: languagesString)
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(Font.system(size: 18, weight: .medium))
                            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 6))
                        
                    }
                    .padding(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 6))
                }
                .accessibility(hint: Text("Navigate to language selection screen."))
                
            }
           
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        .onAppear {
            readDefaults()
        }
    }
    
    func readDefaults() -> [OrderedLanguage] {
        do {
            if let recognitionLanguagesData = UserDefaults.standard.data(forKey: "recognitionLanguages") {
                let recognitionLanguages = try JSONDecoder().decode([OrderedLanguage].self, from: recognitionLanguagesData)
                
                let sorted = recognitionLanguages.sorted { ($0.priority ?? 0) < ($1.priority ?? 0) }
                let strings = sorted.map { $0.language.getName().0 }
                languagesString = strings.joined(separator: ", ")
                
                return recognitionLanguages
            }
        } catch {
            print("Error decoding: \(error)")
        }
        return [OrderedLanguage]()
    }
}


struct RectangleButton: View {
    @Binding var selectedColor: String
    
    var color: String
    var body: some View {
        Button(action: {
            selectedColor = color
        }) {
            Rectangle()
                .foregroundColor(Color(UIColor(hexString: color)))
                .aspectRatio(1.0, contentMode: .fit)
                .overlay(
                    (selectedColor.lowercased() == color.lowercased()) ? AnyView(
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(Font.system(size: 19, weight: .medium))
                    ) : AnyView(EmptyView())
                )
        }
    }
}
struct RectangleViewButton: View {
    @Binding var selectedColor: String
    var color: String
    
    var body: some View {
        RectangleView(selectedColor: $selectedColor, color: color)
            .accessibility(hidden: false)
            .aspectRatio(1.0, contentMode: .fit)
            .overlay(
                (selectedColor.lowercased() == color.lowercased()) ? AnyView(
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(Font.system(size: 19, weight: .medium))
                        .accessibility(hidden: true)
                ) : AnyView(EmptyView())
            )
            .onTapGesture {
                selectedColor = color
            }
    }
}
struct RectangleView: UIViewRepresentable {
    @Binding var selectedColor: String
    var color = "#00aeef"
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIView {
        let uiView = UIView()
        uiView.backgroundColor = UIColor(hexString: color)
        
        let colorDescription = color.getDescription()
        
        let colorString = AccessibilityText(text: "\(colorDescription.0)\n", isRaised: false)
        let pitchTitle = AccessibilityText(text: "Pitch", isRaised: true)
        let pitchString = AccessibilityText(text: "\(colorDescription.1)", isRaised: false, customPitch: colorDescription.1)
        let accessibilityLabel = UIAccessibility.makeAttributedText([colorString, pitchTitle, pitchString])
        
        uiView.isAccessibilityElement = true
        uiView.accessibilityAttributedLabel = accessibilityLabel
        uiView.accessibilityTraits = .none
        return uiView
        
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Self>) {
        if selectedColor == color {
            uiView.accessibilityTraits = .selected
        } else {
            uiView.accessibilityTraits = .none
        }
    }
}
