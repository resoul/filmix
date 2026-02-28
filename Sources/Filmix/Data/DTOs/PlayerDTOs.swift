import Foundation

// MARK: - Player API Response DTOs

public struct PlayerResponseDTO: Codable {
    let type: String
    let message: PlayerMessageDTO
}

public struct PlayerMessageDTO: Codable {
    let translations: TranslationsDTO
}

public struct TranslationsDTO: Codable {
    let video: [String: String]
}

// MARK: - Series Player DTOs

public struct SerialDTO: Codable {
    let title: String
    let folder: [FolderDTO]
}

public struct FolderDTO: Codable {
    let title: String
    let id: String
    let file: String
}

// MARK: - Search Suggestions DTOs (unused in listing flow but kept for completeness)

public struct SuggestionsResponseDTO: Decodable {
    let posts: [SuggestionPostDTO]
}

public struct SuggestionPostDTO: Decodable {
    let id: Int
    let title: String
    let year: Int
    let link: String
    let poster: String
    let last_serie: String
    let categories: String
    let letter: String
}
