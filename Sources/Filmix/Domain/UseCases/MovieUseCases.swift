import Foundation

// MARK: - FetchMoviePageUseCase

public final class FetchMoviePageUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(url: URL? = nil, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        repository.fetchPage(url: url, completion: completion)
    }
}

// MARK: - FetchMovieDetailUseCase

public final class FetchMovieDetailUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(path: String, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        repository.fetchDetail(path: path, completion: completion)
    }
}

// MARK: - FetchTranslationsUseCase

public final class FetchTranslationsUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(postId: Int,
                 isSeries: Bool,
                 completion: @escaping (Result<[Translation], Error>) -> Void) {
        repository.fetchTranslations(postId: postId, isSeries: isSeries, completion: completion)
    }
}

// MARK: - SearchMoviesUseCase

public final class SearchMoviesUseCase {
    private let repository: SearchRepositoryProtocol

    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(query: String, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            completion(.success(MoviePage(movies: [], nextPageURL: nil)))
            return
        }
        repository.search(query: trimmed, completion: completion)
    }
}
