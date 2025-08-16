import Foundation

class StreamProvider {
    private var playerDataUrl: String
    private var streamID: Int
    private var streamCategory: String

    init?(url: String) {
        guard let uri = URL(string: url) else { return nil }

        self.streamID = StreamProvider.getIDFromURL(url: url)

        let pathComponents = uri.path.split(separator: "/").map { String($0) }
        self.streamCategory = pathComponents.first ?? ""

        self.playerDataUrl = "\(uri.scheme ?? "https")://\(uri.host ?? "")/api/movies/player-data?t=\(Int(Date().timeIntervalSince1970))"
    }

    static func getIDFromURL(url: String) -> Int {
        let parts = url.split(separator: "/")
        guard let last = parts.last else { return 0 }
        let subParts = last.split(separator: "-", maxSplits: 1)
        return Int(subParts.first ?? "") ?? 0
    }

    private func request(
        method: String,
        url: String,
        headers: [String: String] = [:],
        body: [String: String]? = nil,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let reqURL = URL(string: url) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        var request = URLRequest(url: reqURL)
        request.httpMethod = method

        for (k, v) in headers {
            request.addValue(v, forHTTPHeaderField: k)
        }

        if let body = body {
            let bodyString = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            request.httpBody = bodyString.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                completion(.failure(err))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "Empty response", code: 0)))
                return
            }
            completion(.success(data))
        }.resume()
    }

    private func sendRequest(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let headers = [
            "x-requested-with": "XMLHttpRequest",
            "Cookie": "FILMIXNET=ah3mgjr8vgfe84u86vcvu5gcp9"
        ]
        let body = [
            "post_id": String(streamID),
            "showfull": "true"
        ]

        request(method: "POST", url: playerDataUrl, headers: headers, body: body) { result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "Invalid JSON", code: 0)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    func getStreamData(completion: @escaping ([String: Any]) -> Void) {
        sendRequest { result in
            switch result {
            case .success(let response):
                var stream: [String: Any] = [:]
                if let type = response["type"] as? String, type == "success" {
                    if let message = response["message"] as? [String: Any],
                       let translations = (message["translations"] as? [String: Any])?["video"] as? [String: Any] {
                        for (translation, rawVideo) in translations {
                            guard let video = rawVideo as? String else { continue }
                            if self.streamCategory == "film" {
                                let decoded = self.decode(video)
                                let parts = decoded.split(separator: ",").map { String($0) }
                                stream[translation] = self.convertFromString(list: parts)
                            } else {
                                // сериал
                                self.request(method: "GET", url: self.decode(video)) { result in
                                    switch result {
                                    case .success(let data):
                                        do {
                                            if let series = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                                                var translationMap: [String: [String: Any]] = [:]
                                                for serie in series {
                                                    guard let title = (serie["title"] as? String)?.trimmingCharacters(in: .whitespaces) else { continue }
                                                    if let folders = serie["folder"] as? [[String: Any]] {
                                                        var folderMap: [String: Any] = [:]
                                                        for folder in folders {
                                                            if let id = folder["id"],
                                                               let fTitle = folder["title"] as? String,
                                                               let file = folder["file"] as? String {
                                                                let files = file.split(separator: ",").map { String($0) }
                                                                folderMap["\(id)"] = [
                                                                    "title": fTitle.trimmingCharacters(in: .whitespaces),
                                                                    "quality": self.convertFromString(list: files)
                                                                ]
                                                            }
                                                        }
                                                        translationMap[title] = folderMap
                                                    }
                                                }
                                                stream[translation] = translationMap
                                                completion(stream)
                                            }
                                        } catch {
                                            print("Decode error: \(error)")
                                        }
                                    case .failure(let err):
                                        print("Error: \(err)")
                                    }
                                }
                            }
                        }
                    }
                }
                if self.streamCategory == "film" {
                    completion(stream)
                }
            case .failure(let err):
                print("Error: \(err)")
                completion([:])
            }
        }
    }

    private func convertFromString(list: [String]) -> [String: String] {
        var qualityList: [String: String] = [:]
        let regex = try! NSRegularExpression(pattern: "\\[(.*?)\\]", options: [])
        for item in list {
            if let match = regex.firstMatch(in: item, options: [], range: NSRange(location: 0, length: item.utf16.count)) {
                if let range = Range(match.range(at: 1), in: item) {
                    let key = String(item[range])
                    let value = item.replacingOccurrences(of: "[\(key)]", with: "").trimmingCharacters(in: .whitespaces)
                    qualityList[key] = value
                }
            }
        }
        return qualityList
    }

    func isMovie() -> Bool {
        return streamCategory == "film"
    }

    private func decode(_ str: String) -> String {
        let tokens = [
            ":<:bzl3UHQwaWk0MkdXZVM3TDdB",
            ":<:SURhQnQwOEM5V2Y3bFlyMGVI",
            ":<:bE5qSTlWNVUxZ01uc3h0NFFy",
            ":<:Mm93S0RVb0d6c3VMTkV5aE54",
            ":<:MTluMWlLQnI4OXVic2tTNXpU"
        ]

        var clean = String(str.dropFirst(2))
        clean = clean.replacingOccurrences(of: "\\/", with: "/")

        while true {
            var modified = false
            for token in tokens {
                if clean.contains(token) {
                    clean = clean.replacingOccurrences(of: token, with: "")
                    modified = true
                }
            }
            if !modified { break }
        }

        if let data = Data(base64Encoded: clean) {
            return String(data: data, encoding: .utf8) ?? ""
        }
        return ""
    }
}
