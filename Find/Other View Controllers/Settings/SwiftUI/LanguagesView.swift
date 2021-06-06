//
//  LanguagesView.swift
//  Find
//
//  Created by Zheng on 6/6/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

enum Language: Int, CaseIterable, Codable {
    case english = 0
    case french = 1
    case italian = 2
    case german = 3
    case spanish = 4
    case portuguese = 5
    case chineseSim = 6
    case chineseTra = 7
    
    func getName() -> (String, String) {
        switch self {
        case .english:
            return ("English", "en-US")
        case .french:
            return ("French", "fr-FR")
        case .italian:
            return ("Italian", "it-IT")
        case .german:
            return ("German", "de-DE")
        case .spanish:
            return ("Spanish", "es-ES")
        case .portuguese:
            return ("Portuguese", "pt-BR")
        case .chineseSim:
            return ("Chinese (Simplified)", "zh-Hans")
        case .chineseTra:
            return ("Chinese (Traditional)", "zh-Hant")
        }
    }
}

struct OrderedLanguage: Codable {
    var language: Language
    var priority: Int?
}

struct LanguageRow: Identifiable {
    
    var id: String {
        if let headerType = headerType {
            return headerType.getName()
        } else if let orderedLanguage = orderedLanguage {
            return orderedLanguage.language.getName().1
        } else {
            return UUID().uuidString
        }
    }
    
    var headerType: HeaderType?
    var orderedLanguage: OrderedLanguage?
}

enum HeaderType {
    case selected
    case unselected
    
    func getName() -> String {
        switch self {
        case .selected:
            return "Active"
        case .unselected:
            return "More Languages"
        }
    }
}

struct LanguagesView: View {
    
    @State var languageRows = [LanguageRow]()
    var readLanguages: (() -> [OrderedLanguage])
    
    init(readLanguages: @escaping (() -> [OrderedLanguage])) {
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        self.readLanguages = readLanguages
    }
    
    var body: some View {
        ZStack {
            Color(.black).brightness(0.1)
            
            VStack(alignment: .leading) {
                Text("Languages for the text recognition engine, sorted by priority.")
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                List {
                    ForEach(languageRows) { languageRow in
                        if let headerType = languageRow.headerType {
                            if #available(iOS 14.0, *) {
                                Text(headerType.getName())
                                    .textCase(.uppercase)
                                    .font(.system(.caption))
                                    .foregroundColor(Color(#colorLiteral(red: 0.8396033654, green: 0.8396033654, blue: 0.8396033654, alpha: 1)))
                                    .offset(x: 0, y: 8)
                                    .listRowBackground(Color(.black).brightness(0.1))
                                    .moveDisabled(true)
                            } else {
                                Text(headerType.getName())
                                    .font(.system(.caption))
                                    .foregroundColor(Color(#colorLiteral(red: 0.8396033654, green: 0.8396033654, blue: 0.8396033654, alpha: 1)))
                                    .offset(x: 0, y: 8)
                                    .listRowBackground(Color(.black).brightness(0.1))
                                    .moveDisabled(true)
                            }
                        } else {
                            Text(languageRow.orderedLanguage?.language.getName().0 ?? "Language")
                                .listRowBackground(Color(.black))
                                .listRowInsets(EdgeInsets(top: 0, leading: -24, bottom: 0, trailing: 0))
                        }
                    }
                    .onMove(perform: move)
                }
                .listStyle(PlainListStyle())
                .environment(\.editMode, .constant(.active))
                .colorScheme(.dark)
                
            }
            .foregroundColor(.white)
        }
        .onAppear {
            populateRows(with: readLanguages())
        }
    }
    func move(from source: IndexSet, to destination: Int) {
        if destination == 0 { /// moved above "Selected Languages" header
            populateRows()
        } else if /// moving last of the selected languages
            let fromIndex = source.first,
            fromIndex == 1,
            languageRows.filter({ $0.orderedLanguage?.priority != nil }).count == 1
        {
            populateRows()
        } else {
            languageRows.move(fromOffsets: source, toOffset: destination)
        }
        
        var currentPriority: Int? = 0
        for index in languageRows.indices {
            if languageRows[index].headerType == .unselected {
                currentPriority = nil
                if languageRows[index].orderedLanguage != nil {
                    languageRows[index].orderedLanguage?.priority = currentPriority
                }
            } else {
                if languageRows[index].orderedLanguage != nil {
                    languageRows[index].orderedLanguage?.priority = currentPriority
                    
                    if currentPriority != nil {
                        currentPriority = currentPriority! + 1
                    }
                }
            }
        }
        
        /// get only the selected languages (priority is not nil)
        let languages: [OrderedLanguage] = languageRows.compactMap {
            if $0.orderedLanguage?.priority != nil {
                return $0.orderedLanguage
            }
            return nil
        }
        
        if let encoded = try? JSONEncoder().encode(languages) {
            UserDefaults.standard.set(encoded, forKey: "recognitionLanguages")
        }
    }
    
    func populateRows(with initialLanguages: [OrderedLanguage]? = nil) {
        
        let selectedLanguages: [OrderedLanguage]
        if let initialLanguages = initialLanguages { /// got data from userdefaults
            selectedLanguages = initialLanguages
        } else { /// refresh
            let unsortedSelectedLanguages = languageRows.filter {
                return $0.orderedLanguage?.priority != nil
            }
            selectedLanguages = unsortedSelectedLanguages
                .map { $0.orderedLanguage ?? OrderedLanguage(language: .english, priority: nil) }
                .sorted { ($0.priority ?? 0) < ($1.priority ?? 0) }
        }
        
        var unselectedLanguages = [OrderedLanguage]()
        for language in Language.allCases {
            if !selectedLanguages.contains(where: { $0.language.getName().0 == language.getName().0 }) {
                let orderedLanguage = OrderedLanguage(language: language, priority: nil)
                unselectedLanguages.append(orderedLanguage)
            }
        }
        
        let selectedHeader = LanguageRow(headerType: .selected, orderedLanguage: nil)
        let selectedRows = selectedLanguages.map { LanguageRow(headerType: nil, orderedLanguage: $0) }
        let unselectedHeader = LanguageRow(headerType: .unselected, orderedLanguage: nil)
        let unselectedRows = unselectedLanguages.map { LanguageRow(headerType: nil, orderedLanguage: $0) }
        
        var rows = [LanguageRow]()
        rows.append(selectedHeader)
        rows += selectedRows
        rows.append(unselectedHeader)
        rows += unselectedRows
        self.languageRows = rows
    }
}
