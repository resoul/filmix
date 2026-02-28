import Foundation

public struct Season {
    public let title: String
    public let episodes: [Episode]

    public init(title: String, episodes: [Episode]) {
        self.title = title
        self.episodes = episodes
    }
}
