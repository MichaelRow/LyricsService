//
//  KrcDecoder.swift
//  LyricsX
//
//  Created by Eru on 2017/8/2.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import SwiftyJSON
import OpenCCSwift

/// 酷狗使用的逐字歌词解析器
public class KrcDecoder: LyricsDecoder {
    
    public static let shared = KrcDecoder()
    
    /// 匹配歌词行开头
    private var lineTimeRex: NSRegularExpression
    
    /// 匹配歌词字的时间和字
    private var wordTimeRex: NSRegularExpression
    
    var idTagRex: NSRegularExpression

    private init() {
        lineTimeRex = try! NSRegularExpression(pattern: "\\[\\d+,\\d+\\]", options: [])
        wordTimeRex = try! NSRegularExpression(pattern: "<\\d+,\\d+,\\d+>", options: [])
        idTagRex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]", options: [])
    }
    
    public func decode(_ text: String) -> Lyrics? {
        guard let decrypt = KugouDecrypt.decrypt(base64: text) else { return nil }
        var lines = [LyricsLine]()
        var metaData = MetaData()
        //解析
        let paragraphs = decrypt.components(separatedBy: CharacterSet.newlines)
        for krcLine in paragraphs {
            if parse(timeTag: krcLine, lines: &lines) { continue }
            if parse(infoTag: krcLine, metaData: &metaData) { continue }
        }
        lines.sort { $0.begin < $1.begin }
        let lyrics = Lyrics(lines: lines, info: metaData, option: [.karaoke])
        
        //解析翻译和罗马字
        parseExtraInfo(lyrics)
        lyrics.metaData.allInfo.removeValue(forKey: "language")
        
        return lyrics
    }
    
    //MARK: Private
    private func parse(timeTag line: String, lines: inout [LyricsLine]) -> Bool {
        
        guard let lineMatched = lineTimeRex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)),
              let range = line.range(from: lineMatched.range)
        else { return false }
        
        let lineTimeTag = line[range]
        guard let commaIndex = lineTimeTag.index(of: ","),
              let lineBeginTime = Int(lineTimeTag[lineTimeTag.index(after: lineTimeTag.startIndex) ..< commaIndex]),
              let lineDuration = Int(lineTimeTag[lineTimeTag.index(after: commaIndex) ..< lineTimeTag.index(before: lineTimeTag.endIndex)])
        else { return true }
        
        //解析歌词逐字标签
        guard let karaoke = karaokeAccessory(with: line, lineBegin: lineBeginTime, lineDuration: lineDuration) else { return true }
        let lyricsLine = LyricsLine(value: karaoke.value, begin: TimeInterval(lineBeginTime)/1000, duration: TimeInterval(lineDuration)/1000)
        lyricsLine.accessory.karaoke = karaoke
        lines.append(lyricsLine)
        
        return true
    }
    
    private func karaokeAccessory(with line: String, lineBegin: Int, lineDuration: Int) -> LyricsLineAccessoryKaraoke? {
        
        let wordMatches = wordTimeRex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))
        guard wordMatches.count > 0 else { return nil }
       
        var components = [LyricsLineAccessoryComponent]()
        var charCount = 0
        for (index, match) in wordMatches.enumerated() {
            // 获取时间标签中的时间
            guard let tagRange = line.range(from: match.range) else { continue }
            let wordTimeTag = line[tagRange]
            let wordTimes = wordTimeTag[wordTimeTag.index(after: wordTimeTag.startIndex) ..< wordTimeTag.index(before: wordTimeTag.endIndex)]
            let times = wordTimes.components(separatedBy: ",")
            guard times.count >= 2,
                  let begin = Int(times[0]),
                  let duration = Int(times[1])
            else { continue }
            
            let startIndex = tagRange.upperBound
            let endIndex: String.Index
            if index + 1 >= wordMatches.count {
                endIndex = line.endIndex
            } else {
                let offset = wordMatches[index + 1].range.location
                guard let endIndexTemp = line.index(line.startIndex, offsetBy: offset, limitedBy: line.endIndex) else { continue }
                endIndex = endIndexTemp
            }

            let word = line[startIndex ..< endIndex]
            let range = NSRange(location: charCount, length: word.count)
            guard let component = LyricsLineAccessoryComponent(value: String(word), begin: TimeInterval(begin)/1000, duration: TimeInterval(duration)/1000, range: range) else { continue }
            components.append(component)
            
            charCount += word.count
        }
        
        return LyricsLineAccessoryKaraoke(components: components, begin: TimeInterval(lineBegin)/1000, duration: TimeInterval(lineDuration)/1000)
    }
    
    private func parseExtraInfo(_ lyrics: Lyrics) {
        guard let translationBase64 = lyrics.metaData["language"],
              let translationData = Data(base64Encoded: translationBase64),
              let contentArray = JSON(translationData)["content"].array
        else { return }
        
        for content in contentArray {
            guard let translations = content["lyricContent"].array,
                  let type = content["type"].int
            else { return }
            
            if type == 0 {
                setRomaji(with: translations, lyrics: lyrics)
            } else {
                setTranslation(from: translations, lyrics: lyrics)
            }
        }
    }
    
    private func setRomaji(with lyricContent: [JSON], lyrics: Lyrics) {
        for (index, content) in lyricContent.enumerated() {
            guard let romajiArray = content.array,
                  lyrics.lines.count > index,
                  let karaokeAccessory = lyrics.lines[index].accessory.karaoke
            else { continue }
            
            var charCount = 0
            var components = [LyricsLineAccessoryComponent]()
            for (romajiIndex, romaji) in romajiArray.enumerated() {
                guard romajiIndex < karaokeAccessory.components.count else { return }
                let karaokeComponent = karaokeAccessory.components[romajiIndex]
                
                let romajiValue = romaji.stringValue
                let spaceNum = max(romajiIndex - 1, 0)
                let rangeInAccessory = NSRange(location: charCount + spaceNum, length: romajiValue.count)
                charCount += romajiValue.count
                guard let romajiComponent = LyricsLineAccessoryComponent(value: romajiValue, begin: karaokeComponent.begin, duration: karaokeComponent.duration, rangeInLine: karaokeComponent.rangeInLine, rangeInAccessory: rangeInAccessory) else { continue }
                components.append(romajiComponent)
            }
            
            let lyricsLine = lyrics.lines[index]
            let accessory = LyricsLineAccessoryPronunciation(components: components, begin: lyricsLine.begin, duration: lyricsLine.end, type: .romaji)
            lyricsLine.accessory.romaji = accessory
        }
    }
    
    private func setTranslation(from lyricContent: [JSON], lyrics: Lyrics) {
        let simplizer = ChineseConverter(Simplize.taiwanPhrase)
        let traditionalizer = ChineseConverter(Traditionalize.taiwanPhrase)
        
        for (index, content) in lyricContent.enumerated() {
            guard let transArray = content.array else { continue }
            let translation = transArray.reduce("") { $0 + $1.stringValue }
            guard lyrics.lines.count > index else { continue }
            
            let lyricsLine = lyrics.lines[index]
            
            translateChinese(with: simplizer, translation: translation, language: .simplifiedChinese, lyricsLine: lyricsLine)
            translateChinese(with: traditionalizer, translation: translation, language: .traditionalChinese, lyricsLine: lyricsLine)
        }
    }
    
    private func translateChinese(with converter: ChineseConverter?, translation: String, language: Language, lyricsLine: LyricsLine) {
        let simplifiedTranslation = converter?.convert(string: translation) ?? translation
        let simplifiedAccessory = LyricsLineAccessoryTranslation(value: simplifiedTranslation, begin: lyricsLine.begin, duration: lyricsLine.duration, type: .translation(language))
        lyricsLine.accessory.setTranslation(accessory: simplifiedAccessory, for: language)
    }
}

extension KrcDecoder: LyricsIDTagDecodable {}
