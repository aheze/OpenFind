//
//  GeneralSettings.swift
//  Find
//
//  Created by Andrew on 1/3/20.
//  Copyright © 2020 Andrew. All rights reserved.
//

import UIKit

extension SettingsViewController {
    
    @objc func watchTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let recog = sender {
            showPressAnimation(recognizer: recog)
        }
    }
    @objc func clearHistTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let recog = sender {
            showPressAnimation(recognizer: recog)
        }
    }
    @objc func resetTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let recog = sender {
            showPressAnimation(recognizer: recog)
        }
    }
    @objc func rateTapped(_ sender: UITapGestureRecognizer? = nil) {
        if let recog = sender {
            showPressAnimation(recognizer: recog)
        }
    }
    @objc func helpTapped(_ sender: UITapGestureRecognizer? = nil) {
      if let recog = sender {
          showPressAnimation(recognizer: recog)
      }
    }
    func showPressAnimation(recognizer: UITapGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizer.State.began){
            print("start")
        }

        if (recognizer.state == UIGestureRecognizer.State.ended){
            print("end")

        }

        if (recognizer.state == UIGestureRecognizer.State.cancelled){
            print("cancelled")

        }
    }
    
}
