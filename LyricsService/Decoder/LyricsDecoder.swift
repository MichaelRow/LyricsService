//
//  LyricsDecoder.swift
//  LyricsService
//
//  Created by Michael Row on 2017/9/24.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public protocol LyricsDecoder {
    
    func decode(_ text: String) -> Lyrics?

}

protocol LyricsIDTagDecodable: LyricsDecoder {
    
    var idTagRex: NSRegularExpression { get }
    
}

extension LyricsIDTagDecodable {
    
    @discardableResult
    func parse(infoTag line: String, metaData: inout MetaData) -> Bool {
        let idTagsMatched = idTagRex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))
        guard idTagsMatched.count > 0 else { return false }
        
        for result in idTagsMatched {
            guard let range = line.range(from: result.range) else { continue }
            let idTag = line[range]
            guard let colonRange = idTag.range(of: ":") else { continue }
            
            let keyStartIndex = idTag.index(after: idTag.startIndex)
            let valueEndIndex = idTag.index(before: idTag.endIndex)
            
            let key = idTag[keyStartIndex ..< colonRange.lowerBound]
            let value = idTag[colonRange.upperBound ..< valueEndIndex]
            
            metaData[String(key)] = String(value)
        }
        return true
    }
}
