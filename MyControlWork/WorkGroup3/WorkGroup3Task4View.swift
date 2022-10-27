//
//  ContentView.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 18.10.2022.
//

import SwiftUI

struct WorkGroup3Task4View: View {
    @State var textFromFile: String = ""
    @State var syntaxStatusMessage: NSAttributedString = .init()
    @State var isSelectingFile: Bool = false
    @State var selectedFile: URL?
    var stringValidator: SyntaxValidatorProtocol = SyntaxValidator()
    
    var body: some View {
        ScrollView{
            VStack {
                Spacer(minLength: 20)
                Text("Тема: Текстовые файлы\nЗадание 4\nДан текстовый файл F, содержащий программу на языке Pascal. Проверить эту программу на соответствие числа открывающих и закрывающих круглых скобок. Считать, что каждый оператор занимает не более одной строки файла, но в строке может быть несколько операторов.")
                    .multilineTextAlignment(.center)
                    .padding()
                if isSelectingFile == false{
                    if let selectedFile = selectedFile{
                        Text("Выбранный файл:\n\(selectedFile.absoluteString.removingPercentEncoding ?? "")")
                    }
                    
                    Button("Выбрать файл") {
                        isSelectingFile = true
                    }
                    .padding(.horizontal,10)
                    .padding(.vertical,10)
                    .background {
                        RoundedRectangle(cornerSize: .init(width: 15, height: 15))
                            .fill(.tint)
                    }.foregroundColor(.white)
                }
                Text(AttributedString(syntaxStatusMessage.string.isEmpty ? .init(string: "Ошибок нет"): syntaxStatusMessage))
                    .font(.subheadline)
                TextField(text: $textFromFile, axis: .vertical) {
                    Text("Или введите текст вручную")
                }
                .padding()
                .font(.system(size: 16))
                .overlay{
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
                }
                .onChange(of: textFromFile) { newValue in
                    var errorIndexes = stringValidator.validateStringRow(row: newValue, openSymbol: "(", closeSymbol: ")")
                    let errorIndexes2 = stringValidator.validateStringRow(row: newValue, openSymbol: "{", closeSymbol: "}")
                    let errorIndexes3 = stringValidator.validateStringRow(row: newValue, openSymbol: "<h1>", closeSymbol: "</h1>")
                    errorIndexes.append(contentsOf: errorIndexes2)
                    errorIndexes.append(contentsOf: errorIndexes3)
                    if errorIndexes.count > 0{
                        let attribString = NSMutableAttributedString(string: newValue)
                        for errorIndex in errorIndexes {
                            let attributes: [NSAttributedString.Key: Any] = [
                                .foregroundColor: UIColor.systemRed,
                                .underlineColor: UIColor.systemRed,
                                .underlineStyle: NSUnderlineStyle.single,
                                .font: UIFont.boldSystemFont(ofSize: 18),
                            ]
                            attribString.addAttributes(attributes, range: errorIndex)
                        }
                        
                        syntaxStatusMessage = attribString
                    } else {
                        syntaxStatusMessage = NSAttributedString(string: textFromFile)
                    }
                }
                Spacer(minLength: 20)
            }
            .padding()
        }.fileImporter(isPresented: $isSelectingFile, allowedContentTypes: [.text,.plainText,.delimitedText,.utf8PlainText,.utf8TabSeparatedText], onCompletion: { result in
            switch result{
            case .success(let url):
                
                FileReader.readFile(url: url) { readedData in
                    if let readedData = readedData{
                        guard let readedString = String(data: readedData, encoding: .utf8) else {
                            self.selectedFile = nil
                            return
                        }
                        textFromFile = readedString.trimmingCharacters(in: .whitespacesAndNewlines)
                        self.selectedFile = url
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        .navigationTitle("Задание 4")
    }
}

struct WorkGroup3Task4View_Previews: PreviewProvider {
    static var previews: some View {
        WorkGroup3Task4View()
    }
}
