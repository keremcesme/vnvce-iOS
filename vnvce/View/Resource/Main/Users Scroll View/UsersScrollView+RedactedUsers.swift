
import SwiftUI
import SwiftUIX

extension UsersScrollView {
    public struct RedactedUsers: View {
        @EnvironmentObject public var homeVM: HomeViewModel
        
        var body: some View {
            ForEach(1...10, id: \.self) { _  in
                Cell
                    .transition(.scale.combined(with: .opacity))
            }
        }
        
        @ViewBuilder
        private var Cell: some View {
            VStack(spacing: 7) {
                Circle()
                    .frame(homeVM.cell.size)
                Capsule()
                    .frame(width: 50, height: 4, alignment: .center)
            }
            .foregroundColor(.primary)
            .opacity(0.1)
            .shimmering()
        }
        
    }
}
