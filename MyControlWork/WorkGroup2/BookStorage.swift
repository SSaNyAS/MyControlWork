//
//  BookStorage.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 22.10.2022.
//

import Foundation
// Интерфейс для реализации хранилища книг, можно легко менять вид хранилища данных
protocol BookStorageProtocol{
    var booksCount: Int{ get }
    func getAllBooks() -> [Book]
    func getBooksByAuthor(author: String) -> [Book]
    func getBooksByName(name: String) -> [Book]
    func getBooksByReleaseYear(date: Date) -> [Book]
    func getBooksByReleaseDate(intervalStart: Date, intervalEnd: Date) -> [Book]
    func getBooksByPrice(price: UInt64) -> [Book]
    func getBooksByPriceInterval(priceStart: UInt64?, priceEnd: UInt64?) -> [Book]
    func getFirstBookByName(name: String) -> Book?
    func addNewBook(book: Book) -> Bool
    func contains(bookId: String) -> Bool
}
// Интерфейс для поддержки экспорта данных и чтения с них
protocol SaveReadFileProtocol{
    func exportData(completion: @escaping (_ data: Data?) -> Void)
    func readFromData(data: Data, completion: @escaping (_ isSuccess: Bool) -> Void)
}
// Создаем простое хранилище книг в памяти
class BookMemoryStorage{
    var books: [String : Book] = [
        "1": Book(id: "1",name: "Swift для начинающих часть 1", releaseDate: Date().addingTimeInterval(-(60*60*24*385*4)), price: 1000, author: "Автор 1"),
        "2": Book(id: "2",name: "Swift 2.4", releaseDate: Date().addingTimeInterval(-(60*60*24*340*3)), price: 1500, author: "Иван"),
        "3": Book(id: "3",name: "Swift 4.2", releaseDate: Date().addingTimeInterval(-(60*60*24*320*2)), price: 1200, author: "Николай"),
        "4": Book(id: "4",name: "Swift 5.7", releaseDate: Date().addingTimeInterval(-(60*60*24*240)), price: 1600, author: "Автор 4"),
    ]
    // добавляем в словарь по ключу id книги саму книгу
    func setBooks(array: [Book]){
        self.books = [:]
        for book in array{
            books[book.id] = book
        }
    }
}
// расширяем хранилище для поддержки записи данных в файл ( или отправку на сервер) и чтения из него
extension BookMemoryStorage: SaveReadFileProtocol{
    // В фоновом потоке переносим данные с обьектов в json и возвращаем в замыкание данные в виде json
    func exportData(completion: @escaping (Data?) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {
                return
            }
            let encodedBooks = try? JSONEncoder().encode(Array(self.books.values))
            completion(encodedBooks)
        }
    }
    // пытаемся получить обьекты из json массива и если успешно то ставим их в хранилище
    func readFromData(data: Data, completion: @escaping (Bool) -> Void) {
        guard let books = try? JSONDecoder().decode([Book].self, from: data) else {
            completion(false)
            return
        }
        setBooks(array: books)
        completion(true)
    }
}
// Добавляем хранилищу взаимодействие с данными и возможность выборки
extension BookMemoryStorage: BookStorageProtocol{
    var booksCount: Int{
        return books.count
    }
    // получаем все книги
    func getAllBooks() -> [Book] {
        return Array(books.values)
    }
    // добавляем новую книгу если книги с таким идентификатором не существует
    func addNewBook(book: Book) -> Bool {
        let isContains = self.contains(bookId: book.id)
        if isContains == false{
            books.updateValue(book, forKey: book.id)
        }
        return !isContains
    }
    // проверка на существование книги по идентификатору
    func contains(bookId: String) -> Bool {
        let isContains = books[bookId] != nil
        return isContains
    }
    // получение книг указанного автора
    func getBooksByAuthor(author: String) -> [Book] {
        let authorLowercased = author.lowercased()
        let booksFiltered = books.filter { book in
            book.value.author.lowercased().contains(authorLowercased)
        }
        return Array(booksFiltered.values)
    }
    // получение книг по наименованию
    func getBooksByName(name: String) -> [Book] {
        let nameLowercased = name.lowercased()
        let booksFiltered = books.filter { book in
            book.value.name.lowercased().contains(nameLowercased)
        }
        return Array(booksFiltered.values)
    }
    // получение книг по году издания
    func getBooksByReleaseYear(date: Date) -> [Book] {
        let booksFiltered = books.filter { book in
            let bookDate = book.value.releaseDate
            return Calendar.current.compare(bookDate, to: date, toGranularity: .year) == .orderedSame
        }
        return Array(booksFiltered.values)
    }
    // Получение книг с датой издания в указанном диапазоне
    func getBooksByReleaseDate(intervalStart: Date, intervalEnd: Date) -> [Book] {
        let dateComponents1 = Calendar.current.dateComponents(needsComponents, from: intervalStart)
        let dateComponents2 = Calendar.current.dateComponents(needsComponents, from: intervalEnd)
        let dateWithoutHours1 = dateComponents1.date
        let dateWithoutHours2 = dateComponents2.date
        
        let booksFiltered = books.filter { book in
            let bookReleaseDate = book.value.releaseDate
            return (bookReleaseDate >= dateWithoutHours1 ?? intervalStart) && (bookReleaseDate <= dateWithoutHours2 ?? intervalEnd)
        }
        return Array(booksFiltered.values)
    }
    // Получение книг по цене
    func getBooksByPrice(price: UInt64) -> [Book] {
        let booksFiltered = books.filter { book in
            book.value.price == price
        }
        return Array(booksFiltered.values)
    }
    // Получение книг по диапазону цены
    func getBooksByPriceInterval(priceStart: UInt64?, priceEnd: UInt64?) -> [Book] {
        let booksFiltered = books.filter { book in
            let bookPrice = book.value.price
            return (bookPrice >= priceStart ?? 0) && (bookPrice <= priceEnd ?? .max)
        }
        return Array(booksFiltered.values)
    }
    // возращает первую книгу которая содержит указанное слово (независимо от регистра)
    func getFirstBookByName(name: String) -> Book? {
        let nameLowercased = name.lowercased()
        let bookFiltered = books.first { book in
            book.value.name.lowercased() == nameLowercased
        }
        return bookFiltered?.value
    }
}

// Создаем обьект книги с уникальным идентификатором, необходимыми полями и реализуем инициализацию из json и запись в него
struct Book: Identifiable, Codable, Hashable{
    let id: String
    let name: String
    let releaseDate: Date
    let price: UInt64
    let author: String
    
    init(id: String, name: String, releaseDate: Date, price: UInt64, author: String) {
        self.id = id
        self.name = name
        
        let dateComponents = Calendar.current.dateComponents(needsComponents, from: releaseDate)
        let dateFromComponents = dateComponents.date
        self.releaseDate = dateFromComponents ?? releaseDate
        self.price = price
        self.author = author
    }
    // инициализатор в который можно передать метод который проверяет идентификатор на уникальность
    init(name: String, releaseDate: Date, price: UInt64, author: String, idValidator: ((_ id: String) -> Bool)? = nil) {
        var id = UUID().uuidString
        if let idValidator = idValidator{
            while idValidator(id) != true{
                id = UUID().uuidString
            }
        }
        self.id = id
        self.name = name
        
        let dateComponents = Calendar.current.dateComponents(needsComponents, from: releaseDate)
        let dateFromComponents = dateComponents.date
        self.releaseDate = dateFromComponents ?? releaseDate
        self.price = price
        self.author = author
    }
    // добавляем поддержку хеширования для удобной работы с различными видами коллекций
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        let releaseDateComponents = Calendar.current.dateComponents(needsComponents, from: releaseDate)
        // записываем в json дату в виде День.Месяц.Год
        guard let releaseDateTruncated = Calendar.current.date(from: releaseDateComponents) else {
            throw EncodingError.invalidValue(releaseDateComponents.date as Any, .init(codingPath: [CodingKeys.releaseDate], debugDescription: ""))
        }
        try container.encode(releaseDateTruncated, forKey: .releaseDate)
        try container.encode(self.price, forKey: .price)
        try container.encode(self.author, forKey: .author)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        self.price = try container.decode(UInt64.self, forKey: .price)
        self.author = try container.decode(String.self, forKey: .author)
    }
    // ключи по которым храняться данные в json
    enum CodingKeys: CodingKey {
        case id
        case name
        case releaseDate
        case price
        case author
    }
}
private let needsComponents: Set<Calendar.Component> = [.year,.month,.day]
