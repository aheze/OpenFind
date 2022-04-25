//
//  CameraStatusView.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/7/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import Popovers
import SwiftUI

enum CameraStatusConstants {
    static var titleInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    static var descriptionInsets = EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    static var actionTitleInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

    static var spacing = CGFloat(8)
    static var verticalPadding = CGFloat(14)

    static var titleFont = UIFont.preferredCustomFont(forTextStyle: .headline, weight: .semibold)
    static var descriptionFont = UIFont.preferredFont(forTextStyle: .body)

    static var popoverBackgroundBlurStyle = UIBlurEffect.Style.systemUltraThinMaterialDark
    static var popoverBackgroundColor = UIColor(hex: 0x0070AF).withAlphaComponent(0.5)
    static var popoverButtonColor = UIColor.black.withAlphaComponent(0.5)
    static var popoverDividerColor = UIColor.white.withAlphaComponent(0.2)

    static var sourceViewIdentifier = "Camera Status Source View"
    static var landscapeSourceViewIdentifier = "Camera Status Landscape Source View"
    static var statusViewIdentifier = "Camera Status Popover"
}

struct CameraStatus {
    var title = ""
    var description: String?
    var secondaryDescription: String?
    var actionTitle: String?
    var action: (() -> Void)?
}

struct CameraStatusView: View {
    @ObservedObject var model: CameraViewModel
    @ObservedObject var searchViewModel: SearchViewModel

    var body: some View {
        let status = getStatus()

        VStack(spacing: CameraStatusConstants.spacing) {
            Text(status.title)
                .font(CameraStatusConstants.titleFont.font)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(CameraStatusConstants.titleInsets)

            if status.description != nil {
                Line(color: CameraStatusConstants.popoverDividerColor)
            }

            if let description = status.description {
                VStack {
                    Text(description)
                        + Text(status.secondaryDescription != nil ? " " : "") /// space
                        + Text(status.secondaryDescription ?? "")
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(CameraStatusConstants.descriptionFont.font)
                .padding(CameraStatusConstants.descriptionInsets)
            }

            if let actionTitle = status.actionTitle {
                Button {
                    status.action?()
                } label: {
                    Text(actionTitle)
                        .font(CameraStatusConstants.titleFont.font)
                        .frame(maxWidth: .infinity)
                        .padding(CameraStatusConstants.actionTitleInsets)
                        .background(CameraStatusConstants.popoverButtonColor.color)
                        .cornerRadius(10)
                }
                .padding(CameraStatusConstants.descriptionInsets)
            }
        }
        .padding(.vertical, CameraStatusConstants.verticalPadding)
        .foregroundColor(.white)
        .frame(maxWidth: 180)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            ZStack {
                Templates.VisualEffectView(CameraStatusConstants.popoverBackgroundBlurStyle)
                CameraStatusConstants.popoverBackgroundColor.color.opacity(0.25)
            }
        )
        .cornerRadius(16)
    }

    func getStatus() -> CameraStatus {
        var status = CameraStatus()

        if model.shutterOn {
            status.title = "\(model.displayedResultsCount) Results"

            if case .number(let count) = model.displayedResultsCount {
                if count == 1 {
                    status.title = "\(count) Result"
                } else {
                    status.title = "\(count) Results"
                }
            }

            if let pausedImage = model.pausedImage {
                if pausedImage.dateScanned != nil {
                    status.actionTitle = "Rescan"
                    status.action = { [weak model] in
                        model?.rescan?()
                    }
                } else {
                    status.description = "Scanning..."
                }
            }
        } else {
            if searchViewModel.isEmpty {
                status.title = "Start Finding!"
                status.description = "Enter text in the search bar."
                status.secondaryDescription = "When Find detects results, this popup will update with more information."
            } else if model.livePreviewScanning, case .number(let count) = model.displayedResultsCount {
                if count == 1 {
                    status.title = "\(count) Result"
                } else {
                    status.title = "\(count) Results"
                }

                status.description = "Find is currently in Live Preview mode."
                status.secondaryDescription = "Tap the shutter to pause and scan."
            } else {
                status.title = "No Text Detected"
                status.description = "Try moving closer."
                status.secondaryDescription = "To conserve processing power, Find is currently paused."
                status.actionTitle = "Resume"
                status.action = { [weak model] in
                    model?.resumeScanning?()
                }
            }
        }

        return status
    }
}
