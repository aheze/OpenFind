//
//  FixFlickering.swift
//  FindAppClip1
//
//  Created by Zheng on 3/13/21.
//

import SwiftUI

public extension ScrollView {
    func fixFlickering() -> some View {
        return fixFlickering { scrollView in
            scrollView
        }
    }
    
    func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        GeometryReader { geometryWithSafeArea in
            GeometryReader { _ in
                configurator(
                    ScrollView<AnyView>(self.axes, showsIndicators: self.showsIndicators) {
                        AnyView(
                            VStack {
                                self.content
                            }
                            .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                            .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                            .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                            .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                        )
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
