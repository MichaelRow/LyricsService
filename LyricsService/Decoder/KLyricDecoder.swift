//
//  KLyricDecoder.swift
//  LyricsX
//
//  Created by Michael Row on 2017/8/11.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

/// 网易云音乐使用的逐字歌词解析器
public class KLyricDecoder: LyricsDecoder {
    
    public static let shared = KLyricDecoder()
    
    /// 匹配歌词行开头
    private var lineTimeRex: NSRegularExpression
    
    /// 匹配歌词字的时间和字
    private var wordTimeRex: NSRegularExpression
    
    var idTagRex: NSRegularExpression
    
    private init() {
        lineTimeRex = try! NSRegularExpression(pattern: "\\[\\d+,\\d+\\]", options: [])
        wordTimeRex = try! NSRegularExpression(pattern: "\\(\\d+,\\d+\\)", options: [])
        idTagRex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]", options: [])
    }
    
    public func decode(_ text: String) -> Lyrics? {
        var lines = [LyricsLine]()
        var metaData = MetaData()
        
        //解析
        let paragraphs = text.components(separatedBy: CharacterSet.newlines)
        for krcLine in paragraphs {
            if parse(timeTag: krcLine, lines: &lines) { continue }
            if parse(infoTag: krcLine, metaData: &metaData) { continue }
        }
        lines.sort { $0.begin < $1.begin }
        return Lyrics(lines: lines, info: metaData, option: .karaoke)
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
        var currentTime = lineBegin
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
            
            //获取单词开始index
            let startIndex = tagRange.upperBound
            //获取单词结束index
            let endIndex: String.Index
            if index + 1 >= wordMatches.count {
                endIndex = line.endIndex
            } else {
                let offset = wordMatches[index + 1].range.location
                guard let endIndexTemp = line.index(line.startIndex, offsetBy: offset, limitedBy: line.endIndex) else { continue }
                endIndex = endIndexTemp
            }
            //单词
            let word = line[startIndex ..< endIndex]
            let range = NSRange(location: charCount, length: word.count)
            guard let component = LyricsLineAccessoryComponent(value: String(word), begin: TimeInterval(begin + currentTime)/1000, duration: TimeInterval(duration)/1000, range: range) else { continue }
            components.append(component)
            
            currentTime += (begin + duration)
            charCount += word.count
        }
        
        return LyricsLineAccessoryKaraoke(components: components, begin: TimeInterval(lineBegin)/1000, duration: TimeInterval(lineDuration)/1000)
    }
}

extension KLyricDecoder: LyricsIDTagDecodable {}
