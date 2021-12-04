//
//  PopoverContainerView.swift
//  Popover
//
//  Created by Zheng on 12/3/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import SwiftUI

struct PopoverContainerView: View {
    @ObservedObject var popoverModel: PopoverModel
    
    var body: some View {
        ZStack {
            Color.blue.opacity(0.25)
            
            Text("Hi")
            
            ForEach(popoverModel.popovers) { popover in
                switch popover {
                case .fieldSettings(let configuration):
                    FieldSettingsView(configuration: configuration)
                        .writeSize(to: configuration.size)
                }
            }
//            if let fieldSettings = Binding($popoverModel.fieldSettings) {
//                FieldSettingsView(configuration: fieldSettings)
//                    .writeSize(to: fieldSettings.size)
//            }
        }
        
    }
}
