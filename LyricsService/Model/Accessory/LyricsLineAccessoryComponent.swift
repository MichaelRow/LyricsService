//
//  LyricsLineAccessoryComponent.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/28.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public class LyricsLineAccessoryComponent {
    
    public var value: String
    
    public var rangeInLine = NSRange()
    
    public var rangeInAccessory = NSRange()
    
    public var begin: TimeInterval {
        didSet { begin = max(begin, 0) }
    }
    
    public var duration: TimeInterval {
        didSet { duration = max(duration, 0) }
    }
    
    public var end: TimeInterval { return begin + duration }
    
    public init?(value: String, begin: TimeInterval, duration: TimeInterval, range: NSRange) {
        self.value = value
        self.begin = begin
        self.duration = duration
        self.rangeInLine = range
        self.rangeInAccessory = range
    }
    
    public init?(value: String, begin: TimeInterval, duration: TimeInterval, rangeInLine: NSRange, rangeInAccessory: NSRange) {
        self.value = value
        self.begin = begin
        self.duration = duration
        self.rangeInLine = rangeInLine
        self.rangeInAccessory = rangeInAccessory
    }
}
