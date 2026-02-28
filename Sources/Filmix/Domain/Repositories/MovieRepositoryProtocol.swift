import Foundation

// MARK: - MovieRepositoryProtocol

public protocol MovieRepositoryProtocol {
    /// Fetch a paginated listing from a URL (nil = home page)
    func fetchPage(url: URL?, completion: @escaping (Result<MoviePage, Error>) -> Void)

    /// Fetch full detail for a movie/series by path or full URL
    func fetchDetail(path: String, completion: @escaping (Result<MovieDetail, Error>) -> Void)

    /// Fetch available player translations (streams or series seasons)
    func fetchTranslations(postId: Int, isSeries: Bool,
                           completion: @escaping (Result<[Translation], Error>) -> Void)
}

// MARK: - SearchRepositoryProtocol

public protocol SearchRepositoryProtocol {
    func search(query: String, completion: @escaping (Result<MoviePage, Error>) -> Void)
}
