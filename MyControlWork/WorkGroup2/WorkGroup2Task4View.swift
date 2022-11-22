//
//  WorkGroup2Task4View.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 21.10.2022.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct WorkGroup2Task4View: View {
    typealias booksStorageIOFileSupport = BookStorageProtocol & SaveReadFileProtocol
    @StateObject var bookCreator: BookCreator = BookCreator()
    var bookStorage: booksStorageIOFileSupport = BookMemoryStorage()
    @State var books: [Book] = []
    @State var selectedTaskId: Int = 0
    @State var tasks: [String] = ["Все книги","Задание a","Задание b"]
    @State var isSelectingYear: Bool = false
    
    @State var selectedYear:String = ""
    @State var isSelectingFileToRead: Bool = false
    @State var isSelectingFileToWrite: Bool = false
    @State var createdFileUrl: URL?
    @State var createdBook: Book?
    @State var file: File = .init(data: Data())
    
    var body: some View {
        ScrollView{
            Text("Дан файл КАТ, содержащий сведения о книгах:\n1)фамилия автора\n2)название\n3)год издания\n4)цена книги\na)распечатать записи с заданным годом издания, упорядоченные по алфавиту, а если таковых нет, то выдать соответствующее сообщение\nб)Отсортировать записи в порядке возрастания цены книги")
                .padding(.horizontal,0)
            
            if createdFileUrl != nil {
                Text("Файл создан по пути:\n" + createdFileUrl!.relativeString)
                    .padding(10)
            }

            HStack(spacing: 20){
                Button {
                    self.isSelectingFileToRead = true
                } label: {
                    Text("Чтение файла")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.accentColor)
                }
                Button {
                    bookCreator.isCreateBook = true
                } label: {
                    Text("Добавить книгу")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.accentColor)
                }
                Button {
                    bookStorage.exportData { data in
                        guard let fileData = data else {
                            return
                        }
                        createFileWithData(data: fileData)
                    }
                } label: {
                    Text("Запись в файл")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.accentColor)
                }
            }
            
            if selectedTaskId == 1{
                Button {
                    self.isSelectingYear = true
                } label: {
                    Text("Выбрать год издания")
                        .foregroundColor(.white)
                        .padding(10)
                }
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.accentColor)
                }
            } else {
                Text("Выбор задания")
                    .padding(.top,10)
            }
            Picker("", selection: $selectedTaskId) {
                ForEach(0..<tasks.count, id: \.self) { id in
                    Text(tasks[id])
                }
            }
            .animation(.spring(), value: selectedTaskId)
            .pickerStyle(.segmented)
            .onChange(of: selectedTaskId, perform: { newValue in
                getBooks()
            })
            
            List(books){ book in
                HStack{
                    Text("#\((books.firstIndex(where: {$0.id == book.id}) ?? 1) + 1)")
                        .font(.title2)
                        .foregroundColor(Color(.placeholderText))
                    Image(systemName: "book")
                        .resizable()
                        .frame(width: 20,height: 20)
                        .padding(.horizontal,5)
                    VStack(alignment: .leading, spacing: 5){
                        Text(book.name + " от " + book.releaseDate.shortFormat())
                            .font(.system(size: 14))
                        Text(book.author)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.lightGray))
                        Text("\(book.price)")
                            .font(.system(size: 14))
                        
                    }
                }
            }
            .frame(minHeight: UIScreen.main.bounds.height*0.5)
            .listStyle(.plain)
            .overlay(alignment: .center, content: {
                if books.count == 0 {
                    Text("Записи отсутствуют")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
            })
            .refreshable(action: {
                getBooks()
            })
            Spacer()
        }
        .onAppear(perform: {
            getBooks()
        })
        .navigationTitle("Задание 4")
        .padding()
        .alert("Введите год издания", isPresented: $isSelectingYear) {
            TextField(text: $selectedYear, axis: .vertical) {
                Text("год издания")
                    .foregroundColor(.init(uiColor: .placeholderText))
            }
            .textContentType(.dateTime)
            .keyboardType(.numberPad)
            Button("Найти") {
                getBooks()
            }
        }
        .alert("Добавление книги", isPresented: $bookCreator.isCreateBook) {
            VStack{
                textfieldWithPlaceholder(placeHolder: "Наименование книги", text: $bookCreator.name)
                textfieldWithPlaceholder(placeHolder: "Автор", text: $bookCreator.author)
                    .textContentType(.organizationName)
                TextField(value: $bookCreator.releaseDate, formatter: {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM.yyyy"
                    return dateFormatter
                }()) {
                    Text("Дата выпуска")
                        .foregroundColor(.init(uiColor: .placeholderText))
                }
                .textContentType(.dateTime)
                .keyboardType(.numbersAndPunctuation)
                
                TextField(value: $bookCreator.price, formatter: {
                    let formatter = NumberFormatter()
                    formatter.minimum = 0
                    formatter.textAttributesForNegativeValues = [NSAttributedString.Key.foregroundColor.rawValue: UIColor.red]
                    formatter.notANumberSymbol = "Укажите число"
                    formatter.zeroSymbol = ""
                    return formatter
                }()) {
                    Text("Цена")
                        .foregroundColor(.init(uiColor: .placeholderText))
                }
                .keyboardType(.numberPad)
                Button("Добавить") {
                    bookCreator.addBookToStorage(bookStorage: bookStorage)
                    getBooks()
                }
                
                Button {
                    
                } label: {
                    Text("Отмена")
                        .fontWeight(.bold)
                }
            }
        }
        .alert(item: $bookCreator.bookCreationError, content: { item in
            Alert(
                title: Text("Ошибка создания"),
                message: Text(item.errorDescription ?? "")
            )
        })
        .fileImporter(isPresented: $isSelectingFileToRead, allowedContentTypes: [.text,.utf8PlainText,.plainText,.utf8TabSeparatedText]) { result in
            switch result {
            case .success(let url):
                importBooksFromFile(url: url)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .fileExporter(isPresented: $isSelectingFileToWrite, document: file, contentType: .json) { result in
            switch result {
            case .success(let url):
                print("url")
                self.createdFileUrl = url
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    func textfieldWithPlaceholder(placeHolder: String, text: Binding<String>) -> some View{
        TextField(text: text, axis: .vertical){
            Text(placeHolder)
                .foregroundColor(.init(uiColor: .placeholderText))
        }
    }
    // получаем книги по условиям выбранного задания
    func getBooks(){
        let books = bookStorage.getAllBooks()
        self.books = []
        switch selectedTaskId{
        case 0:
            self.books = books
        case 1:
            // проверяем чтобы год был в виде числа
            guard let selectedYear = Int(selectedYear) else {
                return
            }
            let dateComponents = DateComponents(calendar: .current,timeZone: .gmt,year: selectedYear,month: 1,day: 1,hour: 0,minute: 0)
            let dateToSelectedYear = dateComponents.date
            guard let date = dateToSelectedYear else {
                return
            }
            // получаем книги с указанным годом и сортируем по алфавиту
            self.books = bookStorage.getBooksByReleaseYear(date: date).sorted(by: { book1, book2 in
                book1.name < book2.name
            })
        case 2:
            // сортируем книги по цене
            self.books = books.sorted(by: {
                $0.price < $1.price
            })
        default:
            break
        }
    }
    // в фоновом потоке асинхронно считываем данные с файла и пытаемся получить книги, если удалось то обновляем интерфейс
    func importBooksFromFile(url: URL){
        DispatchQueue.global(qos: .background).async {
            guard let data = try? Data(contentsOf: url) else {
                print("error to get data from file")
                return
            }
            bookStorage.readFromData(data: data) { isSuccess in
                if isSuccess{
                    print("success fill books from file")
                    getBooks()
                } else {
                    print("error to encode data from file")
                }
            }
        }
    }
    
    func createFileWithData(data: Data){
        let file = File(data: data)
        self.file = file
        self.isSelectingFileToWrite = true
    }
    
    class File: FileDocument{
        static var readableContentTypes: [UTType] = [.json]
        static var writableContentTypes: [UTType] = [.json]
        private let fileWrapper: FileWrapper?
        
        required init(configuration: ReadConfiguration) throws {
            fatalError("this file not readable")
        }
        // для выходного файла ставим имя по умолчанию в виде BooksData_дата с временем.json
        init(data: Data){
            self.fileWrapper = .init(regularFileWithContents: data)
            self.fileWrapper?.preferredFilename = "BooksData_\(Date().shortFormatWithTime()).json"
        }
        
        func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
            guard let fileWrapper = self.fileWrapper else {
                throw NSFileProviderError.init(.noSuchItem)
            }
            return fileWrapper
        }
        
    }
}




struct WorkGroup2Task4View_Previews: PreviewProvider {
    static var previews: some View {
        WorkGroup2Task4View()
    }
}
