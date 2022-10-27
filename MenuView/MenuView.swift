//
//  MenuView.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 21.10.2022.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 10){
                navigationLinkSetupped(title: "1. Строковый тип", destination: WorkGroup1Task4())
                navigationLinkSetupped(title: "2. Типизированные типы", destination: WorkGroup2Task4View())
                navigationLinkSetupped(title: "3. Текстовые файлы", destination: WorkGroup3Task4View())
                navigationLinkSetupped(title: "4. Модульное программирование", destination: EmptyView())
                navigationLinkSetupped(title: "5. Динамические структуры данных", destination: EmptyView())
                navigationLinkSetupped(title: "6. ASCIIZ - строки (строки с нулевым окончанием)", destination: EmptyView())
                navigationLinkSetupped(title: "8?. Рекурсивные алгоритмы", destination: EmptyView())
            }
            .padding()
        }
    }
    
    
    func navigationLinkSetupped(title:String ,destination: some View) -> some View {
        return NavigationLink(destination: destination) {
            Text(title)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical,10)
        .padding(.horizontal,10)
        .background{
            RoundedRectangle(cornerSize: .init(width: 15, height: 15))
                .fill(.tint)
        }
        .foregroundColor(.white)
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
