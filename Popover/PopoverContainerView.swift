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
        ZStack(alignment: .topLeading) {
            Color.blue.opacity(0.25)
            
            ForEach(Array(zip(popoverModel.popovers.indices, popoverModel.popovers)), id: \.1.id) { (index, popover) in
                switch popover {
                case .fieldSettings(let configuration):
                    let binding = Binding {
                        configuration
                    } set: { newValue in
                        popoverModel.popovers[index] = .fieldSettings(newValue)
                        configuration.propertiesChanged?(newValue)
                    }
                    
                    FieldSettingsView(configuration: binding)
                        .offset(
                            x: configuration.popoverContext.origin.x,
                            y: configuration.popoverContext.origin.y
                        )
                        .writeSize(to: binding.popoverContext.size)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}
