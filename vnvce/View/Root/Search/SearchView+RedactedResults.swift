//
//  SearchView+RedactedResults.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.11.2022.
//

import SwiftUI

extension SearchView {
    @ViewBuilder
    public var RedactedResults: some View {
        ForEach((1...15), id: \.self) { _ in
            HStack(spacing:10){
                RoundedRectangle(cornerRadius: 7.5)
                    .foregroundColor(Color.primary)
                    .frame(width: 50, height: 50, alignment: .center)
                VStack(alignment:.leading){
                    VStack(alignment: .leading){
                        Capsule()
                            .frame(width: 175, height:5 , alignment: .center)
                        Capsule()
                            .frame(width: 100, height: 5, alignment: .center)
                    }
                    .foregroundColor(Color.primary)
                }
                Spacer()
            }
            .opacity(0.1)
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        }
        .shimmering()
    }
}
