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
    
    public let animationDuration: CGFloat = 0.25
    
    @Published  public var moments = [Moments]()
    
    override init() {
        
        super.init()
        
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
                    self.moments[items.offset].moments[0].downloadedImage = downloadedImage
                }
            } catch {
                print(error.localizedDescription)
                continue
            }
        }
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
        root.view.gestureRecognizers?.removeLast()
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
        switch gesture.state {
        case .possible, .began:
            onBeginGesture()
        case .changed:
            onChangedGesture()
        case .ended, .cancelled, .failed:
            onEndedGesture()
        @unknown default:
            onEndedGesture()
        }
    }
    
    private func onBeginGesture() {
        
    }
    
    private func onChangedGesture() {
        
    }
    
    private func onEndedGesture() {
        
    }
    
}
