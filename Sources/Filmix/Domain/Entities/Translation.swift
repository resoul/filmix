import Foundation

public struct Translation {
    public let studio: String
    public let streams: [String: String]
    public let seasons: [Season]

    public init(studio: String, streams: [String: String], seasons: [Season]) {
        self.studio = studio
        self.streams = streams
        self.seasons = seasons
    }

    public var isSeries: Bool { !seasons.isEmpty }

    public var sortedQualities: [String] {
        let order = ["4K UHD", "1080p Ultra+", "1080p", "720p", "480p", "360p"]
        let known   = order.filter { streams[$0] != nil }
        let unknown = streams.keys.filter { !order.contains($0) }.sorted()
        return known + unknown
    }

    public var bestQuality: String? { sortedQualities.first }
    public var bestURL: String?     { bestQuality.flatMap { streams[$0] } }
}
