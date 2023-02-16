//
//  PurchaseView.swift
//  vnvce
//
//  Created by Kerem Cesme on 13.02.2023.
//

import SwiftUI

struct PurchaseView: View {
    @EnvironmentObject private var storeKit: StoreKitManager
    var body: some View {
        ZStack {
            Color.black
            VStack(spacing:20){
                Text("Transaction id")
                if let transactionID = storeKit.currentTransactionID {
                    Text(transactionID)
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 20){
                    ForEach(storeKit.products, id: \.id) { product in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            Task {
                                await storeKit.purchase(product)
                            }
                        } label: {
                            VStack {
                                Group {
                                    Text("\(product.displayName)")
                                        .font(.system(size: 16, weight: .regular, design: .default))
                                    Text("\(product.displayPrice)")
                                        .font(.system(size: 20, weight: .bold, design: .default))
                                }
                                .foregroundColor(.black)
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(.white))
                            
                        }

                    }
                }
            }
        }
        .colorScheme(.dark)
        .ignoresSafeArea()
    }
}
