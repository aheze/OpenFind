//
//  SettingsCredits.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

enum SettingsProfileTransformState: CaseIterable {
    case flippedVertically
    case flippedHorizontally
    case zoomed
    case spun
}

struct Person: Identifiable {
    let id = UUID()
    var name: String
    var picture: ProfilePicture
    var description: String
    var urlString: String

    enum ProfilePicture {
        case image(imageName: String)
        case symbol(iconName: String, backgroundColor: UIColor)
    }

    func getUrlSummary() -> String {
        var urlString = self.urlString
        urlString = urlString.replacingOccurrences(of: "https://", with: "", options: .anchored)
        urlString = urlString.replacingOccurrences(of: "http://", with: "", options: .anchored)

        let endSet = CharacterSet(charactersIn: "/")
        urlString = urlString.trimmingCharacters(in: endSet)
        return urlString
    }
}

extension Person {
    static var people: [Person] = {
        [
            .init(
                name: "H. Kamran",
                picture: .image(imageName: "HKamranProfile"),
                description: "Beta Tester",
                urlString: "https://hkamran.com/"
            ),
            .init(
                name: "W in K",
                picture: .image(imageName: "WinKProfile"),
                description: "Made the app promo music",
                urlString: "https://soundcloud.com/winksounds"
            ),
        ]
    }()
}

struct SettingsCredits: View {
    @ObservedObject var model: SettingsViewModel
    @ObservedObject var realmModel: RealmModel
    @State var transform: SettingsProfileTransformState?
    @State var toggled = false

    var body: some View {
        VStack {
            /// top profile
            VStack(spacing: 20) {
                Button {
                    withAnimation(
                        .spring(
                            response: 0.6,
                            dampingFraction: 0.6,
                            blendDuration: 1
                        )
                    ) {
                        if transform == nil {
                            transform = SettingsProfileTransformState.allCases.randomElement()
                        } else {
                            transform = nil
                        }
                    }
                } label: {
                    Image("Zheng")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(transform == .zoomed ? 2 : 1)
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .roundedCircleBorder(borderRadius: 6)
                        .rotation3DEffect(
                            .degrees(transform == .flippedHorizontally || transform == .flippedVertically ? 180 : 0),
                            axis: (x: transform == .flippedVertically ? 1 : 0, y: transform == .flippedHorizontally ? 1 : 0, z: 0)
                        )
                        .rotationEffect(.degrees(transform == .spun ? 90 : 0))
                }
                .buttonStyle(SettingsProfileButtonStyle())

                Text("Find by Andrew Zheng")
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)

                Text("Thanks for checking out Find, I really appreciate it :)")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding(.horizontal, 32)

            HStack(spacing: 16) {
                SettingsProfileLink(imageName: "TwitterIcon", inset: 3, urlString: "https://twitter.com/aheze0")
                SettingsProfileLink(imageName: "GitHubIcon", inset: 4.5, urlString: "https://github.com/aheze")
                SettingsProfileLink(imageName: "RedditIcon", inset: 2, urlString: "https://www.reddit.com/user/aheze")
                SettingsProfileLink(imageName: "DiscordIcon", inset: 2, urlString: "https://discord.com/invite/UJpHv8jmN5")
                SettingsProfileLink(imageName: "MailIcon", inset: 2, urlString: "mailto:aheze@getfind.app")
            }

            Divider()
                .padding(.vertical, 16)
                .padding(.horizontal, 32)

            VStack(spacing: SettingsConstants.sectionSpacing) {
                Text("Find was only made possible by these people — thank you!")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .padding(.horizontal, 32)

                ForEach(Person.people) { person in
                    Button {
                        if let url = URL(string: person.urlString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 20) {
                            VStack {
                                switch person.picture {
                                case .image(imageName: let imageName):
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case .symbol(iconName: let iconName, backgroundColor: let backgroundColor):
                                    backgroundColor.color
                                        .overlay(
                                            Image(systemName: iconName)
                                                .font(UIFont.preferredFont(forTextStyle: .title2).font)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            .frame(width: 80, height: 80)
                            .roundedCircleBorder(borderRadius: 3)

                            VStack(alignment: .leading) {
                                Text(person.name)
                                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                                    .foregroundColor(UIColor.label.color)

                                Text(person.description)
                                    .foregroundColor(UIColor.secondaryLabel.color)

                                Spacer()

                                Text(person.getUrlSummary())
                                    .font(.footnote)
                                    .foregroundColor(UIColor.secondaryLabel.color)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(SettingsConstants.rowVerticalInsetsFromText)
                        .padding(SettingsConstants.rowHorizontalInsets)
                        .overlay(
                            RoundedRectangle(cornerRadius: SettingsConstants.sectionCornerRadius)
                                .strokeBorder(
                                    UIColor.secondaryLabel.color,
                                    lineWidth: 0.25
                                )
                        )
                    }
                }

                Button {
                    withAnimation(.easeOut(duration: 0.75)) {
                        toggled = true
                    }
                } label: {
                    VStack {
                        if toggled {
                            Text("❤️")
                                .transition(.scale(scale: 2).combined(with: .opacity))
                        } else {
                            Text("Natalie, thank you for everything. We will always remember you ❤️")
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(UIColor.secondaryLabel.color)
                                .padding(.horizontal, 32)
                                .transition(
                                    .asymmetric(
                                        insertion: .identity,
                                        removal: .scale(scale: 0.5).combined(with: .opacity)
                                    )
                                )
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

extension View {
    func roundedCircleBorder(borderRadius: CGFloat) -> some View {
        self.clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                UIColor.systemBackground.color,
                                UIColor.systemBackground.toColor(.label, percentage: 0.1).color,
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: borderRadius
                    )
            )
            .shadow(
                color: UIColor.label.color.opacity(0.25),
                radius: borderRadius,
                x: 0,
                y: borderRadius / 2
            )
    }
}

struct SettingsProfileLink: View {
    var imageName: String
    var inset: CGFloat
    var urlString: String

    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        } label: {
            Color.clear
                .frame(width: 40, height: 40)
                .overlay(
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(UIColor.secondaryLabel.color)
                        .padding(inset)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(SettingsProfileButtonStyle())
    }
}

struct SettingsProfileButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(
                .spring(
                    response: 0.3,
                    dampingFraction: 0.4,
                    blendDuration: 1
                ),
                value: configuration.isPressed
            )
    }
}
