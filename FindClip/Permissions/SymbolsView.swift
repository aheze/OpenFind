//
//  SymbolsView.swift
//  FindAppClip1
//
//  Created by Zheng on 3/15/21.
//

import SwiftUI

struct SymbolsView: View {
    @State var symbols = [SymbolList]()
    
    var body: some View {
        HStack {
            ForEach(symbols) { symbolList in
                LazyVStack {
                    ForEach(symbolList.symbols) { symbol in
                        Image(systemName: symbol.string)
                            .foregroundColor(Color.white.opacity(0.2))
                            .font(.system(size: 21, weight: .medium))
                            .frame(width: 20, height: 40)
                    }
                }
            }
        }
        .onAppear {
            populate()
        }
    }
}

struct SymbolsView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolsView()
            .previewLayout(.fixed(width: 400, height: 1900))
    }
}


