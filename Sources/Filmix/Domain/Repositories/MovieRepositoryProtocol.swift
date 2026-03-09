import Foundation

// MARK: - MovieRepositoryProtocol

public protocol MovieRepositoryProtocol {
    /// Fetch a paginated listing from a URL (nil = home page)
    func fetchPage(url: URL?) async throws -> MoviePage

    /// Fetch full detail for a movie/series by path or full URL
    func fetchDetail(path: String) async throws -> MovieDetail

    /// Fetch available player translations (streams or series seasons)
    func fetchTranslations(postId: Int, isSeries: Bool) async throws -> [Translation]
}

// MARK: - SearchRepositoryProtocol

public protocol SearchRepositoryProtocol {
    func search(query: String) async throws -> MoviePage
}
