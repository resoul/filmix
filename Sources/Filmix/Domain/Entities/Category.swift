import Foundation

public struct Category {
    public let title: String
    public let url: String
    public let icon: String
    public let kind: Kind
    public var genres: [Genre]

    public init(title: String, url: String, icon: String, kind: Kind, genres: [Genre]) {
        self.title = title; self.url = url; self.icon = icon
        self.kind = kind; self.genres = genres
    }

    public enum Kind {
        case regular
        case favorites
        case watchHistory
        case search
    }

    public static let all: [Category] = [
        Category(title: "Главная",     url: "https://filmix.my",          icon: "house.fill",       kind: .regular,      genres: []),
        Category(title: "Фильмы",      url: "https://filmix.my/film/",    icon: "film.fill",         kind: .regular,      genres: Genre.movies),
        Category(title: "Сериалы",     url: "https://filmix.my/seria/",   icon: "tv.fill",           kind: .regular,      genres: Genre.series),
        Category(title: "Мультфильмы", url: "https://filmix.my/mults/",   icon: "sparkles.tv.fill",  kind: .regular,      genres: Genre.cartoons),
        Category(title: "Избранное",   url: "",                           icon: "star.fill",         kind: .favorites,    genres: []),
        Category(title: "Смотрю",      url: "",                           icon: "play.circle.fill",  kind: .watchHistory, genres: []),
    ]
}
