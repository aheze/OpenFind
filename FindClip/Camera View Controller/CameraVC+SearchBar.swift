//
//  CameraVC+SearchBar.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import UIKit

extension CameraViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1) {
            self.textFieldBackgroundView.backgroundColor = UIColor(named: "DarkBlue")?.withAlphaComponent(0.5)
        }
        scrollView.isScrollEnabled = true
        searchPressed?(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.textFieldBackgroundView.backgroundColor = UIColor(named: "SearchBackground")
        }
        scrollView.isScrollEnabled = false
        searchPressed?(false)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        /// if paused, find
        if CurrentState.currentlyPaused {
            findWhenPaused()
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            findText = updatedString
        }
        
        /// if paused, find
        if CurrentState.currentlyPaused {
            findWhenPaused()
        }
        
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        findText = ""
        DispatchQueue.main.async {
            self.removeCurrentComponents()
        }
        
        return true
    }
}
