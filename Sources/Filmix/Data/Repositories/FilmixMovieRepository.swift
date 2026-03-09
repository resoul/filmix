import Foundation
import Alamofire

// MARK: - FilmixMovieRepository

public final class FilmixMovieRepository: MovieRepositoryProtocol {

    private let client: FilmixNetworkClient

    public init(client: FilmixNetworkClient = .shared) {
        self.client = client
    }

    // MARK: - MovieRepositoryProtocol

    public func fetchPage(url: URL?) async throws -> MoviePage {
        let target = url?.absoluteString ?? client.baseURL
        let data = try await client.get(url: target)
        return try FilmixHTMLParser.parseListing(html: FilmixHTMLParser.decodeData(data))
    }

    public func fetchDetail(path: String) async throws -> MovieDetail {
        let url = path.hasPrefix("http") ? path : "\(client.baseURL)\(path)"
        let data = try await client.get(url: url)
        return try FilmixHTMLParser.parseDetail(html: FilmixHTMLParser.decodeData(data))
    }

    public func fetchTranslations(postId: Int, isSeries: Bool) async throws -> [Translation] {
        let ts = Int(Date().timeIntervalSince1970)
        let url = "\(client.baseURL)/api/movies/player-data?t=\(ts)"
        let params: Parameters = ["post_id": "\(postId)", "showfull": "true"]
        let headers: HTTPHeaders = [
            "x-requested-with": "XMLHttpRequest",
            "Cookie": client.cookiesString(for: client.baseURL),
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
        ]

        let dto: PlayerResponseDTO = try await client.postDecodable(url: url, parameters: params, headers: headers)
        let entries = dto.message.translations.video.sorted { $0.key < $1.key }

        if isSeries {
            return try await resolveSeriesTranslations(entries: entries)
        }

        return entries.compactMap { studio, encoded in
            let raw = StreamDecoder.decodeTokens(encoded)
            let parts = raw.split(separator: ",").map(String.init)
            let streams = StreamDecoder.decodeQualityMap(from: parts)
            guard !streams.isEmpty else { return nil }
            return Translation(studio: studio, streams: streams, seasons: [])
        }
    }

    // MARK: - Private: Series Resolution

    private func resolveSeriesTranslations(entries: [(key: String, value: String)]) async throws -> [Translation] {
        try await withThrowingTaskGroup(of: Translation?.self) { group in
            for (studio, encoded) in entries {
                group.addTask {
                    let secondURL = StreamDecoder.decodeTokens(encoded)
                    guard !secondURL.isEmpty else { return nil }

                    let string = try await self.client.getString(url: secondURL)
                    let json = StreamDecoder.decodeTokens(string)

                    guard
                        let data = json.data(using: .utf8),
                        let serials = try? JSONDecoder().decode([SerialDTO].self, from: data)
                    else {
                        return nil
                    }

                    let seasons: [Season] = serials.map { serial in
                        let episodes: [Episode] = serial.folder.map { folder in
                            let streams = StreamDecoder.decodeQualityMap(
                                from: folder.file.split(separator: ",").map(String.init)
                            )
                            return Episode(title: folder.title, id: folder.id, streams: streams)
                        }
                        return Season(title: serial.title, episodes: episodes)
                    }

                    return Translation(studio: studio, streams: [:], seasons: seasons)
                }
            }

            var results: [Translation] = []
            for try await translation in group {
                if let translation {
                    results.append(translation)
                }
            }
            return results.sorted { $0.studio < $1.studio }
        }
    }
}

