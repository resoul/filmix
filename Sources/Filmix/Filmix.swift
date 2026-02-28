import Foundation

public final class Filmix {

    public static let shared = Filmix()
    private init() {}

    public private(set) lazy var networkClient: FilmixNetworkClient = .shared

    public private(set) lazy var movieRepository: MovieRepositoryProtocol = FilmixMovieRepository(client: networkClient)
    public private(set) lazy var searchRepository: SearchRepositoryProtocol = FilmixSearchRepository(client: networkClient)

    public var fetchMoviePage: FetchMoviePageUseCase { FetchMoviePageUseCase(repository: movieRepository) }
    public var fetchMovieDetail: FetchMovieDetailUseCase { FetchMovieDetailUseCase(repository: movieRepository) }
    public var fetchTranslations: FetchTranslationsUseCase { FetchTranslationsUseCase(repository: movieRepository) }
    public var searchMovies: SearchMoviesUseCase { SearchMoviesUseCase(repository: searchRepository) }
}
