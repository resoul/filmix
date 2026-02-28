# Filmix

> ⚠️ **This is a demo project.** Created solely for educational purposes as an example of Clean Architecture implementation in a Swift Package targeting iOS, tvOS, and macOS.

---

## Overview

Filmix is a Swift Package demonstrating a multiplatform app architecture based on Clean Architecture principles. The project shows how to properly separate business logic, networking, and HTML parsing into isolated, easily testable components.

## Platforms

| Platform | Minimum Version |
|----------|----------------|
| iOS      | 16.0+          |
| tvOS     | 16.0+          |
| macOS    | 13.0+          |

## Architecture

The project follows **Clean Architecture** and is split into two layers:

```
Sources/Filmix/
│
├── Domain/                  # Business logic — no UIKit or networking dependencies
│   ├── Entities/            # Movie, MovieDetail, Category, Genre, Translation…
│   ├── Repositories/        # Protocols: MovieRepositoryProtocol, SearchRepositoryProtocol
│   └── UseCases/            # FetchMoviePageUseCase, FetchMovieDetailUseCase…
│
└── Data/                    # Implementations — networking, parsing, decoding
    ├── Network/             # FilmixNetworkClient (Alamofire wrapper)
    ├── Parsers/             # FilmixHTMLParser (SwiftSoup → Domain models)
    ├── Repositories/        # FilmixMovieRepository, FilmixSearchRepository
    ├── DTOs/                # Codable models for JSON API responses
    └── StreamDecoder.swift  # Obfuscated stream URL decoder
```

### Dependency Rule

```
Presentation → Domain ← Data
```

- **Domain** has no knowledge of networking, UI, or storage
- **Data** implements protocols defined in Domain
- **Presentation** (in your app) only interacts with Use Cases

## Dependencies

| Package | Purpose |
|---------|---------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | HTTP networking |
| [SwiftSoup](https://github.com/scinfu/SwiftSoup) | HTML parsing |

## Installation

### Swift Package Manager

In your app's `Package.swift`:

```swift
dependencies: [
    .package(path: "../Filmix") // local package
]
```

Or via Xcode: **File → Add Package Dependencies → Add Local...**

Then add `Filmix` to **Frameworks, Libraries and Embedded Content** for each target.

## Usage

```swift
import Filmix

// Fetch movie listing
let useCase = Filmix.shared.fetchMoviePage
useCase.execute(url: nil) { result in
    switch result {
    case .success(let page):
        print(page.movies)
    case .failure(let error):
        print(error)
    }
}

// Search
let search = Filmix.shared.searchMovies
search.execute(query: "Inception") { result in
    // ...
}
```

## Testing

Repository protocols make it easy to inject mocks:

```swift
final class MockMovieRepository: MovieRepositoryProtocol {
    func fetchPage(url: URL?, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        completion(.success(MoviePage(movies: [], nextPageURL: nil)))
    }
    // ...
}

let useCase = FetchMoviePageUseCase(repository: MockMovieRepository())
```

## Disclaimer

This project was created **for demo and educational purposes only** as an example of a Clean Architecture approach in Swift. It is not intended for commercial use.