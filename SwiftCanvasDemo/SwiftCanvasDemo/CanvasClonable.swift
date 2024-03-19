//
//  CanvasClonable.swift
//  SwiftCanvasDemo
//
//  Created by Andre Pham on 19/3/2024.
//

import Foundation

public protocol CanvasClonable {

    init(_ original: Self)
    
}
extension CanvasClonable {
    
    public func clone() -> Self {
        return type(of: self).init(self)
    }
    
}
extension Array where Element: CanvasClonable {
    
    public func clone() -> Array {
        var clonedArray = Array<Element>()
        for element in self {
            clonedArray.append(element.clone())
        }
        return clonedArray
    }
    
}
extension Dictionary where Value: CanvasClonable {
    
    public func clone() -> Dictionary {
        var clonedDictionary = Dictionary<Key, Value>()
        for pair in self {
            clonedDictionary[pair.key] = pair.value.clone()
        }
        return clonedDictionary
    }
    
}
