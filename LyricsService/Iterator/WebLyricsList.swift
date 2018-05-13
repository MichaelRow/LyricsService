//
//  WebLyricsList.swift
//  LyricsX
//
//  Created by Eru on 2017/7/3.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

public class WebLyricsList: DefaultIterator {
    
    public typealias Element = WebLyrics
    
    public private(set) var webLyrics: [Element]
    
    /// 默认遍历器
    public var defaultIterator: IteratorType
    
    public var iterableContent: [Element] { return webLyrics }
    
    public init(_ webLyrics: [Element]) {
        self.webLyrics = webLyrics
        self.defaultIterator = IteratorType(array: webLyrics)
    }
}
