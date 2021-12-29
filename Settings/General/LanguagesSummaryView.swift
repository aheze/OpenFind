//
//  LanguagesView.swift
//  Find
//
//  Created by Zheng on 9/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

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
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                    }
                    .edgePadding()
                    .bottomRowPadding()
                }
                .accessibility(hint: Text("Navigate to language selection screen."))
            }
        }
        .background(Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)))
        .cornerRadius(12)
        .onAppear {
            _ = readDefaults()
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
        } catch {}
        return [OrderedLanguage]()
    }
}
