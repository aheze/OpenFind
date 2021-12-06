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
                } set: { newValue in
                    if popoverModel.popovers.indices.contains(index) {
                        popoverModel.popovers[index].context = newValue
                    }
                }
                
                popover.view
                    .opacity(popover.frame != nil ? 1 : 0)
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
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    func popoverOffset(for popover: Popover) -> CGSize {
        guard let popoverFrame = popover.frame else { return .zero }
        print("frame is: \(popoverFrame)")
        
        let offset = CGSize(
            width: popoverFrame.origin.x + ((selectedPopover == popover) ? selectedPopoverOffset.width : 0),
            height: popoverFrame.origin.y + ((selectedPopover == popover) ? selectedPopoverOffset.height : 0)
        )
        return offset
    }
}

