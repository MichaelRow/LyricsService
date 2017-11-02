//
//  LrcxDecoder.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/24.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import SwiftyJSON

public class LrcxDecoder: LyricsDecoder {
    
    public static let shared = LrcxDecoder()
    
    private var tagRex: NSRegularExpression
    
    private init() {
        tagRex = try! NSRegularExpression(pattern: "\\(\\d+,\\d+,\\d+,\\d+\\)", options: [])
    }
    
    public func decode(_ text: String) -> Lyrics? {
        let resolvedJSON = JSON(parseJSON: text)
        guard let lyrics = parseLines(with: resolvedJSON) else { return nil }
        parseMetaData(with: resolvedJSON, lyrics: lyrics)
        return lyrics
    }
    
    //MARK: Private
    
    private func parseLines(with json: JSON) -> Lyrics? {
        var lines = [LyricsLine]()
        var option: Lyrics.Option = []
        
        guard let jsonLines = json["lines"].array else { return nil }
        for lineInfo in jsonLines {
            let begin = lineInfo["begin"].doubleValue / 1000
            let duration = lineInfo["duration"].doubleValue / 1000
            let value = lineInfo["value"].stringValue
            let lyricsLine = LyricsLine(value: value, begin: begin, duration: duration)
            
            let newOpt = parseAccessory(with: lineInfo, lyricsLine: lyricsLine, begin: begin, duration: duration)
            option.insert(newOpt)
            lines.append(lyricsLine)
        }
        
        return Lyrics(lines: lines, info: MetaData(), option: option)
    }
    
    private func parseAccessory(with json: JSON, lyricsLine: LyricsLine, begin: TimeInterval, duration: TimeInterval) -> Lyrics.Option {
        guard let accessoryInfo = json["accessory"].dictionary else { return [] }
        var option: Lyrics.Option = []
        
        for key in accessoryInfo.keys {
            guard let accessoryType = LyricsLineAccessory.Kind(rawValue: key),
                  let lineValue = accessoryInfo[key]?["value"].string
            else { continue }
            let accessory: LyricsLineAccessoryable?
            
            switch accessoryType {
            case .karaoke:
                accessory = parseKaraoke(with: lineValue, line: lyricsLine, begin: begin, duration: duration)
            case .romaji:
                accessory = parseRomaji(with: lineValue, line: lyricsLine, begin: begin, duration: duration)
            case .translation(let language):
                accessory = parseTranslation(with: lineValue, language: language, begin: begin, duration: duration)
            }
            
            guard accessory != nil else { continue }
            option.insert(accessoryType.lyricsOption)
            lyricsLine.accessory.setAccessory(accessory!, for: accessoryType)
        }
        return option
    }
    
    private func parseKaraoke(with text: String, line: LyricsLine, begin: TimeInterval, duration: TimeInterval) -> LyricsLineAccessoryKaraoke? {
        let matchedTags = tagRex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        guard matchedTags.count > 0 else { return nil }
        
        var components = [LyricsLineAccessoryComponent]()
        for tag in matchedTags {
            guard let tagRange = text.range(from: tag.range),
                  let tagComponents = tagComponents(from: text[tagRange])
            else { continue }
            
            let nsRange = NSRange(location: tagComponents[0], length: tagComponents[1])
            guard let range = line.value.range(from: nsRange),
                  let component = LyricsLineAccessoryComponent(value: String(line.value[range]), begin: begin, duration: duration, range: nsRange)
            else { continue }
            
            components.append(component)
        }
        
        return LyricsLineAccessoryKaraoke(components: components, begin: begin, duration: duration)
    }

    private func parseRomaji(with text: String, line: LyricsLine, begin: TimeInterval, duration: TimeInterval) -> LyricsLineAccessoryPronunciation? {
        let matchedTags = tagRex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        guard matchedTags.count > 0 else { return nil }
        
        var components = [LyricsLineAccessoryComponent]()
        for (index, tag) in matchedTags.enumerated() {
            guard let tagRange = text.range(from: tag.range),
                  let tagComponents = tagComponents(from: text[tagRange])
            else { continue }
            
            
            let startIndex = tagRange.upperBound
            let endIndex: String.Index
            if index + 1 >= matchedTags.count {
                endIndex = text.endIndex
            } else {
                let offset = matchedTags[index + 1].range.location
                guard let endIndexTemp = text.index(text.startIndex, offsetBy: offset, limitedBy: text.endIndex) else { continue }
                endIndex = endIndexTemp
            }
            let value = text[startIndex ..< endIndex]
            
            let rangeInLine = NSRange(location: tagComponents[0], length: tagComponents[1])
            let rangeInAccessory = NSRange(location: tagComponents[0] + index, length: tagComponents[1])
            
            guard let _ = line.value.range(from: rangeInLine),
                  let component = LyricsLineAccessoryComponent(value: String(value), begin: begin, duration: duration, rangeInLine: rangeInLine, rangeInAccessory: rangeInAccessory)
            else { continue }
            
            components.append(component)
        }
        
        return LyricsLineAccessoryPronunciation(components: components, begin: begin, duration: duration, type: .romaji)
    }
    
    private func parseTranslation(with text: String, language: Language, begin: TimeInterval, duration: TimeInterval) -> LyricsLineAccessoryTranslation? {
        return LyricsLineAccessoryTranslation(value: text, begin: begin, duration: duration, type: .translation(language))
    }
    
    private func parseMetaData(with json: JSON, lyrics: Lyrics) {
        guard let metaData = json["metaData"].dictionary else { return }
        for key in metaData.keys {
            guard let value = metaData[key]?.stringValue else { continue }
            lyrics.metaData.set(value: value, forKey: key)
        }
    }

    private func tagComponents(from tag: Substring) -> [Int]? {
        guard tag.count >= 9 else { return nil }
        var tagContent = tag
        tagContent.removeFirst()
        tagContent.removeLast()
        
        let components = tag.components(separatedBy: ",")
        return components.map{ Int($0) ?? 0 }
    }
}
