import Foundation

public struct Episode {
    public let title: String
    public let id: String
    public let streams: [String: String]

    public init(title: String, id: String, streams: [String: String]) {
        self.title = title
        self.id = id
        self.streams = streams
    }
}
