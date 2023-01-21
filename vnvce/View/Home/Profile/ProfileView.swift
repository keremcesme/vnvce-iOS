
import SwiftUI
import ContactsUI

struct ProfileView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        VStack(spacing:0) {
            NavigationBar
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack {
                    Circle()
                        .foregroundColor(.secondary)
                        .frame(width: 120, height: 120)
                        .padding(5)
                        .background(Circle().fill(.white).opacity(0.2))
                    Spacer()
                }
                .padding(.top, 15)
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    private var NavigationBar: some View {
        HStack {
            Spacer()
            Button {
                
            } label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.white).opacity(0.9)
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .frame(height: 44)
                    .padding(.trailing, 17)
            }
        }
        .padding(.top, UIDevice.current.statusBarHeight())
        Divider()
    }
}
