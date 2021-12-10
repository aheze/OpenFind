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
                let context = Binding {
                    popover.context
                } set: { newValue, transaction in
//                    transaction.animation = nil
//                    print(newValue.)
                    if popoverModel.popovers.indices.contains(index) {
//                        popoverModel.popovers[index].context = Popover.Context(position: <#T##Popover.Position#>)
//                            .size = newValue
//                        if let popoverSize = newValue.size {
//                            let popoverFrame = newValue.position.popoverFrame(popoverSize: popoverSize)
//        //                    withAnimation {
//                            print("New: \(popoverFrame)")
//                            popoverModel.popovers[index].context.frame = popoverFrame
//        //                    }
//                        }
                        popoverModel.popovers[index].context.size = newValue.size
//                        popoverModel.popovers[index].context = newValue
                    }
                }
                
                
                popover.background
                    .opacity(popover.context.isReady ? 1 : 0)
                
                popover.view
                    .opacity(popover.context.isReady ? 1 : 0)
                    .writeSize(to: context.size)
                    .offset(popoverOffset(for: popover))
                    .animation(.spring(), value: selectedPopover)
                    .transition(
                        .asymmetric(
                            insertion: popover.attributes.presentation.transition ?? .opacity,
                            removal: popover.attributes.dismissal.transition ?? .opacity
                        )
                    )
                    .simultaneousGesture(
                        
                        /// 1 is enough to allow scroll views to scroll, if one is contained in the popover
                        DragGesture(minimumDistance: 1)
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
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    func popoverOffset(for popover: Popover) -> CGSize {

        /// make sure the frame has been calculated first
        guard popover.context.isReady else { return .zero }
        
        let offset = CGSize(
            width: popover.context.frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: popover.context.frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        
        return offset
    }
}

