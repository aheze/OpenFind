//
//  EditableTextView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 5/27/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

class EditableTextViewModel: ObservableObject {
    var configuration: Configuration

    /// start, end
    var getFrameForRange: ((Int, Int) -> CGRect?)?

    @Published var isEditing = false
    var endEditing: (() -> Void)?

    @Published var keyboardHeight: CGFloat?

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    struct Configuration {
        var scrollable = false
        var editable = true

        static let infoSlides: Self = {
            var configuration = Configuration()
            configuration.scrollable = true
            return configuration
        }()

        static let cellResults: Self = {
            var configuration = Configuration()
            configuration.scrollable = false
            configuration.editable = false
            return configuration
        }()
    }
}

struct EditableTextView: UIViewRepresentable {
    @ObservedObject var model: EditableTextViewModel
    @Binding var text: String
    @State var view: UITextView?

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.backgroundColor = .clear
        view.delegate = context.coordinator
        view.font = UIFont.preferredFont(forTextStyle: .body)
        view.textContainerInset = .zero
        view.isScrollEnabled = model.configuration.scrollable
        view.isEditable = model.configuration.editable

        DispatchQueue.main.async {
            self.view = view
        }

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

        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
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

            guard parent.view?.isFirstResponder ?? false else { return }

            /// only modify and call the `sink` on `parent.model.keyboardHeight` if the height changed - prevent over-scrolling
            if currentKeyboardHeight.map({ $0 != keyboardHeight }) ?? true {
                parent.model.keyboardHeight = keyboardHeight
            }
            currentKeyboardHeight = keyboardHeight
        }
    }

    @objc func keyboardDidHide(_ notification: Notification) {
        guard parent.view?.isFirstResponder ?? false else { return }
        parent.model.keyboardHeight = nil
        currentKeyboardHeight = nil
    }
}
