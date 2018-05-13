//
//  DefaultIterator.swift
//  LyricsX
//
//  Created by Eru on 2017/8/16.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public protocol DefaultIterator: class, Collection {
    
    typealias IteratorType = ArrayIterator<Element>
    
    var defaultIterator: IteratorType { get set }
    
    var iterableContent: [Element] { get }
    
    func resetIterator()
}

//MARK: Sequence

public extension DefaultIterator {
    
    var startIndex: Int { return 0 }
    
    var endIndex: Int { return iterableContent.count }
    
    subscript(i: Int) -> Element {
        precondition((0 ..< endIndex).contains(i), "序列越界")
        return iterableContent[i]
    }
    
    func index(after i: Int) -> Int {
        return Swift.min(i + 1, endIndex)
    }
    
    func makeIterator() -> IteratorType {
        return IteratorType(array: iterableContent)
    }
    
    func resetIterator() {
        defaultIterator = IteratorType(array: iterableContent)
    }
}
