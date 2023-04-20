
import SwiftUI
import DeviceKit
import FirebaseFunctions
import VNVCECore

struct UserCellProperties {
    let size: CGFloat
    
    let imageSize: CGFloat
    let selectedImageSize: CGFloat
    
    let blurSize: CGFloat
    let selectedBlurSize: CGFloat
    
    let backgroundImageSize: CGFloat
    let backgroundSelectedImageSize: CGFloat
    
    init() {
        let smallDevices: [Device] = [.iPhone6, .iPhone7, .iPhone8, .iPhoneSE2, .iPhoneSE3, .simulator(.iPhone6), .simulator(.iPhone7), .simulator(.iPhone8), .simulator(.iPhoneSE2), .simulator(.iPhoneSE3)]
        
        if Device.current.isOneOf(smallDevices) {
            self.size = 68
            self.imageSize = 60
            self.selectedImageSize = 47
            self.blurSize = self.size
            self.selectedBlurSize = self.selectedImageSize
            self.backgroundImageSize = 67
            self.backgroundSelectedImageSize = self.selectedImageSize
        } else {
            self.size = 72
            self.imageSize = 64
            self.selectedImageSize = 51
            self.blurSize = self.size
            self.selectedBlurSize = self.selectedImageSize
            self.backgroundImageSize = 71
            self.backgroundSelectedImageSize = self.selectedImageSize
        }
    }
}

class HomeViewModel: NSObject, ObservableObject {
    lazy var functions = Functions.functions()
    
    public var bottomScrollView: UIScrollView!
    
    public let screen: CGRect = UIScreen.main.bounds
    public let bottomPadding: CGFloat
    
    public let navBarHeight: CGFloat = 36
    public let momentSize: CGSize
    
    public let cameraRaw = "CAMERA"
    
    @Published private(set) public var touchesBegan: Bool = false
    
    @Published public var showBlur: Bool = true
    
    @Published var tab: String
    
    public let cell = UserCellProperties()
    
    @Published public var showSearchView: Bool = false
    @Published public var showProfileView: Bool = false
    
    override init() {
        let width = screen.width
        let height = width * 3 / 2
        momentSize = CGSize(width, height)
        tab = cameraRaw
        bottomPadding = screen.width / 2 - 36
    }
    
    public func bottomScrollViewConnector(_ scrollView: UIScrollView) {
        self.bottomScrollView = scrollView
    }
    
    public func bottomScrollTo(_ inx: Int) {
        let index = CGFloat(inx + 1)
        let offset = 72 * index + 15 * index
        
        self.bottomScrollView.setContentOffset(.init(offset, 0), animated: true)
    }
    
    public func bottomResetScroll() {
        self.bottomScrollView.setContentOffset(.zero, animated: true)
    }
    
}

extension HomeViewModel: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func addGesture() -> UIGestureRecognizer {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(gesture))
        panGesture.delegate = self
        
        return panGesture
    }
    
    @objc
    private func gesture(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            if !touchesBegan {
                withAnimation {
                    touchesBegan = true
                    print("Gesture Started")
                }
            }
        case .ended:
            if touchesBegan {
                withAnimation {
                    touchesBegan = false
                    print("Gesture Ended")
                }
            }
        default: ()
        }
    }
}
