//
//  EditableTextView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class EditableTextViewModel: ObservableObject {
    /// start, end
    var getFrameForRange: ((Int, Int) -> CGRect?)?

    @Published var isEditing = false
    var endEditing: (() -> Void)?

    @Published var keyboardHeight: CGFloat?
//    var keyboardShown: ((CGFloat?) -> Void)?
}

struct EditableTextView: UIViewRepresentable {
    @ObservedObject var model: EditableTextViewModel
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        view.font = UIFont.preferredFont(forTextStyle: .body)

        context.coordinator.listenToKeyboard()

        model.getFrameForRange = { [weak view] start, end in
            if let frame = view?.getFrame(start: start, end: end) {
                return frame
            }
            return nil
        }
        model.endEditing = { [weak view] in
            view?.resignFirstResponder()
        }
        return view
    }

    func updateUIView(_ view: UITextView, context: Context) {
        view.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: EditableTextView
        var currentKeyboardHeight: CGFloat?

        init(_ parent: EditableTextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.model.isEditing = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.model.isEditing = false
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}

extension EditableTextView.Coordinator {
    func listenToKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            /// only modify and call the `sink` on `parent.model.keyboardHeight` if the height changed - prevent over-scrolling
            if currentKeyboardHeight.map({ $0 != keyboardHeight }) ?? true {
                parent.model.keyboardHeight = keyboardHeight
            }
            currentKeyboardHeight = keyboardHeight
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        parent.model.keyboardHeight = nil
        currentKeyboardHeight = nil
    }
}