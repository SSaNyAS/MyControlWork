//
//  WorkGroup4Task12.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 06.11.2022.
//

import SwiftUI


struct WorkGroup4Task12: View {
    var testArray: [Int] = [
        1,
        5,
        2,
        5,
        7,
        8,
        9,
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            List{
                // везде используются методы написанные в расширении базовой коллекции
                // где $0 - это текущий элемент, а $1 - следующий
                // файл где написан весь код ArrayExtension.swift
                
                Section("sum, multiply, max, min (using test array)") {
                    Text("sum: \(String(describing: testArray.customSum()))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text("multiply:\(String(describing: testArray.customMultiply()))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text("max:\(String(describing: testArray.customMax()))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text("min:\(String(describing: testArray.customMin()))")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                }
                Section("Filter (using test array)") {
                    Text("filter by item % 2 == 0\n" + "\(testArray.customFilter({$0 % 2 == 0}))")
                        .font(.title2)
                }
                
                Section("Vectors Scalar 2D"){
                    let vector1 = Vector2D(x: 7, y: -4)
                    let vector2 = Vector2D(x: -8, y: 6)
                    let scalar = vector1 * vector2
                    Text("Vector 1: \(String(describing: vector1))")
                    Text("Vector 2: \(String(describing: vector2))")
                    // убираем лишние знаки после запятой сокращая их до 2 символов
                    Text("Scalar: \(String(format: "%.2f", scalar))")
                }
                
                Section("Vectors Scalar 3D"){
                    let vector1 = Vector3D(x: 7, y: -4, z: 3)
                    let vector2 = Vector3D(x: -8, y: 6, z: -5)
                    let scalar = vector1 * vector2
                    Text("Vector 1: \(String(describing: vector1))")
                    Text("Vector 2: \(String(describing: vector2))")
                    
                    Text("Scalar: \(String(format: "%.2f", scalar))")
                }
                
                Section("Sorting") {
                    Text("Array\n\(testArray)\nisSorted by asc = "+"\(testArray.isSorted(by: {$0 <= $1}))\nisSorted by desc = \(testArray.isSorted(by: {$0 >= $1}))")
                        .font(.title2)
                    
                    let sortedAsc = testArray.sorted(by: {$0 < $1})
                    Text("Array\n\(sortedAsc)\nisSorted by asc = "+"\(sortedAsc.isSorted(by: {$0 <= $1}))")
                        .font(.title2)
                    
                    let sortedDesc = testArray.sorted(by: {$0 > $1})
                    Text("Array\n\(sortedDesc)\nisSorted by desc = "+"\(sortedDesc.isSorted(by: {$0 >= $1}))")
                        .font(.title2)
                        
                    
                    let customSortedASC = testArray.customQuickSort(by: {$0 < $1})
                    Text("Array with custom sort\n\(customSortedASC)\nisSorted by desc = "+"\(customSortedASC.isSorted(by: {$0 >= $1}))")
                        .font(.title2)
                    
                    let customSortedDESC = testArray.customQuickSort(by: {$0 > $1})
                    Text("Array with custom sort\n\(customSortedDESC)\nisSorted by asc = "+"\(customSortedDESC.isSorted(by: {$0 <= $1}))")
                        .font(.title2)
                }
                
            }
            .padding(.top,100)
            .overlay(alignment: .top) {
                Text("test array: \n\(String(describing: testArray))\n")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .background(.background)
            }
        }
        
    }
}

struct WorkGroup4Task12_Previews: PreviewProvider {
    static var previews: some View {
        WorkGroup4Task12()
    }
}
