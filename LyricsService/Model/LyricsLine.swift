//
//  LyricsLine.swift
//  LyricsX
//
//  Created by Eru on 2017/7/8.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

public class LyricsLine {
    
    public var accessory = LyricsLineAccessory()

    public var value: String
    
    public var enable = true
    
    public var begin: TimeInterval {
        didSet { begin = max(begin, 0) }
    }
    
    public var duration: TimeInterval {
        didSet { duration = max(duration, 0) }
    }
    
    public var end: TimeInterval { return begin + duration }
    
    init(value: String, begin: TimeInterval, duration: TimeInterval) {
        self.value = value
        self.begin = begin
        self.duration = duration
    }
}

extension LyricsLine: LyricsDictionaryPresentable {
    
    public var dictionaryValue: [String : Encodable] {
        return [ "accessory" : accessory.dictionaryValue,
                 "value" : value,
                 "begin" : Int(begin*1000),
                 "duration" : Int(duration*1000)]
    }
}
