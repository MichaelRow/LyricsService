//
//  LyricsLineAccessoryComponentable.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/15.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public class LyricsLineAccessoryComponentable: LyricsLineAccessoryable, LyricsDictionaryPresentable {
    
    public var components: [LyricsLineAccessoryComponent]
    
    public var type: LyricsLineAccessory.Kind
    
    public var begin: TimeInterval {
        didSet { begin = max(begin, 0) }
    }
    
    public var duration: TimeInterval {
        didSet { duration = max(duration, 0) }
    }
    
    public var end: TimeInterval { return begin + duration }
    
    init(components: [LyricsLineAccessoryComponent], begin: TimeInterval, duration: TimeInterval, type: LyricsLineAccessory.Kind) {
        self.components = components
        self.begin = begin
        self.duration = duration
        self.type = type
    }
    
    public var dictionaryValue: [String : Encodable] {
        let description = components.reduce("") {
            $0 + String(format: "(%d,%d,%.0f,%.0f)%@",$1.rangeInLine.location,$1.rangeInLine.length,$1.begin*1000,$1.duration*1000,$1.value)
        }
        return [ "value" : description ]
    }
}

public class LyricsLineAccessoryKaraoke: LyricsLineAccessoryComponentable {
    
    public init(components: [LyricsLineAccessoryComponent], begin: TimeInterval, duration: TimeInterval) {
        super.init(components: components, begin: begin, duration: duration, type: .karaoke)
    }
    
    public var value: String {
        return components.reduce("") { $0 + $1.value }
    }
    
    override public var dictionaryValue: [String : Encodable] {
        let description = components.reduce("") {
            $0 + String(format: "(%d,%d,%.0f,%.0f)",$1.rangeInLine.location,$1.rangeInLine.length,$1.begin*1000,$1.duration*1000)
        }
        return [ "value" : description ]
    }
}

public class LyricsLineAccessoryPronunciation: LyricsLineAccessoryComponentable {
    public var value: String {
        var value = components.reduce("") { $0 + " " + $1.value }
        if value.count > 0 { value.removeFirst() }
        return value
    }
}

