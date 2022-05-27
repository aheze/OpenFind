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

    var keyboardShown: ((CGFloat?) -> Void)?
}

struct EditableTextView: UIViewRepresentable {
    @ObservedObject var model: EditableTextViewModel
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        view.font = UIFont.preferredFont(forTextStyle: .body)

        listenToKeyboard()

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
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height

            parent.model.keyboardShown?(keyboardHeight)
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        parent.model.keyboardShown?(nil)
    }
}
