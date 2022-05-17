//
//  SettingsCredits.swift
//  Find
//
//  Created by A. Zheng (github.com/aheze) on 4/6/22.
//  Copyright © 2022 A. Zheng. All rights reserved.
//

import SwiftUI

struct Person: Identifiable {
    let id = UUID()
    var name: String
    var picture: ProfilePicture
    var description: String
    var urlString: String?
    var showUrl = true

    enum ProfilePicture {
        case image(imageName: String)
        case symbol(iconName: String, foregroundColor: UIColor, backgroundColor: UIColor)
    }

    func getUrlSummary() -> String {
        guard var urlString = urlString else { return "" }
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
            .init(
                name: "Eleni",
                picture: .symbol(iconName: "person.fill", foregroundColor: .white, backgroundColor: .systemPink),
                description: "Made the strawberry image - try typing /strawberry in a search bar"
            ),
            .init(
                name: "Leo",
                picture: .symbol(iconName: "person.fill", foregroundColor: .white, backgroundColor: .systemGreen),
                description: "Made the gradient image - try typing /gradient in a search bar"
            ),
            .init(
                name: "Want to help?",
                picture: .symbol(iconName: "plus", foregroundColor: UIColor.secondaryLabel, backgroundColor: UIColor.secondarySystemBackground),
                description: "Find is a completely free app — got something you want to add? It could be a translation or a feature or anything, just DM me on Twitter!",
                urlString: "https://twitter.com/aheze0",
                showUrl: false
            )
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
                    PortraitView(length: 180, circular: true, transform: $transform)
                }
                .buttonStyle(SettingsProfileButtonStyle())

                Text("Find by Andrew Zheng")
                    .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)

                Text("Thanks for checking out Find, I really appreciate it :) I'm the person who coded this app. If you have any questions, comments, or whatever just message me using one of the links below!")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(UIColor.secondaryLabel.color)
            }
            .padding(.horizontal, 28)

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
                Text("Thanks to")
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .foregroundColor(UIColor.secondaryLabel.color)
                    .padding(.horizontal, 28)

                ForEach(Person.people) { person in
                    PersonView(person: person)
                }

                Button {
                    withAnimation(.easeOut(duration: 0.75)) {
                        toggled = true
                    }
                } label: {
                    VStack {
                        if toggled {
                            Text("❤️")
                                .font(UIFont.preferredFont(forTextStyle: .title1).font)
                                .transition(.scale(scale: 2).combined(with: .opacity))
                        } else {
                            Text("Natalie, thank you for everything. We will always remember you ❤️")
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .foregroundColor(UIColor.secondaryLabel.color)
                                .padding(.horizontal, 28)
                                .transition(
                                    .asymmetric(
                                        insertion: .identity,
                                        removal: .scale(scale: 0.5).combined(with: .opacity)
                                    )
                                )
                        }
                    }
                }
            }
        }
    }
}


struct PersonView: View {
    let person: Person
    var body: some View {
        Button {
            if let urlString = person.urlString, let url = URL(string: urlString) {
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
                    case .symbol(iconName: let iconName, foregroundColor: let foregroundColor, backgroundColor: let backgroundColor):
                        backgroundColor.color
                            .overlay(
                                Image(systemName: iconName)
                                    .font(UIFont.preferredFont(forTextStyle: .largeTitle).font)
                                    .foregroundColor(foregroundColor.color)
                            )
                    }
                }
                .frame(width: 80, height: 80)
                .roundedCircleBorderSmall()

                VStack(alignment: .leading, spacing: 8) {
                    Text(person.name)
                        .font(UIFont.preferredCustomFont(forTextStyle: .title3, weight: .medium).font)
                        .foregroundColor(UIColor.label.color)

                    Text(person.description)
                        .foregroundColor(UIColor.secondaryLabel.color)
                        .multilineTextAlignment(.leading)

                    if person.showUrl {
                        Spacer()
                        Text(person.getUrlSummary())
                            .font(.footnote)
                            .foregroundColor(UIColor.secondaryLabel.color)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
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
            .contentShape(Rectangle())
        }
        .buttonStyle(EasingScaleButtonStyle())
    }
}

extension View {
    func roundedCircleBorderSmall() -> some View {
        self.clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                UIColor.systemBackground.toColor(.label, percentage: 0.1).color,
                                UIColor.systemBackground.toColor(.label, percentage: 0.25).color
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        ),
                        lineWidth: 3
                    )
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

struct EasingScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(
                .spring(
                    response: 0.2,
                    dampingFraction: 0.55,
                    blendDuration: 1
                ),
                value: configuration.isPressed
            )
    }
}
