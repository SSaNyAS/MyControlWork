//
//  BookCreatorViewModel.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 05.11.2022.
//

import SwiftUI
// перечисление с видами ошибок при создании книги
enum BookCreationError: Identifiable, LocalizedError{
    var id: String{
        return self.errorDescription ?? UUID().uuidString
    }
    case emptyName
    case emptyAuthor
    case bookIsExist
    
    var errorDescription: String?{
        switch self {
        case .emptyName:
            return "Укажите название книги"
        case .emptyAuthor:
            return "Укажите автора книги"
        case .bookIsExist:
            return "Книга с таким идентификатором уже существует"
        }
    }
}

// Обьект использующийся для постепенного построения обьекта книги (паттерн Builder)
// Теги перед переменными используются для поддержки Key-Value Observing (т.е чтобы приложение знало что эти значения изменились и необходимо перерисовать интерфейс)
class BookCreator: Identifiable, ObservableObject{
    let id = UUID()
    @Published var isCreateBook: Bool = false
    @Published var bookCreationError: BookCreationError?
    
    @Published var name: String = ""
    @Published var author: String = ""
    @Published var releaseDate: Date = Date()
    @Published var price: UInt64 = 0
    
    // пытаемся получить книгу, а если не получается получаем ошибку
    func getValidBook() -> Book?{
        guard !name.isEmpty else {
            bookCreationError = .emptyName
            return nil
        }
        
        guard !author.isEmpty else {
            bookCreationError = .emptyAuthor
            return nil
        }
        
        return Book(name: name, releaseDate: releaseDate, price: price, author: author)
    }
    
    func clearData(){
        name = ""
        author = ""
        releaseDate = Date()
        price = 0
    }
    // если книгу удалось собрать из необходимых данных то
    // Добавляем книгу в указанное хранилище и очищаем поля для ввода
    func addBookToStorage(bookStorage: BookStorageProtocol){
        guard let book = getValidBook() else {
            return
        }
        let isSuccess = bookStorage.addNewBook(book: book)
        
        if isSuccess == false{
            bookCreationError = .bookIsExist
            return
        }
        clearData()
    }
}
