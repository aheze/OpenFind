//
//  CameraMessageView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 2/21/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

enum CameraMessagesConstants {
    static var padding = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    static var backgroundStyle = UIBlurEffect.Style.systemUltraThinMaterialDark
    static var backgroundColor = UIColor(hex: 0x0070AF).withAlphaComponent(0.5)
}

struct Message: Identifiable, Equatable {
    var id: Identifier
    var string: String
    var tapped: (() -> Void)? /// set to nil to disable the message button

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }

    enum Identifier {
        case noTextDetected
    }
}

class CameraMessagesViewModel: ObservableObject {
    internal var messages = [Message]()

    func addMessage(_ message: Message) {
        withAnimation {
            if !messages.contains(message) {
                messages.append(message)
            }
        }
    }

    func removeMessage(id: Message.Identifier) {
        withAnimation {
            if let firstIndex = messages.firstIndex(where: { $0.id == id }) {
                messages.remove(at: firstIndex)
            }
        }
    }
}

struct CameraMessagesView: View {
    @ObservedObject var model: CameraMessagesViewModel

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(model.messages) { message in
                Button {
                    message.tapped?()
                } label: {
                    Text(message.string)
                }
                .buttonStyle(CameraMessageButtonStyle())
                .allowsHitTesting(message.tapped != nil)
            }
        }
    }
}

struct CameraMessagesBackground: View {
    @State var appeared = false
    var body: some View {
        PopoverReader { context in
            let popoverTopLeftPoint = context.frame.point(at: .topLeft)
            let popoverBottomLeftPoint = context.frame.point(at: .bottomLeft)
            let resultsRect = context.window.frameTagged("ResultsIconView")
            let leftDifference = resultsRect.midX - context.staticFrame.minX
            
            let start = CGPoint(
                x: popoverTopLeftPoint.x + leftDifference,
                y: popoverTopLeftPoint.y + CameraMessagesConstants.padding.top
            )

            let middle = CGPoint(
                x: popoverBottomLeftPoint.x + leftDifference,
                y: popoverBottomLeftPoint.y
            )
            
            let end = context.window.frameTagged("ResultsIconView").point(at: .top)

            ExtendedCurveConnector(
                start: start,
                middle: middle,
                end: end
            )
            .trim(from: appeared ? 0 : 1, to: 1)
            .stroke(
                Color.white,
                style: .init(
                    lineWidth: 2,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut) {
                    appeared = true
                }
            }
        }
    }
}

struct CameraMessageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(CameraMessagesConstants.padding)
            .background(
                ZStack {
                    Templates.VisualEffectView(CameraMessagesConstants.backgroundStyle)
                    CameraMessagesConstants.backgroundColor.color.opacity(0.25)
                }
            )
            .mask(Capsule())
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

@available(iOS 14.0, *)
struct CameraMessagesViewTester: View {
    @StateObject var model: CameraMessagesViewModel = {
        let model = CameraMessagesViewModel()

        model.messages = [
            Message(id: .noTextDetected, string: "No Results", tapped: {}),
            Message(id: .noTextDetected, string: "Move Closer"),
            Message(id: .noTextDetected, string: "Slow Down", tapped: {})
        ]
        return model
    }()

    var body: some View {
        CameraMessagesView(model: model)
            .padding()
            .background(Color.blue)
    }
}

@available(iOS 14.0, *)
struct CameraMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        CameraMessagesViewTester()
    }
}
