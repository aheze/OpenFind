//
//  LanguagesView.swift
//  Find
//
//  Created by Zheng on 6/6/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI
import Introspect

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
    
    func versionNeeded() -> Int {
        switch self {
        case .english:
            return 13
        case .french:
            return 14
        case .italian:
            return 14
        case .german:
            return 14
        case .spanish:
            return 14
        case .portuguese:
            return 14
        case .chineseSim:
            return 14
        case .chineseTra:
            return 14
        }
    }
    
    func requiresAccurateMode() -> Bool {
        switch self {
        case .english:
            return false
        case .french:
            return false
        case .italian:
            return false
        case .german:
            return false
        case .spanish:
            return false
        case .portuguese:
            return false
        case .chineseSim:
            return true
        case .chineseTra:
            return true
        }
    }
}

func deviceVersion() -> Int {
    if #available(iOS 14, *) {
        return 14
    } else {
        return 13
    }
}

struct OrderedLanguage: Codable {
    init(language: Language, priority: Int? = nil) {
        self.language = language
        self.priority = priority
    }
    
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

    var body: some View {
        ZStack {
            Color(.black).brightness(0.1).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                SwiftUI.List {
                    Text("Languages for the text recognition engine, sorted by priority. For best results, select up to 2.")
                        .padding(.top, 10)
                        .listRowBackground(Color(.black).brightness(0.1))
                    
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
                            
                            if let language = languageRow.orderedLanguage?.language {
                                
                                let versionUpdateNeeded = language.versionNeeded() > deviceVersion()
                                let requiresAccurate = language.requiresAccurateMode()
                                
                                VStack(spacing: 8) {
                                    HStack {
                                        Text(language.getName().0)
                                            .opacity(versionUpdateNeeded ? 0.5 : 1)
                                        
                                        Spacer()
                                        
                                        if requiresAccurate {
                                            Button(action: {
                                                Settings.Bridge.presentTopOfTheList?()
                                            }) {
                                                Image(systemName: "exclamationmark")
                                                    .font(.system(.subheadline))
                                                    .frame(width: 24, height: 24)
                                                    .background(Color.green.brightness(-0.2).cornerRadius(12))
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .padding(.trailing, 10)
                                            
                                        }
                                        
                                        if versionUpdateNeeded {
                                            Button(action: {
                                                Settings.Bridge.presentRequiresSoftwareUpdate?("\(language.versionNeeded()))")
                                            }) {
                                                Text("iOS \(language.versionNeeded())+")
                                                    .font(.system(.subheadline))
                                                    .padding(EdgeInsets(top: 2, leading: 10, bottom: 2, trailing: 8))
                                                    .frame(height: 24)
                                                    .background(
                                                        Color.blue.cornerRadius(12)
                                                    )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                                .listRowBackground(Color(.black))
                                .moveDisabled(versionUpdateNeeded)
                                .listRowInsets(
                                    versionUpdateNeeded
                                        ? EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
                                        : EdgeInsets(top: 0, leading: -24, bottom: 0, trailing: 0)
                                )
                            }
                        }
                    }
                    .onMove(perform: move)
                }
                .listStyle(PlainListStyle())
                .introspectTableView { tableView in
                    tableView.separatorStyle = .none
                    tableView.backgroundColor = .clear
                }
                .environment(\.editMode, .constant(.active))
                .colorScheme(.dark)
                
            }
            .foregroundColor(.white)
    
        }
        .navigationBarTitle("Recognition Languages", displayMode: .inline)
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
