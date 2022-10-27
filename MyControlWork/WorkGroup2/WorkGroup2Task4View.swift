//
//  WorkGroup2Task4View.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 21.10.2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct WorkGroup2Task4View: View {
    var bookStorage: BookStorageProtocol & SaveReadFileProtocol = BookMemoryStorage()
    @State var books: [Book] = []
    @State var selectedTaskId: Int = 0
    @State var tasks: [String] = ["Все книги","Задание a","Задание b"]
    @State var isSelectingYear: Bool = false
    @State var selectedYear:String = ""
    @State var isSelectingFileToRead: Bool = false
    @State var isSelectingFileToWrite: Bool = false
    @State var createdFileUrl: URL?
    @State var file: File = .init(data: Data())
    var body: some View {
        ScrollView{
            Text("Дан файл КАТ, содержащий сведения о книгах:\n1)фамилия автора\n2)название\n3)год издания\n4)цена книги\na)распечатать записи с заданным годом издания, упорядоченные по алфавиту, а если таковых нет, то выдать соответствующее сообщение\nб)Отсортировать записи в порядке возрастания цены книги")
                .padding(.horizontal,0)
            
            if createdFileUrl != nil {
                Text(createdFileUrl!.relativeString)
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
                //self.isSelectingYear = selectedTaskId == 1
                getBooks()
            })
            
            List(books){ book in
                HStack{
                    Text("#\(books.firstIndex(where: {$0.id == book.id}) ?? 1)")
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
        .fileImporter(isPresented: $isSelectingFileToRead, allowedContentTypes: [.text,.utf8PlainText,.plainText,.utf8TabSeparatedText]) { result in
            switch result {
            case .success(let url):
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
        
    }
    
    func getBooks(){
        let books = bookStorage.getAllBooks()
        self.books = []
        switch selectedTaskId{
        case 0:
            self.books = books
        case 1:
            guard let selectedYear = Int(selectedYear) else {
                return
            }
            let dateComponents = DateComponents(calendar: .current,timeZone: .gmt,year: selectedYear,month: 1,day: 1,hour: 0,minute: 0)
            let dateToSelectedYear = dateComponents.date
            guard let date = dateToSelectedYear else {
                return
            }
            self.books = bookStorage.getBooksByReleaseYear(date: date).sorted(by: { book1, book2 in
                book1.name < book2.name
            })
        case 2:
            self.books = books.sorted(by: {
                $0.price < $1.price
            })
        default:
            break
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
