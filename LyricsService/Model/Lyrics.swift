//
//  Lyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/7/8.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

public protocol LyricsJSONPresentable {
    var codableValue: JSONEncodable { get }
}

public class Lyrics {
    
    public struct Option: OptionSet {
        
        public let rawValue: UInt
        
        public init(rawValue: UInt) { self.rawValue = rawValue }
        
        public static let translate = Option(rawValue: 1 << 0)
        
        public static let karaoke = Option(rawValue: 1 << 1)
        
        public static let romaji = Option(rawValue: 1 << 2)
        
        static let allOption = [translate, karaoke, romaji]
        
        static let completeOption: Option = [.translate, .karaoke, .romaji]
    }
    
    //MARK: - Lyrics
    
    public var defaultIterator: IteratorType
    
    public var lines: [LyricsLine]
    
    public var metaData: MetaData
    
    public var option: Option
    
    public var lyricsValue: String {
        var value = lines.reduce("") { $0 + $1.value + "\n" }
        value.removeLast()
        return value
    }
    
    public var romajiValue: String? {
        guard option.contains(.romaji) else { return nil }
        var value = lines.reduce("") { result, line -> String in
            guard let romaji = line.accessory.romaji else { return result }
            return result + romaji.value + "\n"
        }
        if value.count > 0 { value.removeLast() }
        return value.count > 0 ? value : nil
    }
    
    public init(lines: [LyricsLine], info: MetaData, option: Option) {
        self.lines = lines
        self.metaData = info
        self.option = option
        self.defaultIterator = IteratorType(array: lines)
    }
    
    public func merge(lyrics: Lyrics, newOption: Option) {
        LrcMerger.mergeMatchingTime(self, with: lyrics)
        option.insert(newOption)
    }
    
    public var JSONValue: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: codableValue, options: []) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    public func translation(for language: Language) -> String? {
        guard option.contains(.translate) else { return nil }
        var value = lines.reduce("") { result, line -> String in
            guard let translation = line.accessory.translation(for: language) else { return result }
            return result + translation.value + "\n"
        }
        if value.count > 0 { value.removeLast() }
        return value.count > 0 ? value : nil
    }
}

extension Lyrics: DefaultIterator {
    
    public typealias Element = LyricsLine
    public var iterableContent: [LyricsLine] { return lines }
}

extension Lyrics: LyricsJSONPresentable {
    
    public var codableValue: JSONEncodable {
        let codableLines = lines.map { $0.codableValue }
        let codableValue = [ "lines" : codableLines,
                             "metaData" : metaData.codableValue ]
        return codableValue
    }
}
