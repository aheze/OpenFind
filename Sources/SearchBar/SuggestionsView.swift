//
//  SuggestionsView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 1/1/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class SuggestionsViewModel: ObservableObject {
    @Published var pinned = [Value]()
    @Published var history = [Value]()
    @Published var lists = [List]()
}

struct SuggestionsView: View {
    @ObservedObject var model: SuggestionsViewModel
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                
            }
        }
    }
}


//struct SuggestionsGroup: View {
//    var body: some View {
//        <#T##Content##AnyView#>
//    }
//}
//
//struct SuggestionsToken: View {
//    var value: Value
//    var body: some View {
//        switch value {
//        case .word(let word):
//            <#code#>
//        case .list(let list):
//            <#code#>
//        }
//    }
//}
