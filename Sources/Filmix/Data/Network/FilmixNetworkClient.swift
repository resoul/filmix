import Foundation
import Alamofire

// MARK: - FilmixNetworkClient

/// Thin Alamofire wrapper. Owns session config, cookies, and auth headers.
public final class FilmixNetworkClient {

    public static let shared = FilmixNetworkClient()
    private init() {}

    public let baseURL = "https://filmix.my"

    private let session: Session = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = [
            "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36"
        ]
        config.httpCookieStorage = .shared
        config.httpShouldSetCookies = true
        config.httpCookieAcceptPolicy = .always
        return Session(configuration: config)
    }()

    // MARK: - Generic Requests

    public func get(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        session.request(url, method: .get).responseData { response in
            completion(response.result.mapError { $0 as Error })
        }
    }

    public func getString(url: String, completion: @escaping (Result<String, Error>) -> Void) {
        session.request(url, method: .get).responseString { response in
            completion(response.result.mapError { $0 as Error })
        }
    }

    public func post(url: String,
              parameters: Parameters,
              headers: HTTPHeaders,
              completion: @escaping (Result<Data, Error>) -> Void) {
        session.request(url, method: .post, parameters: parameters, headers: headers)
            .responseData { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    public func postDecodable<T: Decodable>(url: String,
                                     parameters: Parameters,
                                     headers: HTTPHeaders,
                                     completion: @escaping (Result<T, Error>) -> Void) {
        session.request(url, method: .post, parameters: parameters, headers: headers)
            .responseDecodable(of: T.self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // MARK: - Cookie Helpers

    public func cookiesString(for urlString: String) -> String {
        guard let url = URL(string: urlString),
              let cookies = HTTPCookieStorage.shared.cookies(for: url) else { return "" }

        var header = HTTPCookie.requestHeaderFields(with: cookies)["Cookie"] ?? ""

        if !header.contains("alora="),
           let baseURL = URL(string: baseURL),
           let minotaurs = HTTPCookieStorage.shared.cookies(for: baseURL)?
               .first(where: { $0.name == "minotaurs" }) {
            let sep = header.isEmpty ? "" : "; "
            header += "\(sep)alora=\(minotaurs.value)"
        }
        return header
    }
}
