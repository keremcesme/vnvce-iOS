
import SwiftUI
import PureSwiftUI

extension HomeView {
    @ViewBuilder
    public func UserCell(_ inx: Int, _ user: UserTestModel) -> some View {
        Button {
            homeVM.tab = user.id.uuidString
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 7) {
                ZStack {
                    Group {
                        Image(user.picture)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(isSelected(user) ? 51 : 71)
                        BlurView(style: .dark)
                            .frame(isSelected(user) ? 51 : 72)
                        Image(user.picture)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(isSelected(user) ? 51 : 64)
//                        BlurView(style: .dark)
//                            .frame(isSelected(user) ? 52 : 0)
                        Circle()
                            .strokeBorder(.white, lineWidth: isSelected(user) ? 6 : 0)
                            .foregroundColor(Color.clear)
                            .frame(width: 72, height: 72, alignment: .center)
                    }
                    .clipShape(Circle())
                }
                .overlay(alignment: .topTrailing) {
                    if user.count >= 2 && homeVM.tab != user.id.uuidString {
                        BlurView(style: .dark)
                            .frame(width: 25, height: 25)
                            .overlay {
                                Text("\(user.count)")
                                    .foregroundColor(.white)
                                    .tracking(-0.25)
                                    .font(.system(size: 12, weight: .medium, design: .default))
                            }
                            .clipShape(Circle())
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                 
                if homeVM.tab != user.id.uuidString {
                    Text(user.name)
                        .foregroundColor(.white)
                        .tracking(-0.25)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .frame(maxWidth: 79.5)
                        .transition(.opacity)
//                        .opacity(homeVM.tab == user.id.uuidString ? 0.00001 : 1)
                }
               
                
            }
            .animation(.easeInOut(duration: 0.3), value: homeVM.tab)
        }
        .buttonStyle(ScaledButtonStyle())
        .id(user.id.uuidString)
    }
    
    private func isSelected(_ user: UserTestModel) -> Bool {
        return homeVM.tab == user.id.uuidString
    }
}
