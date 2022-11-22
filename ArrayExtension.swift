//
//  ArrayExtension.swift
//  
//
//  Created by Александр Шандыба on 07.11.2022.
//
import Foundation

//Расширяем Коллекцию где элементами являются числа и добавляем эти методы
public extension Collection where Element: Numeric{
    // просто проходимся по всем элементам и суммируем ( начальное значение 0)
    func customSum() -> Element {
        var sum = Element.zero
        
        self.forEach { item in
            sum += item
        }
        return sum
    }
    // просто проходимся по всем элементам и перемножаем ( начальное значение 1, чтобы не влиять на результат)
    func customMultiply() -> Element{
        var result: Element = 1
        
        self.forEach { item in
            result *= item
        }
        return result
    }
}

//Расширяем Коллекцию где элементами являются обьекты которые можно сравнивать
public extension Collection where Element: Comparable{
    
    // самая простая реализация поиска минимального числа, где сначала мы минимальным делаем первое число а затем сравниваем остальные с минимальным и если они меньше, то перезаписываем минимальное
    func customMin() -> Element?{
        var min = first
        
        forEach { item in
            if min == nil {
                min = item
            }
            
            if item < min!  {
                min = item
            }
        }
        return min
    }
    // самая простая реализация поиска максимального числа, где сначала мы максимальным делаем первое число а затем сравниваем остальные с максимальным и если они больше, то перезаписываем максимальное
    func customMax() -> Self.Element?{
        var max = first
        
        forEach { item in
            if max == nil {
                max = item
            }
            
            if item > max!  {
                max = item
            }
        }
        return max
    }
    
    func customQuickSort(by compareFunc: @escaping (Self.Element, Self.Element) -> Bool) -> [Self.Element]{
        guard let pivotItem: Self.Element = first else {
            return []
        }
        if count == 1{
            return [pivotItem]
        }
        
        var leftArray: [Self.Element] = []
        leftArray.reserveCapacity(count)
        var rightArray: [Self.Element] = []
        rightArray.reserveCapacity(count)
        var equalsArray: [Self.Element] = []
        equalsArray.reserveCapacity(count)
        
        for (_, item) in self.enumerated(){
            let compareResult = compareFunc(pivotItem,item)
            if compareResult{
                leftArray.append(item)
            } else if item == pivotItem {
                equalsArray.append(item)
            } else {
                rightArray.append(item)
            }
        }
        let leftSorted = leftArray.customQuickSort(by: compareFunc)
        let rightSorted = rightArray.customQuickSort(by: compareFunc)
        return leftSorted + equalsArray + rightSorted
    }
    
    
}
// расширяем коллекцию содержащую любые обьекты
public extension Collection{
    
    // Используется словарь для добавления соотвествующих предикату элементов
    // поскольку он имеет константное время при добавлении элемента О(1)
    // для этого мы резервируем место в памяти на количество элементов в коллекции (больше этого количества быть не может)
    
    // если обьект подходит по условию то добавляем его в словарь а затем возвращаем словарь где находятся обьекты подходящие по условию
    func customFilter(_ filter: @escaping (Self.Element) -> Bool ) -> [Self.Element]{
        var dict: [String:Self.Element] = [:]
        dict.reserveCapacity(self.count)
        
        var itemId = 0
        forEach { item in
            let isFiltered = filter(item)
            
            if isFiltered {
                dict.updateValue(item, forKey: "\(itemId)")
            }
            
            itemId += 1;
        }
        return Array(dict.values)
    }
    
    func isSorted(by compareFunc: @escaping (Self.Element, Self.Element) -> Bool) -> Bool{
        var isSorted = true
        // проверяем есть ли с чем сравнивать обьекты
        guard self.count > 1 else {
            return true
        }
        var prevElement: Self.Element?
        // проверяем если предыдущий элемент пустой то мы в него ставим первый элемент
        // и проверям подходит ли наш элемент по функции сравнивания если да то проверяем следующий и так далее
        // если хоть один элемент не отсортирован то дальнейшие проверки не влияют на результат( вообще лучше сделать сразу выход из функции)
        forEach { item in
            if prevElement == nil {
                prevElement = item
            } else {
                isSorted = isSorted && compareFunc(prevElement!,item)
                prevElement = item
            }
        }
        return isSorted
    }
}
// Создаем интерфейс для вектора с 2 осями
protocol Vector2DProtocol{
    var x: Double{get set}
    var y: Double{get set}
}

// Добавляем ему базовую реализацию сравнивания и умножения
extension Vector2DProtocol{
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func * (lhs: Self, rhs: Self) -> Double{
        return lhs.x * rhs.x + lhs.y * rhs.y
    }
}

// Создаем интерфейс для вектора с 3 осями наследуя при этом все возможности векторов с 2 осями и добавляем ему еще одну ось.
// Это позволит использовать вектор с 3 осями как вектор с 2 осями
protocol Vector3DProtocol: Vector2DProtocol{
    var z: Double{get set}
}

// Добавляем ему базовую реализацию сравнивания и умножения
extension Vector3DProtocol{
    static func == (lhs: Self, rhs: Self) -> Bool{
        lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    static func * (lhs: Self, rhs: Self) -> Double{
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    }
}

// Реализуем интерфейс вектора с 2 осями
struct Vector2D: Vector2DProtocol{
    var x: Double
    var y: Double
}

// Реализуем интерфейс вектора с 3 осями
struct Vector3D: Vector3DProtocol{
    var x: Double
    var y: Double
    var z: Double
}


