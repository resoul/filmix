import Foundation

public struct MoviePage {
    public let movies: [Movie]
    public let nextPageURL: URL?

    public init(movies: [Movie], nextPageURL: URL?) {
        self.movies = movies
        self.nextPageURL = nextPageURL
    }
}
