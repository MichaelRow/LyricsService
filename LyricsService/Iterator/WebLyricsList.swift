//
//  WebLyricsList.swift
//  LyricsX
//
//  Created by Eru on 2017/7/3.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

public class WebLyricsList: DefaultIterator {
    
    public private(set) var webLyrics: [WebLyrics]
    
    /// 默认遍历器
    public private(set) var defaultIterator: WebLyricesIterator
    
    public init(_ webLyrics: [WebLyrics]) {
        self.webLyrics = webLyrics
        self.defaultIterator = WebLyricesIterator(webLyrics: webLyrics)
    }
    
    public func resetIterator() {
        defaultIterator = WebLyricesIterator(webLyrics: webLyrics)
    }
}

//MARK: Sequence

extension WebLyricsList: Sequence {
    
    public typealias Iterator = WebLyricesIterator
    
    public func makeIterator() -> WebLyricsList.Iterator {
        return WebLyricesIterator(webLyrics: webLyrics)
    }
}

//MARK: Collection

extension WebLyricsList: Collection {
    
    public typealias Element = WebLyrics
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return webLyrics.count - 1
    }
    
    public subscript(i: Int) -> Element {
        precondition((0 ..< endIndex).contains(i), "序列越界")
        return webLyrics[i]
    }
    
    public func index(after i: Int) -> Int {
        if i < endIndex {
            return i + 1
        } else {
            return endIndex
        }
    }
}

