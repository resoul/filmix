import Foundation
import Alamofire

// MARK: - FilmixMovieRepository

public final class FilmixMovieRepository: MovieRepositoryProtocol {

    private let client: FilmixNetworkClient

    public init(client: FilmixNetworkClient = .shared) {
        self.client = client
    }

    // MARK: - MovieRepositoryProtocol

    public func fetchPage(url: URL?, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        let target = url?.absoluteString ?? client.baseURL
        client.get(url: target) { result in
            completion(result.flatMap { data in
                Result { try FilmixHTMLParser.parseListing(html: FilmixHTMLParser.decodeData(data)) }
            })
        }
    }

    public func fetchDetail(path: String, completion: @escaping (Result<MovieDetail, Error>) -> Void) {
        let url = path.hasPrefix("http") ? path : "\(client.baseURL)\(path)"
        client.get(url: url) { result in
            completion(result.flatMap { data in
                Result { try FilmixHTMLParser.parseDetail(html: FilmixHTMLParser.decodeData(data)) }
            })
        }
    }

    public func fetchTranslations(postId: Int,
                           isSeries: Bool,
                           completion: @escaping (Result<[Translation], Error>) -> Void) {
        let ts  = Int(Date().timeIntervalSince1970)
        let url = "\(client.baseURL)/api/movies/player-data?t=\(ts)"
        let params: Parameters = ["post_id": "\(postId)", "showfull": "true"]
        let headers: HTTPHeaders = [
            "x-requested-with": "XMLHttpRequest",
            "Cookie": client.cookiesString(for: client.baseURL),
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
        ]

        client.postDecodable(url: url, parameters: params, headers: headers) { (result: Result<PlayerResponseDTO, Error>) in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let dto):
                let entries = dto.message.translations.video.sorted { $0.key < $1.key }

                if isSeries {
                    self.resolveSeriesTranslations(entries: entries, completion: completion)
                } else {
                    let translations: [Translation] = entries.compactMap { studio, encoded in
                        let raw     = StreamDecoder.decodeTokens(encoded)
                        let parts   = raw.split(separator: ",").map(String.init)
                        let streams = StreamDecoder.decodeQualityMap(from: parts)
                        guard !streams.isEmpty else { return nil }
                        return Translation(studio: studio, streams: streams, seasons: [])
                    }
                    completion(.success(translations))
                }
            }
        }
    }

    // MARK: - Private: Series Resolution

    private func resolveSeriesTranslations(
        entries: [(key: String, value: String)],
        completion: @escaping (Result<[Translation], Error>) -> Void
    ) {
        var results: [Translation] = []
        let group = DispatchGroup()
        let lock  = NSLock()

        for (studio, encoded) in entries {
            let secondURL = StreamDecoder.decodeTokens(encoded)
            guard !secondURL.isEmpty else { continue }

            group.enter()
            client.getString(url: secondURL) { response in
                defer { group.leave() }
                guard case .success(let string) = response else { return }

                let json = StreamDecoder.decodeTokens(string)
                guard
                    let data    = json.data(using: .utf8),
                    let serials = try? JSONDecoder().decode([SerialDTO].self, from: data)
                else { return }

                let seasons: [Season] = serials.map { serial in
                    let episodes: [Episode] = serial.folder.map { folder in
                        let streams = StreamDecoder.decodeQualityMap(
                            from: folder.file.split(separator: ",").map(String.init)
                        )
                        return Episode(title: folder.title, id: folder.id, streams: streams)
                    }
                    return Season(title: serial.title, episodes: episodes)
                }

                let translation = Translation(studio: studio, streams: [:], seasons: seasons)
                lock.withLock { results.append(translation) }
            }
        }

        group.notify(queue: .main) {
            completion(.success(results.sorted { $0.studio < $1.studio }))
        }
    }
}

// MARK: - NSLock+withLock helper

private extension NSLock {
    func withLock(_ block: () -> Void) {
        lock(); block(); unlock()
    }
}
