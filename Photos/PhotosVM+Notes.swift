//
//  PhotosVM+Notes.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/24/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

extension PhotosViewModel {
    func addNote(_ note: PhotosNote) {
        DispatchQueue.main.async {
            withAnimation {
                if !self.notes.contains(note) {
                    self.notes.append(note)
                }
            }
        }
    }

    func removeNote(_ note: PhotosNote) {
        DispatchQueue.main.async {
            withAnimation {
                self.notes = self.notes.filter { $0 != note }
            }
        }
    }
}
