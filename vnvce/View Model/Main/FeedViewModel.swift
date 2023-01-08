//
//  FeedViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 15.11.2022.
//

import SwiftUI
import Alamofire

struct FeedTest: Codable, Hashable {
    var id: String
    var owner: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case owner = "author"
        case url
    }
}

class FeedViewModel: ObservableObject {
    public var momentsScrollView: UIScrollView!
    
    @Published public var pageIndex: Int = 0
    
    @Published public var data: [FeedTest] = []
    
    @Published public var testData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    
    public func momentsScrollViewConnector(_ scrollView: UIScrollView) {
        momentsScrollView = scrollView
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }
    
    public func scrollTo(id: Int) -> CGFloat {
        return  UIScreen.main.bounds.width * CGFloat(id + 1)
    }
    
    func radiusCorner(id: Int) -> CGFloat {
        return pageIndex == id ? 100 : 15
    }
    
    func findIndex(item: Int) -> Int {
        let index = testData.firstIndex(where: {item == $0 })
        return index!
    }
    
    @Sendable
    public func fetch() async {
        do {
            let url = URL(string: "https://picsum.photos/v2/list")!
            
            let task = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            
            let data = try decoder.decode([FeedTest].self, from: task.0)
            
            await MainActor.run {
                self.data = data
            }
            
        } catch let error  {
            print(error)
            return
        }
        
    }
}
