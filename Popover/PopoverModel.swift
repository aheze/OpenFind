//
//  PopoverModel.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Combine
import SwiftUI

class PopoverModel: ObservableObject {
//    @Published var fieldSettings: Popover.FieldSettings?
    @Published var popovers = [Popover]()
}

enum Popover: Identifiable {
    var id: UUID {
        switch self {
        case .fieldSettings(let configuration):
            return configuration.id
        }
    }
    
    case fieldSettings(Binding<Configuration.FieldSettings>)
    
    struct Configuration {
        struct FieldSettings: PopoverContext {
            let id = UUID()
            
            var origin: CGPoint = .zero
            var size: CGSize = .zero
            var keepPresentedRects: [CGRect] = []
            
            var defaultColor: UInt = 0
            var selectedColor: UInt = 0
            var alpha: CGFloat = 1
        }
    }
}
protocol PopoverContext: Identifiable {
    
    /// position of the popover
    var origin: CGPoint { get set }
    
    /// calculated from SwiftUI
    var size: CGSize { get set }
    
    /// if click in once of these rects, don't dismiss the popover. Otherwise, dismiss.
    var keepPresentedRects: [CGRect] { get set }
}
