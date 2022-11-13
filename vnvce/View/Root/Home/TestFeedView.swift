//
//  TestFeedView.swift
//  vnvce
//
//  Created by Kerem Cesme on 11.11.2022.
//

import SwiftUI
import SwiftUIX
import Introspect

struct TestFeedView: View {
    
    @State var offset: CGFloat = 0
    @State var selection: Int = 0
    @State var location: CGPoint = .zero
    
    var body: some View {
        
        PageView(offset: $offset, selection: $selection) { proxy in
            View1
                .id(0)
                .overlay {
                    Button {
                        proxy.move(id: selection + 1)
                    } label: {
                        Text("MOVE")
                            .font(.title3.bold())
                    }

                }
            View2
                .id(1)
            View1
                .id(2)
            View2
                .id(3)
            View1
                .id(4)
                .overlay {
                    Button {
                        proxy.move(id: selection + 1)
                    } label: {
                        Text("MOVE")
                            .font(.title3.bold())
                    }

                }
            View2
                .id(5)
            View1
                .id(6)
            View2
                .id(7)
        }
    }
    
    @ViewBuilder
    private var View1: some View {
        NavigationView {
            ZStack {
                Color.red
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("VIEW 1")
        }
        .frame(UIScreen.main.bounds.size)
        
    }
    
    @ViewBuilder
    private var View2: some View {
        NavigationView {
            ZStack {
                Color.green
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("VIEW 2")
        }
        .frame(UIScreen.main.bounds.size)
    }
}

