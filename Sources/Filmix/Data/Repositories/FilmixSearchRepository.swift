import Foundation
import Alamofire

// MARK: - FilmixSearchRepository

public final class FilmixSearchRepository: SearchRepositoryProtocol {

    private let client: FilmixNetworkClient

    public init(client: FilmixNetworkClient = .shared) {
        self.client = client
    }

    private static let searchHeaders: HTTPHeaders = [
        "x-requested-with": "XMLHttpRequest",
        "content-type": "application/x-www-form-urlencoded; charset=UTF-8",
        "origin": "https://filmix.my",
        "referer": "https://filmix.my/search/",
        "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
    ]

    // MARK: - SearchRepositoryProtocol

    public func search(query: String, completion: @escaping (Result<MoviePage, Error>) -> Void) {
        let url = "\(client.baseURL)/engine/ajax/sphinx_search.php"
        let params: Parameters = [
            "scf":          "fx",
            "story":        query,
            "search_start": "0",
            "do":           "search",
            "subaction":    "search",
            "years_ot":     "1902",
            "years_do":     "2026",
            "kpi_ot":       "1",
            "kpi_do":       "10",
            "imdb_ot":      "1",
            "imdb_do":      "10",
            "sort_name":    "",
            "sort_date":    "",
            "sort_favorite":"",
            "simple":       "1"
        ]

        client.post(url: url, parameters: params, headers: Self.searchHeaders) { result in
            completion(result.flatMap { data in
                Result { try FilmixHTMLParser.parseListing(html: FilmixHTMLParser.decodeData(data)) }
            })
        }
    }
}
