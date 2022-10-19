//
//  ContentView.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 18.10.2022.
//

import SwiftUI

struct ContentView: View {
    @State var textFromFile: String = ""
    @State var syntaxStatusMessage: NSAttributedString = .init()
    var stringValidator: SyntaxValidator = .init()
    
    var body: some View {
        ScrollView{
            VStack {
                Spacer(minLength: 20)
                Image(systemName: "swift")
                    .resizable()
                    .padding(.bottom, 50)
                    .frame(width: 200, height: 200)
                    .foregroundColor(.accentColor)
                
                Text(AttributedString(syntaxStatusMessage.string.isEmpty ? .init(string: "Ошибок нет"): syntaxStatusMessage))
                    .font(.subheadline)
                TextField(text: $textFromFile, axis: .vertical) {
                    Text("Введите текст")
                        .foregroundColor(Color(.placeholderText))
                }
                .font(.system(size: 16))
                .frame(minHeight: 100)
                .background{
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
                }
                .onChange(of: textFromFile) { newValue in
                    var errorIndexes = stringValidator.validateStringRow(row: newValue, openSymbol: "(", closeSymbol: ")")
                    let errorIndexes2 = stringValidator.validateStringRow(row: newValue, openSymbol: "{", closeSymbol: "}")
                    let errorIndexes3 = stringValidator.validateStringRow(row: newValue, openSymbol: "begin", closeSymbol: "end")
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
