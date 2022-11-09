//
//  MomentsViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.11.2022.
//

import Foundation
import SwiftUI

@MainActor
class MomentsViewModel: NSObject, ObservableObject {
    private let momentAPI = MomentAPI.shared
    private let imageLoader = ImageLoader()
    
    @Published public var scrollView: UIScrollView!
    
    public let animationDuration: CGFloat = 0.25
    public let blur: UIBlurEffect.Style = .light
    
    @Published public var moments = [Moments]()
    
    @Published  public var selectedMomentCellSize: CGSize!
    @Published  public var selectedMomentCellFrame: CGRect!
    
    @Published private(set) public var viewWillAppear: Bool = false
    @Published private(set) public var show: Bool = false // Animation Variable
    @Published private(set) public var viewIsReady: Bool = false
    
    @Published private(set) public var viewOffset: CGSize = .zero
    
    @Published private(set) public var onDragging: Bool = false
    @Published private(set) public var onDraggingAnimation: Bool = false // Animation Variable
    
    @Published public var pageIndex: Int = 0
    
    override init() {
        super.init()
    }
    
    public func scrollViewConnector(_ scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
}

// MARK: Actions:
@MainActor
extension MomentsViewModel {
    public func gridCellTapAction(index: Int, size: CGSize, frame: CGRect) async {
        guard !viewWillAppear else { return }
        self.onDragging = false
        self.onDraggingAnimation = false
        
        self.selectedMomentCellSize = size
        self.selectedMomentCellFrame = frame
        self.pageIndex = index
        self.viewWillAppear = true
        
        do {
            self.removeGesture()
            try await Task.sleep(seconds: 0.001)
            self.addGesture()
            withAnimation(response: self.animationDuration) {
                self.show = true
            } after: {
                self.viewIsReady = true
            }
        } catch {
            return
        }
    }
    
    @Sendable
    public func dismiss() async {
        self.viewIsReady = false
        self.removeGesture()
        do {
            try await Task.sleep(seconds: 0.001)
            withAnimation(response: self.animationDuration) {
                self.viewOffset = .zero
                self.show = false
            } after: {
                Task {
                    try? await Task.sleep(seconds: 0.1)
                    self.viewWillAppear = false
                }
            }
        } catch {
            return
        }
    }
    
    public func dismissNonAsync() {
        Task(operation: self.dismiss)
    }
    
    public func onChangeViewIsReady(size: CGSize, frame: CGRect) {
        self.selectedMomentCellSize = size
        self.selectedMomentCellFrame = frame
    }
    
}

// MARK: Fetch Moments
extension MomentsViewModel {
    
    public func fetchMoments() async {
        if Task.isCancelled { return }
        do {
            var result = try await momentAPI.fetchMoments(.me)
            if Task.isCancelled { return }
            
            for moment in result.enumerated() {
                let date = Date(timeIntervalSince1970: moment.element.createdAt)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                
                let dateString = dateFormatter.string(from: date)
                let int: Int = Int(dateString)!
                
                result[moment.offset].date = int
            }
            
            var sortedMoments: [[Moment]] = Dictionary(grouping: result, by: { $0.date!})
                .sorted(by: { $0.key > $1.key })
                .map { $0.value}
            
            for sortedMoment in sortedMoments.enumerated() {
                sortedMoments[sortedMoment.offset] = sortedMoment.element.reversed()
            }
            
            var newMoments = [Moments]()
            for moments in sortedMoments {
                
                let moments = Moments(day: getDayString(first: moments.first!), moments: moments)
                newMoments.append(moments)
            }
            
            await MainActor.run {
                self.moments = newMoments
                Task.detached(operation: downloadImages)
            }
        } catch {
            print(error.localizedDescription)
            return
        }
    }
    
    private func getDayString(first moment: Moment) -> String {
        let date = Date(timeIntervalSince1970: moment.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
    
}

// MARK: Download Images
extension MomentsViewModel {
    
    @Sendable
    public func downloadImages() async {
        for items in self.moments.enumerated() where items.element.moments.first?.downloadedImage == nil {
            guard let firstMoment = items.element.moments.first else {
                continue
            }
            
            let request = URLRequest(url: firstMoment.returnURL)
            
            do {
                let image = try await imageLoader.fetch(request)
                DispatchQueue.main.async {
                    let downloadedImage = CodableImage(image: image)
                    if self.moments[safe: items.offset]?.moments[safe: 0] != nil {
                        self.moments[items.offset].moments[0].downloadedImage = downloadedImage
                    }
                }
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
        print("ALL IMAGES IS DOWNLOADED")
    }
    
    public func downloadMoreImages(index: Int) async {
        for items in self.moments[index].moments.enumerated() where items.element.downloadedImage == nil {
            let request = URLRequest(url: items.element.returnURL)
            
            do {
                let image = try await imageLoader.fetch(request)
                DispatchQueue.main.async {
                    let downloadedImage = CodableImage(image: image)
                    self.moments[index].moments[items.offset].downloadedImage = downloadedImage
                }
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
    }
    
}

// MARK: Gesture PUBLIC -
extension MomentsViewModel {
    // MARK: Adding Gesture
    public func addGesture() {
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(gesture))
        dragGesture.delegate = self
        dragGesture.maximumNumberOfTouches = 1
        let root = findRootViewController()
        root.view.addGestureRecognizer(dragGesture)
    }
    
    // MARK: Removing When Leaving The View
    public func removeGesture() {
        let root = findRootViewController()
        root.view.gestureRecognizers?.removeAll()
    }
}

// MARK: Gesture PRIVATE -
extension MomentsViewModel: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Finding Root Controller
    private func findRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    @objc
    private func gesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: gesture.view)
        let velo = gesture.velocity(in: gesture.view)
        switch gesture.state {
        case .possible, .began:
            onBeginGesture(velo)
        case .changed:
            onChangedGesture(translation)
        case .ended, .cancelled, .failed:
            onEndedGesture(translation, velo)
        @unknown default:
            onEndedGesture(translation, velo)
        }
    }
    
    private func onBeginGesture(_ velo: CGPoint) {
        let angle = atan2(velo.y, velo.x) * 180 / 3.14159
        if (angle <= (self.pageIndex == 0 ? 125 : 55) && angle >= (self.pageIndex == self.moments.count - 1 ? -155 : -55)) {
            DispatchQueue.main.async {
                self.scrollView.isScrollEnabled = false
                self.onDragging = true
                withAnimation(response: self.animationDuration) {
                    self.onDraggingAnimation = true
                }
//                if !UIDevice.current.hasNotch() {
//                    UIDevice.current.showStatusBar()
//                }
            }
        }
    }
    
    private func onChangedGesture(_ translation: CGPoint) {
        let width: CGFloat = translation.width / 1.5
        let height: CGFloat = translation.height / 1.5
        DispatchQueue.main.async {
            if self.onDragging {
                let size = CGSize(width, height)
                self.viewOffset = size
            }
        }
    }
    
    private func onEndedGesture(_ translation: CGPoint, _ velo: CGPoint) {
        let width: CGFloat = translation.width / 1.5
        let height: CGFloat = translation.height / 1.5
        DispatchQueue.main.async {
            if self.onDragging {
                self.scrollView.isScrollEnabled = true
                
                if width >= 25 || height >= 25 {
                    self.dismissNonAsync()
                }
                
//                else if abs(velo.y) > 100 && (width >= 5 || height >= 5) {
//                    self.dismissNonAsync()
//                }
                
                else {
                    withAnimation(response: self.animationDuration) {
                        self.viewOffset = .zero
                        self.onDraggingAnimation = false
                    } after: {
                        self.onDragging = false
                        
                        
//                        if !UIDevice.current.hasNotch() {
//                            UIDevice.current.hideStatusBar()
//                        }
                    }
                }
            }
        }
    }
    
}
