//
//  LrcDecoder.swift
//  LyricsX
//
//  Created by Eru on 2017/8/2.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa

/// 通用歌词解析器
public class LrcDecoder: LyricsDecoder {
    
    public static let shared = LrcDecoder()
    
    private var timeTagRex: NSRegularExpression
    
    var idTagRex: NSRegularExpression
    
    private init() {
        timeTagRex = try! NSRegularExpression(pattern: "\\[\\d+:\\d+.\\d+\\]|\\[\\d+:\\d+\\]", options: [])
        idTagRex = try! NSRegularExpression(pattern: "\\[[^\\]]+:[^\\]]+\\]", options: [])
    }
    
    public func decode(_ text: String) -> Lyrics? {
        guard let parseResult = parse(text),
              parseResult.timeTrack.count > 0
        else { return nil }
        
        let lyricsLines = lines(from: parseResult.timeTrack)
        return Lyrics(lines: lyricsLines, info: parseResult.infos, option: [])
    }
    
//MARK: Private
    
    /// 解析lrc歌词
    private func parse(_ text: String) -> (timeTrack: [Int : String], infos: MetaData)? {
        
        var timeDic = [Int : String]()
        var metaData = MetaData()
        
        let lrcParagraphs = text.components(separatedBy: CharacterSet.newlines)
        for lrcLine in lrcParagraphs {
            if parse(timeTag: lrcLine, timeDic: &timeDic) { continue }
            if parse(infoTag: lrcLine, metaData: &metaData) { continue }
        }
        return (timeDic, metaData)
    }
    
    @discardableResult
    private func parse(timeTag line: String, timeDic: inout [Int : String]) -> Bool {
        let timeTagsMatched = timeTagRex.matches(in: line, options: [], range: NSRange(location: 0, length: line.count))
        guard timeTagsMatched.count > 0 else { return false }
        
        let index = timeTagsMatched.last!.range.location + timeTagsMatched.last!.range.length
        let lineContent = index < line.count - 1 ? line[line.index(line.startIndex, offsetBy: index)...] : ""
        for result in timeTagsMatched {
            guard let range = line.range(from: result.range) else { continue }
            let timeTag = line[range]
            guard let msTime = time(from: String(timeTag)) else { continue }
            timeDic[msTime] = String(lineContent)
        }
        return true
    }
    
    private func time(from tag: String) -> Int? {
        guard let colonRange = tag.range(of: ":"),
              let dotRange = tag.range(of: "."),
              let leftBracketRange = tag.range(of: "["),
              let rightBracketRange = tag.range(of: "]")
        else { return nil }
        
        let minStr = tag[leftBracketRange.upperBound ..< colonRange.lowerBound]
        let secStr = tag[colonRange.upperBound ..< dotRange.lowerBound]
        let msecStr = tag[dotRange.upperBound ..< rightBracketRange.lowerBound]
        
        guard let min = Int(minStr),
              let sec = Int(secStr),
              let msec = Int(msecStr)
        else { return nil }
        
        return (min * 60 + sec) * 1000 + msec
    }
    
    private func lines(from timeTrackInfos: [Int : String]) -> [LyricsLine] {
        let sortedTime = timeTrackInfos.keys.sorted { $0 < $1 }
        var lines = [LyricsLine]()
        
        for index in 0 ..< sortedTime.count {
            let currentTime = sortedTime[index]
            guard let content = timeTrackInfos[currentTime] else { continue }
            let nextTime: Int
            if index + 1 < sortedTime.count {
                nextTime = sortedTime[index + 1]
            } else {
                nextTime = currentTime + 30
            }
            
            let line = LyricsLine(value: content, begin: TimeInterval(currentTime)/1000, duration: TimeInterval(nextTime - currentTime)/1000)
            lines.append(line)
        }
        return lines
    }
}

extension LrcDecoder: LyricsIDTagDecodable {}

