//
//  UserMomentsViewModelOLD.swift
//  vnvce
//
//  Created by Kerem Cesme on 24.10.2022.
//

import Foundation
import SwiftUI
import Nuke

@MainActor
class UserMomentsViewModelOLD: NSObject, ObservableObject {
    private let momentAPI = MomentAPI.shared
    private let imageLoader = ImageLoader()
    
    public let animationDuration: CGFloat = 0.25
    
//    @Published public var moments = [[Moment]]()
    @Published public var momentsMain = [Moments]()
    
    // NEW
    @Published private(set) public var selectedMomentDayID: UUID!
    @Published private(set) public var selectedMomentDayIndex: Int!
    @Published private(set) public var selectedMomentDayCellSize: CGSize!
    @Published private(set) public var selectedMomentDayCellFrame: CGRect!
    
    @Published private(set) public var momentsViewWillAppear: Bool = false
    @Published private(set) public var openMomentsView: Bool = false // Animation Variable
    @Published private(set) public var momentsViewIsReady: Bool = false
    
    @Published public var currentIndex: Int = 0
    @Published public var disablePaging: Bool = true
    @Published public var offset: CGSize = .zero
    @Published public var onDragging: Bool = false
    @Published public var disablePage: Bool = false
    
    @MainActor
    public func momentCellTapAction(id: UUID, index: Int, size: CGSize, frame: CGRect) async {
        guard !momentsViewWillAppear else { return }
        self.onDragging = false
        
        self.selectedMomentDayID = id
        self.selectedMomentDayIndex = index
        self.selectedMomentDayCellSize = size
        self.selectedMomentDayCellFrame = frame
        
        self.currentIndex = index
        
        self.momentsViewWillAppear = true
        
        try? await Task.sleep(seconds: 0.001)
        
//        self.addGesture()
        
        withAnimation(response: animationDuration) {
            self.openMomentsView = true
        } after: {
            self.momentsViewIsReady = true
            if !UIDevice.current.hasNotch() {
                UIDevice.current.hideStatusBar()
            }
            Task.detached {
                await self.downloadMoreImages2(index: index)
            }
        }
    }
    
    public func dismiss() {
        DispatchQueue.main.async {
            Task {
                if !UIDevice.current.hasNotch() {
                    UIDevice.current.showStatusBar()
                    try? await Task.sleep(seconds: 0.01)
                }
                
                self.momentsViewIsReady = false
                
//                self.removeGesture()
                try? await Task.sleep(seconds: 0.01)
                withAnimation(response: self.animationDuration) {
                    self.offset = .zero
                    self.openMomentsView = false
                } after: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.momentsViewWillAppear = false
                    }
                }
            }
            
        }
    }
    
    public func onChangeIndexUpdateCell(size: CGSize, frame: CGRect){
        DispatchQueue.main.async {
                self.selectedMomentDayCellSize = size
                self.selectedMomentDayCellFrame = frame
        }
    }
    
    public func onChangeIndexUpdateCurrentMoment(id: UUID){
        DispatchQueue.main.async {
            if self.momentsViewIsReady {
                self.selectedMomentDayID = id
                self.selectedMomentDayIndex = self.currentIndex
            }
        }
    }
    
    func fetchMoments() async {
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
//                self.moments = sortedMoments
                self.momentsMain = newMoments
            }
            
//            await downloadImages2()
//
//            for momentDay in self.momentsMain {
//                print("~~~~~~~~~~~~~~~~~")
//                print("Day: \(momentDay.day)")
//                print("Count: \(momentDay.count)")
//                for moment in momentDay.moments {
//                    print("     ID: \(moment.id)")
//                    print("     DATE: \(getDateString(moment: moment))")
//                    print("     Downloaded Image: \(moment.downloadedImage)")
//                    print("     ~~~~~~~~~")
//                }
//            }
            
            Task.detached(operation: downloadImages2)
            
            
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
    
    private func getDateString(moment: Moment) -> String {
        let date = Date(timeIntervalSince1970: moment.createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd-MM-yyyy "
        return formatter.string(from: date)
    }
    
}

// MARK: Download Images
extension UserMomentsViewModelOLD {
//    @Sendable
//    public func downloadImages() async {
//        for items in self.moments.enumerated() where items.element.first?.downloadedImage == nil {
//            if let firstMoment = items.element.first {
//                let request = URLRequest(url: firstMoment.returnURL)
//                do {
//                    let image = try await imageLoader.fetch(request)
//                    DispatchQueue.main.async {
//                        let downloadedImage = CodableImage(image: image)
//                        self.moments[items.offset][0].downloadedImage = downloadedImage
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                    return
//                }
//            }
//        }
//    }
    
    @Sendable
    public func downloadImages2() async {
        for items in self.momentsMain.enumerated() where items.element.moments.first?.downloadedImage == nil {
            guard let firstMoment = items.element.moments.first else {
                continue
            }
            
            let request = URLRequest(url: firstMoment.returnURL)
            
            do {
                let image = try await imageLoader.fetch(request)
                DispatchQueue.main.async {
                    let downloadedImage = CodableImage(image: image)
                    self.momentsMain[items.offset].moments[0].downloadedImage = downloadedImage
                }
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
    }
    
//    public func downloadMoreImages(index: Int) async {
//        let moments = self.moments[index]
//        for items in moments.enumerated() where items.element.downloadedImage == nil {
//            let request = URLRequest(url: items.element.returnURL)
//            do {
//                let image = try await imageLoader.fetch(request)
//                DispatchQueue.main.async {
//                    let downloadedImage = CodableImage(image: image)
//                    self.moments[index][items.offset].downloadedImage = downloadedImage
//                }
//            } catch {
//                print(error.localizedDescription)
//                return
//            }
//        }
//    }
    
    public func downloadMoreImages2(index: Int) async {
        for items in self.momentsMain[index].moments.enumerated() where items.element.downloadedImage == nil {
            let request = URLRequest(url: items.element.returnURL)
            
            do {
                let image = try await imageLoader.fetch(request)
                DispatchQueue.main.async {
                    let downloadedImage = CodableImage(image: image)
                    self.momentsMain[index].moments[items.offset].downloadedImage = downloadedImage
                }
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
    }
    
}

// MARK: Gesture:
extension UserMomentsViewModelOLD: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Adding Gesture
    public func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange))
        panGesture.delegate = self
        panGesture.maximumNumberOfTouches = 1
        rootController().view.addGestureRecognizer(panGesture)
    }
    
    
    
    // MARK: Removing When Leaving The View
    public func removeGesture() {
        rootController().view.gestureRecognizers?.removeLast()
    }
    
    // MARK: Finding Root Controller
    private func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = screen.windows.first?.rootViewController
        else {
            return .init()
        }
        
        return root
    }
    
    @objc
    private func onGestureChange(gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: gesture.view)
        let width: CGFloat = offset.width / 2
        let height: CGFloat = offset.height / 2
        let velocity = gesture.velocity(in: gesture.view)
        
        switch gesture.state {
        case .possible, .began:
            let angle = atan2(velocity.y, velocity.x) * 180 / 3.14159
            
            if (angle <= (self.currentIndex == 0 ? 125 : 55) && angle >= (self.currentIndex == self.momentsMain.count - 1 ? -155 : -55)) {
                DispatchQueue.main.async {
                    self.onDragging = true
                    if !UIDevice.current.hasNotch() {
                        UIDevice.current.showStatusBar()
                    }
                }
            }
        case .changed:
            DispatchQueue.main.async {
                if self.onDragging {
                    let size = CGSize(width, height)
                    self.offset = size
                }
            }
        case .ended, .cancelled, .failed:
            DispatchQueue.main.async {
                if self.onDragging {
                    if width >= 25 || height >= 25 {
                        self.dismiss()
                    } else if abs(velocity.y) > 100 && (width >= 5 || height >= 5) {
                        self.dismiss()
                    } else {
                        withAnimation(response: self.animationDuration) {
                            self.offset = .zero
                        } after: {
                            self.onDragging = false
                            if !UIDevice.current.hasNotch() {
                                UIDevice.current.hideStatusBar()
                            }
                        }
                    }
                }
            }
        @unknown default:
            fatalError()
        }
    }
}
