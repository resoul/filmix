import Foundation

// MARK: - FetchMoviePageUseCase

public final class FetchMoviePageUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(url: URL? = nil) async throws -> MoviePage {
        try await repository.fetchPage(url: url)
    }
}

// MARK: - FetchMovieDetailUseCase

public final class FetchMovieDetailUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(path: String) async throws -> MovieDetail {
        try await repository.fetchDetail(path: path)
    }
}

// MARK: - FetchTranslationsUseCase

public final class FetchTranslationsUseCase {
    private let repository: MovieRepositoryProtocol

    public init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(postId: Int, isSeries: Bool) async throws -> [Translation] {
        try await repository.fetchTranslations(postId: postId, isSeries: isSeries)
    }
}

// MARK: - SearchMoviesUseCase

public final class SearchMoviesUseCase {
    private let repository: SearchRepositoryProtocol

    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(query: String) async throws -> MoviePage {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            return MoviePage(movies: [], nextPageURL: nil)
        }
        return try await repository.search(query: trimmed)
    }
}
