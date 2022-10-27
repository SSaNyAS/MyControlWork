//
//  WorkGroup1Task4.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 27.10.2022.
//

import SwiftUI

struct WorkGroup1Task4: View {
    @State var text: String = ""
    @State var resultText: String = ""
    
    var body: some View {
        ScrollView{
            Text("1. Дана последовательность, содержащая от 2 до 30 слов, в каждом из которых от 2 до 10 латинских букв; между соседними словами - не менее одного пробела, за последним словом точка. Напечатать все слова, отличные от последнего слова, предварительно преобразовав каждое из них по следующему правилу:\n4. Условие задачи 1:\n-удалить из слова все последующие вхождения первой буквы.")
                .padding(5)
            
            TextField(text: $text, axis: .vertical) {
                Text("Введите текст")
            }
            .padding()
            .font(.system(size: 16))
            .overlay{
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(style: .init(lineWidth: 1, lineCap: .round, lineJoin: .round))
            }
            .onChange(of: text) { newValue in
                let words = newValue.components(separatedBy: .whitespaces)
                let wordsResulted = words.map { word in
                    if word.hasSuffix("."){
                        return word
                    }
                    guard let firstChar = word.first else {
                        return word
                    }
                    var wordCopy = word
                    wordCopy.removeAll(where: {
                        $0 == firstChar
                    })
                    wordCopy.insert(firstChar, at: wordCopy.startIndex)
                    return wordCopy
                }
                resultText = wordsResulted.joined(separator: " ")
            }
            Divider()
            Text(resultText)
                .padding(5)
                .padding(.vertical,10)
        }
        .padding()
    }
}

struct WorkGroup1Task4_Previews: PreviewProvider {
    static var previews: some View {
        WorkGroup1Task4()
    }
}
