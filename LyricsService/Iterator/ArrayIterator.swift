//
//  ArrayIterator.swift
//  LyricsX
//
//  Created by Eru on 2017/6/29.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public class ArrayIterator<T> {
        
    fileprivate var index = -1
    fileprivate var contentArray: [T]
    
    public init(array: [T]) {
        contentArray = array
    }
    
    public func current() -> T? {
        guard index >= 0, index < contentArray.count else { return nil }
        return contentArray[index]
    }
    
    public func previous() -> T? {
        let preIndex = index - 1
        guard preIndex >= 0, preIndex < contentArray.count else { return nil }
        return contentArray[preIndex]
    }
    
    public func nextWithoutMove() -> T? {
        let nextIndex = index + 1
        guard nextIndex >= 0, nextIndex < contentArray.count else { return nil }
        return contentArray[nextIndex]
    }
}

extension ArrayIterator: IteratorProtocol {
    
    public typealias Element = T
    
    public func next() -> T? {
        index += 1
        guard index < contentArray.count else { return nil }
        return contentArray[index]
    }
}
