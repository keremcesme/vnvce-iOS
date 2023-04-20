
import SwiftUI

extension View {
    
    @ViewBuilder
    func navigationDestination<V: View>(
        isPresented: Binding<Bool>,
        isDetailLink: Bool = false,
        @ViewBuilder destination: () -> V
    ) -> some View{
        if #available(iOS 16.0, *) {
            self
                .navigationDestination(isPresented: isPresented, destination: destination)
        } else {
            self
                .background {
                    NavigationLink(isActive: isPresented, destination: destination) { EmptyView() }
                        .isDetailLink(isDetailLink)
                }
        }
    }
    
}
