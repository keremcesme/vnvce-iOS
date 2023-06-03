
import SwiftUI
import SwiftUIX

extension UsersScrollView {
    
    @ViewBuilder
    public func DiscoveryButton(action: @escaping () -> Void) -> some View {
        Button(action: action, label: ButtonLabel)
            .buttonStyle(.scaled)
            .id(homeVM.cameraRaw)
    }
    
    @ViewBuilder
    private func ButtonLabel() -> some View {
        VStack(spacing: 7, content: ButtonVStackContent)
            .animation(.easeInOut(duration: 0.3), value: homeVM.currentTab)
    }
    
    @ViewBuilder
    private func ButtonVStackContent() -> some View {
        ZStack(content: ButtonZStackContent)
        ChevronDown
    }
    
    @ViewBuilder
    private func ButtonZStackContent() -> some View {
        Circle()
            .fill(.primary.opacity(0.1))
            .frame(homeVM.cell.size)
        Group(content: ButtonIcon)
            .foregroundColor(.primary)
            .opacity(0.85)
            .frame(30)
            .transition(.scale.combined(with: .opacity))
    }
    
    @ViewBuilder
    private func ButtonIcon() -> some View {
        if homeVM.currentTab == homeVM.cameraRaw {
            Image("discovery_icon")
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Image("camera_fill_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                
        }
    }
    
    @ViewBuilder
    private var ChevronDown: some View {
        if homeVM.currentTab == homeVM.cameraRaw {
            Image(systemName: "chevron.down")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .transition(.opacity.combined(with: .scale))
        }
    }
}
