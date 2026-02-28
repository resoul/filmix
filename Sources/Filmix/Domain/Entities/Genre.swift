import Foundation

public struct Genre {
    public let title: String
    public let url: String

    public init(title: String, url: String) {
        self.title = title; self.url = url
    }

    public static let movies: [Genre] = [
        Genre(title: "Аниме",          url: "https://filmix.my/film/animes/"),
        Genre(title: "Биография",      url: "https://filmix.my/film/biografia/"),
        Genre(title: "Боевики",        url: "https://filmix.my/film/boevik/"),
        Genre(title: "Вестерн",        url: "https://filmix.my/film/vesterny/"),
        Genre(title: "Военный",        url: "https://filmix.my/film/voennyj/"),
        Genre(title: "Детектив",       url: "https://filmix.my/film/detektivy/"),
        Genre(title: "Детский",        url: "https://filmix.my/film/detskij/"),
        Genre(title: "Для взрослых",   url: "https://filmix.my/film/for_adults/"),
        Genre(title: "Документальные", url: "https://filmix.my/film/dokumentalenyj/"),
        Genre(title: "Драмы",          url: "https://filmix.my/film/drama/"),
        Genre(title: "Исторический",   url: "https://filmix.my/film/istoricheskie/"),
        Genre(title: "Комедии",        url: "https://filmix.my/film/komedia/"),
        Genre(title: "Короткометражка",url: "https://filmix.my/film/korotkometragka/"),
        Genre(title: "Криминал",       url: "https://filmix.my/film/kriminaly/"),
        Genre(title: "Мелодрамы",      url: "https://filmix.my/film/melodrama/"),
        Genre(title: "Мистика",        url: "https://filmix.my/film/mistika/"),
        Genre(title: "Музыка",         url: "https://filmix.my/film/music/"),
        Genre(title: "Мюзикл",         url: "https://filmix.my/film/muzkl/"),
        Genre(title: "Приключения",    url: "https://filmix.my/film/prikluchenija/"),
        Genre(title: "Семейный",       url: "https://filmix.my/film/semejnye/"),
        Genre(title: "Спорт",          url: "https://filmix.my/film/sports/"),
        Genre(title: "Триллеры",       url: "https://filmix.my/film/triller/"),
        Genre(title: "Ужасы",          url: "https://filmix.my/film/uzhasu/"),
        Genre(title: "Фантастика",     url: "https://filmix.my/film/fantastiks/"),
        Genre(title: "Фэнтези",        url: "https://filmix.my/film/fjuntezia/"),
    ]

    public static let series: [Genre] = [
        Genre(title: "Аниме",          url: "https://filmix.my/seria/animes/s7/"),
        Genre(title: "Биография",      url: "https://filmix.my/seria/biografia/s7/"),
        Genre(title: "Боевики",        url: "https://filmix.my/seria/boevik/s7/"),
        Genre(title: "Вестерн",        url: "https://filmix.my/seria/vesterny/s7/"),
        Genre(title: "Военный",        url: "https://filmix.my/seria/voennyj/s7/"),
        Genre(title: "Детектив",       url: "https://filmix.my/seria/detektivy/s7/"),
        Genre(title: "Детский",        url: "https://filmix.my/seria/detskij/s7/"),
        Genre(title: "Для взрослых",   url: "https://filmix.my/seria/for_adults/s7/"),
        Genre(title: "Документальные", url: "https://filmix.my/seria/dokumentalenyj/s7/"),
        Genre(title: "Дорамы",         url: "https://filmix.my/seria/dorama/s7/"),
        Genre(title: "Драмы",          url: "https://filmix.my/seria/drama/s7/"),
        Genre(title: "Игра",           url: "https://filmix.my/seria/game/s7/"),
        Genre(title: "Исторический",   url: "https://filmix.my/seria/istoricheskie/s7/"),
        Genre(title: "Комедии",        url: "https://filmix.my/seria/komedia/s7/"),
        Genre(title: "Криминал",       url: "https://filmix.my/seria/kriminaly/s7/"),
        Genre(title: "Мелодрамы",      url: "https://filmix.my/seria/melodrama/s7/"),
        Genre(title: "Мистика",        url: "https://filmix.my/seria/mistika/s7/"),
        Genre(title: "Мюзикл",         url: "https://filmix.my/seria/muzkl/s7/"),
        Genre(title: "Приключения",    url: "https://filmix.my/seria/prikluchenija/s7/"),
        Genre(title: "Семейный",       url: "https://filmix.my/seria/semejnye/s7/"),
        Genre(title: "Ситком",         url: "https://filmix.my/seria/sitcom/s7/"),
        Genre(title: "Триллеры",       url: "https://filmix.my/seria/triller/s7/"),
        Genre(title: "Ужасы",          url: "https://filmix.my/seria/uzhasu/s7/"),
        Genre(title: "Фантастика",     url: "https://filmix.my/seria/fantastiks/s7/"),
        Genre(title: "Фэнтези",        url: "https://filmix.my/seria/fjuntezia/s7/"),
    ]

    public static let cartoons: [Genre] = [
        Genre(title: "Аниме",          url: "https://filmix.my/mults/animes/s14/"),
        Genre(title: "Биография",      url: "https://filmix.my/mults/biografia/s14/"),
        Genre(title: "Боевики",        url: "https://filmix.my/mults/boevik/s14/"),
        Genre(title: "Вестерн",        url: "https://filmix.my/mults/vesterny/s14/"),
        Genre(title: "Военный",        url: "https://filmix.my/mults/voennyj/s14/"),
        Genre(title: "Детектив",       url: "https://filmix.my/mults/detektivy/s14/"),
        Genre(title: "Детский",        url: "https://filmix.my/mults/detskij/s14/"),
        Genre(title: "Для взрослых",   url: "https://filmix.my/mults/for_adults/s14/"),
        Genre(title: "Документальные", url: "https://filmix.my/mults/dokumentalenyj/s14/"),
        Genre(title: "Драмы",          url: "https://filmix.my/mults/drama/s14/"),
        Genre(title: "Исторический",   url: "https://filmix.my/mults/istoricheskie/s14/"),
        Genre(title: "Комедии",        url: "https://filmix.my/mults/komedia/s14/"),
        Genre(title: "Криминал",       url: "https://filmix.my/mults/kriminaly/s14/"),
        Genre(title: "Мелодрамы",      url: "https://filmix.my/mults/melodrama/s14/"),
        Genre(title: "Мистика",        url: "https://filmix.my/mults/mistika/s14/"),
        Genre(title: "Музыка",         url: "https://filmix.my/mults/music/s14/"),
        Genre(title: "Мюзикл",         url: "https://filmix.my/mults/muzkl/s14/"),
        Genre(title: "Приключения",    url: "https://filmix.my/mults/prikluchenija/s14/"),
        Genre(title: "Семейный",       url: "https://filmix.my/mults/semejnye/s14/"),
        Genre(title: "Спорт",          url: "https://filmix.my/mults/sports/s14/"),
        Genre(title: "Триллеры",       url: "https://filmix.my/mults/triller/s14/"),
        Genre(title: "Ужасы",          url: "https://filmix.my/mults/uzhasu/s14/"),
        Genre(title: "Фантастика",     url: "https://filmix.my/mults/fantastiks/s14/"),
        Genre(title: "Фэнтези",        url: "https://filmix.my/mults/fjuntezia/s14/"),
    ]
}
