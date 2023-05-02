
import SwiftUI

extension MomentOutputView {
    
    @ViewBuilder
    public func AudienceButton(height: CGFloat) -> some View {
        VStack(spacing:20) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shareMomentVM.showAudienceSheet = !shareMomentVM.showAudienceSheet
            } label: {
                HStack(spacing: 3){
                    Group {
                        if shareMomentVM.showAudienceSheet {
                            Text("Audience")
                                .opacity(0.65)
                        } else {
                            Text(shareMomentVM.selectedAudience.title)
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .transition(.scale(scale: 0).combined(with: .opacity))
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white).opacity(0.65)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .rotationEffect(.degrees(shareMomentVM.showAudienceSheet ? 180 : 0))
                }
                .padding(.horizontal, 12.5)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(height: height)
                }
                .frame(height: height)
            }
            .buttonStyle(.scaled)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.66)
            
            if shareMomentVM.showAudienceSheet {
                AudienceSheetView
            }
        }
    }
    
    @ViewBuilder
    private var AudienceSheetView: some View {
        VStack(spacing: 15){
            VStack(alignment: .leading, spacing: 0){
                VStack(alignment: .leading, spacing: 2) {
                    AudienceCell(.friendsOnly)
                    AudienceCell(.friendsOfFriends)
                    AudienceCell(.nearby)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                .cornerRadius(27.5)
                .padding(4)
                AudienceDescription
            }
            .background(.thinMaterial)
            .preferredColorScheme(.dark)
            .cornerRadius(31)
        }
        .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
    }
    
    @ViewBuilder
    private func AudienceCell(_ type: AudienceType) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            shareMomentVM.selectedAudience = type
        } label: {
            HStack(spacing: 12.5){
                Circle()
                    .fill(.white.opacity(0.1))
                    .colorScheme(.dark)
                    .frame(UIDevice.current.navigationBarHeight)
                    .overlay {
                        Image(systemName: type.icon)
                            .foregroundColor(.white).opacity(returnOpacity(type))
                            .font(.system(size: 18, weight: .medium, design: .default))
                    }
                Text(type.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white).opacity(returnOpacity(type))
                Spacer()
                Image(systemName: shareMomentVM.selectedAudience == type ? "smallcircle.filled.circle.fill" : "circle")
                    .foregroundColor(.white).opacity(returnOpacity(type))
                    .font(.system(size: 22, weight: .regular, design: .default))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.scaled)
        .padding(10)
        .background(.white.opacity(0.1))
    }
    
    private func returnOpacity(_ type: AudienceType) -> Double {
        return shareMomentVM.selectedAudience == type ? 1 : 0.65
    }
    
    @ViewBuilder
    private var AudienceDescription: some View {
        Text(shareMomentVM.selectedAudience.description)
            .foregroundColor(.white).opacity(0.55)
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 2.5)
            .padding(.bottom, 7.5)
            .padding(.horizontal, 15)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .center)
    }
    
}
