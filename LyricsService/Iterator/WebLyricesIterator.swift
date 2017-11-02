//
//  WebLyricesIterator.swift
//  LyricsX
//
//  Created by Eru on 2017/6/29.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public class WebLyricesIterator {
    
    fileprivate var index = 0
    fileprivate var webLyrics: [WebLyrics]
    
    public init(webLyrics: [WebLyrics]) {
        self.webLyrics = webLyrics
    }
}

extension WebLyricesIterator: IteratorProtocol {
    
    public typealias Element = WebLyrics
    
    public func next() -> WebLyrics? {
        if index < webLyrics.count {
            let element = webLyrics[index]
            index += 1
            return element
        } else {
            return nil
        }
    }
}
