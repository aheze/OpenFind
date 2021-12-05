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
    @State var selectedPopover: Popover? = nil
    @GestureState var selectedPopoverOffset: CGSize = .zero
    
    var body: some View {

        ZStack(alignment: .topLeading) {
            Color.blue.opacity(0.25)
            
            ForEach(Array(zip(popoverModel.popovers.indices, popoverModel.popovers)), id: \.1.id) { (index, popover) in
                let binding = Binding {
                    popover.context
                } set: { newValue in
                    if popoverModel.popovers.indices.contains(index) {
                        popoverModel.popovers[index].context = newValue
                    }
                }
                
                popover.view
                    .offset(popoverOffset(for: popover))
                    .animation(.spring(), value: selectedPopover)
                    .writeSize(to: binding.size)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .updating($selectedPopoverOffset) { value, draggingAmount, transaction in
                                
                                if selectedPopover == nil {
                                    DispatchQueue.main.async {
                                        selectedPopover = popover
                                    }
                                }
                                
                                let xTranslation = value.translation.width
                                let yTranslation = value.translation.height
                                var calculatedTransition = CGSize.zero
                                if value.translation.width <= 0 {
                                    calculatedTransition.width = -pow(-xTranslation, PopoverConstants.rubberBandingPower)
                                } else {
                                    calculatedTransition.width = pow(xTranslation, PopoverConstants.rubberBandingPower)
                                }
                                if value.translation.height <= 0 {
                                    calculatedTransition.height = -pow(-yTranslation, PopoverConstants.rubberBandingPower)
                                } else {
                                    calculatedTransition.height = pow(yTranslation, PopoverConstants.rubberBandingPower)
                                }
                                draggingAmount = calculatedTransition
                            }
                            .onEnded { value in
                                self.selectedPopover = nil
                            }
                        , including: popoverModel.popoversDraggable ? .all : .subviews
                    )
            }
            
            
            //            ForEach(Array(zip(popoverModel.popovers.indices, popoverModel.popovers)), id: \.1.id) { (index, popover) in
            //                switch popover {
            //                case .fieldSettings(let configuration):
            //                    let binding = Binding {
            //                        configuration
            //                    } set: { newValue in
            //                        popoverModel.popovers[index] = .fieldSettings(newValue)
            //                        configuration.propertiesChanged?(newValue)
            //                    }
            //
            //                    FieldSettingsView(configuration: binding, stopDraggingGesture: $draggingActiveInsideSelectedPopover)
            //                        .offset(
            //                            x: popover.frame.origin.x + (selectedPopover == popover ? selectedPopoverOffset.width : 0),
            //                            y: popover.frame.origin.y + (selectedPopover == popover ? selectedPopoverOffset.height : 0)
            //                        )
            //                        .animation(.spring(), value: selectedPopover)
            //                        .writeSize(to: binding.popoverContext.size)
            //                        .simultaneousGesture(
            //                            DragGesture(minimumDistance: 0)
            //                                .updating($selectedPopoverOffset) { value, draggingAmount, transaction in
            //                                    if selectedPopover == nil {
            //                                        DispatchQueue.main.async {
            //                                            selectedPopover = popover
            //                                        }
            //                                    }
            //
            //                                    let xTranslation = value.translation.width
            //                                    let yTranslation = value.translation.height
            //                                    var calculatedTransition = CGSize.zero
            //                                    if value.translation.width <= 0 {
            //                                        calculatedTransition.width = -pow(-xTranslation, PopoverConstants.rubberBandingPower)
            //                                    } else {
            //                                        calculatedTransition.width = pow(xTranslation, PopoverConstants.rubberBandingPower)
            //                                    }
            //                                    if value.translation.height <= 0 {
            //                                        calculatedTransition.height = -pow(-yTranslation, PopoverConstants.rubberBandingPower)
            //                                    } else {
            //                                        calculatedTransition.height = pow(yTranslation, PopoverConstants.rubberBandingPower)
            //                                    }
            //                                    draggingAmount = calculatedTransition
            //                                }
            //                                .onEnded { value in
            //                                    self.selectedPopover = nil
            //                                }
            //                            , including: draggingActiveInsideSelectedPopover ? .subviews : .all)
            //                }
            //            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    func popoverOffset(for popover: Popover) -> CGSize {
        //        popover.frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0)
        let offset = CGSize(
            width: popover.frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: popover.frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        return offset
        
    }
}

