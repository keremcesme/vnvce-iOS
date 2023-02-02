
import SwiftUI

extension ProfilePictureCropView {
    public struct GestureView: UIViewRepresentable {
        
        @Binding public var isInteracting: Bool
        @Binding public var offset: CGSize
        @Binding public var lastOffset: CGSize
        @Binding public var scale: CGFloat
        @Binding public var lastScale: CGFloat
        
        @State private var initialCenter: CGSize = .zero
        
        let view = UIView()
        
        class Coordinator: NSObject, UIGestureRecognizerDelegate {
            
            private var parent: GestureView
            
            init(_ parent: GestureView) {
                self.parent = parent
            }
            
            func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                return true
            }
            
            @objc
            public func panGesture(_ gesture: UIPanGestureRecognizer) {
                switch gesture.state {
                case .began:
                    parent.isInteracting = true
                    parent.initialCenter = parent.offset
                case .changed:
                    DispatchQueue.main.async {
                        let translation = gesture.translation(in: gesture.view)
                        
                        self.parent.offset = CGSize(self.parent.initialCenter.x + translation.x,
                                                    self.parent.initialCenter.y + translation.y)
                    }
                case .ended, .cancelled:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.parent.isInteracting = false
                    }
                default:
                    break
                }
            }
            
            @objc
            public func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
                switch gesture.state {
                case .began:
                    parent.isInteracting = true
                case .changed:
                    let delta = gesture.scale / parent.lastScale
                    parent.lastScale = gesture.scale
                    let zoomDelta = parent.scale * delta
                    var minMaxScale = max(1, zoomDelta)
                    minMaxScale = min(5, minMaxScale)
                    
                    parent.scale = minMaxScale
                case .ended, .cancelled:
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        self.parent.lastScale = 1
                        if self.parent.scale <= 1 {
                            withAnimation(.interactiveSpring()) {
                                self.parent.scale = 1
                            }
                        } else if self.parent.scale > 5 {
                            self.parent.scale = 5
                        }
                        self.parent.isInteracting = false
                    }
                    
                default:
                    break
                }
            }
            
        }
        
        func makeUIView(context: Context) -> UIView {
            
            view.frame.size = UIScreen.main.bounds.size
            
            let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.panGesture))
            let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pinchGesture))
            
            panGesture.delegate = context.coordinator
            pinchGesture.delegate = context.coordinator
            
            view.addGestureRecognizer(panGesture)
            view.addGestureRecognizer(pinchGesture)
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
    }
}
