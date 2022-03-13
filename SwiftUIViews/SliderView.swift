//
//  SliderView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 3/12/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//
    

import SwiftUI

class SliderViewModel: ObservableObject {
    enum Selection {
        case starred
        case screenshots
        case all
        
        func getString() -> String {
            switch self {
            case .starred:
                return "Starred"
            case .screenshots:
                return "Screenshots"
            case .all:
                return "All"
            }
        }
    }
    
    @Published var selection = Selection.all
}
struct SliderView: View {
    @ObservedObject var model: SliderViewModel
    var body: some View {
        Text("Hi")
    }
}

struct SliderViewTester: View {
    @StateObject var model = SliderViewModel()
    var body: some View {
        SliderView(model: model)
    }
}

struct SliderViewTester_Previews: PreviewProvider {
    static var previews: some View {
        SliderViewTester()
    }
}
