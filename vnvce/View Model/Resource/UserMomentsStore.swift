
import SwiftUI
import VNVCECore

class UserMomentsStore: ObservableObject {
    public let screen: CGRect = UIScreen.main.bounds
    public let navBarHeight: CGFloat = 36
    public let momentSize: CGSize
    
    @Published public var usersWithMoments: [UserWithMoments.V1] = [
        .init(
            owner: .init(
                id: UUID(),
                username: "madelyn",
                displayName: "Madelyn 💧",
                profilePictureURL: "person1"),
            moments: [
                .init(
                    id: UUID(),
                    media: .init(
                        id: UUID(),
                        mediaType: .image,
                        url: "moment1",
                        sensitiveContent: false),
                    createdAt: Date().timeIntervalSince1970)
            ]),
        .init(
            owner: .init(
                id: UUID(),
                username: "phillip_mango",
                displayName: "Phillip Mango",
                profilePictureURL: "person2"),
            moments: [
                .init(
                    id: UUID(),
                    media: .init(
                        id: UUID(),
                        mediaType: .image,
                        url: "moment2",
                        sensitiveContent: false),
                    createdAt: Date().timeIntervalSince1970),
                .init(
                    id: UUID(),
                    media: .init(
                        id: UUID(),
                        mediaType: .image,
                        url: "moment4",
                        sensitiveContent: false),
                    createdAt: Date().timeIntervalSince1970)
            ]),
        .init(
            owner: .init(
                id: UUID(),
                username: "kierra_rhiel",
                displayName: "Kierra Rhiel",
                profilePictureURL: "person3"),
            moments: [
                .init(
                    id: UUID(),
                    media: .init(
                        id: UUID(),
                        mediaType: .image,
                        url: "moment3",
                        sensitiveContent: false),
                    createdAt: Date().timeIntervalSince1970)
            ]),
    ]
    
    @Published public var currentMoment: VNVCECore.Moment.V1?
    
    init() {
        let width = screen.width
        let height = width * 3 / 2
        momentSize = CGSize(width, height)
    }
}
