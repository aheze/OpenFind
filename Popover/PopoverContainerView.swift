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
                
                let size = Binding<CGSize?> {
                    popover.context.size
                } set: { newValue in
                    
                    if let transaction = popover.context.transaction {
                        
                        /// when `popover.context.size` is nil, the popover was just presented
                        if popover.context.size == nil {
                            popover.context.setSize(newValue)
                            Popovers.refresh(with: transaction)
                        } else {
                            
                            /// otherwise, the popover is *replacing* a previous popover, so animate it
                            withTransaction(transaction) {
                                popover.context.setSize(newValue)
                                Popovers.refresh(with: transaction)
                            }
                        }
                        popover.context.transaction = nil
                    }
                }
                
                popover.background
                
                popover.view
                    .writeSize(to: size)
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
                                
                                popover.context.presentationFrame.origin = popover.context.frame.origin + CGPoint(x: draggingAmount.width, y: draggingAmount.height)
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
        
        let offset = CGSize(
            width: popover.context.frame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: popover.context.frame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        
        return offset
    }
}

