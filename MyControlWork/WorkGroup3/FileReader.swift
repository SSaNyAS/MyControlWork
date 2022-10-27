//
//  FileReader.swift
//  MyControlWork
//
//  Created by Александр Шандыба on 21.10.2022.
//

import Foundation
class FileReader{
    static func readFile(url: URL, completion: @escaping (_ readedData: Data?) -> Void){
        DispatchQueue.global(qos: .background).async {
            guard let reader = try? FileHandle(forReadingFrom: url) else {
                completion(nil)
                return
            }
            reader.readabilityHandler = { fileInfo in
                completion(fileInfo.availableData)
                fileInfo.readabilityHandler = nil
            }
            reader.readInBackgroundAndNotify()
        }
    }
}
