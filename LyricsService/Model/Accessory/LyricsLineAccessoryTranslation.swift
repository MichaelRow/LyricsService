//
//  LyricsLineAccessoryTranslation.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/15.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public class LyricsLineAccessoryTranslation: LyricsLineAccessoryable {
    
    public var type: LyricsLineAccessory.Kind
    
    public var value: String
    
    public var end: TimeInterval { return begin + duration }
    
    public var begin: TimeInterval {
        didSet { begin = max(begin, 0) }
    }
    
    public var duration: TimeInterval {
        didSet { duration = max(duration, 0) }
    }
    
    public init(value: String, begin: TimeInterval, duration: TimeInterval, type: LyricsLineAccessory.Kind) {
        self.value = value
        self.begin = begin
        self.duration = duration
        self.type = type
    }
}

extension LyricsLineAccessoryTranslation: LyricsJSONPresentable {
    public var codableValue: JSONEncodable {
        return [ "value" : value ] as [String : JSONEncodable]
    }
}
