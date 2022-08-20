//
//  HomeView.swift
//  vnvce
//
//  Created by Kerem Cesme on 20.08.2022.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        Text("Hello, World!")
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { allowed, error in
                    if allowed {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        print(error?.localizedDescription)
                    }
                }
            }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
