//
//  JrcDecoder.swift
//  LyricsX
//
//  Created by Eru on 2017/8/2.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import SwiftyJSON

/// 网易云音乐接口使用的组合歌词解析器 JSON Lyrics
public class NetEaseJSONLyricsDecoder: LyricsDecoder {
    
    public static let shared = NetEaseJSONLyricsDecoder()
    
    public func decode(_ text: String) -> Lyrics? {
        let jsonObject = JSON(parseJSON: text)
        var lyrics: Lyrics?
        
        // 歌词主体
        if let kLyric = jsonObject["klyric"]["lyric"].string {
            lyrics = KLyricDecoder.shared.decode(kLyric)
        }
        
        // 无逐字歌词用逐行歌词
        if lyrics == nil,
           let lrc = jsonObject["lrc"]["lyric"].string {
            
            lyrics = LrcDecoder.shared.decode(lrc)
        }

        guard lyrics != nil else { return nil }
        
        // 翻译
        if let tLyric = jsonObject["tlyric"]["lyric"].string,
           let translationLyrics = LrcDecoder.shared.decode(tLyric) {
            
            lyrics!.merge(lyrics: translationLyrics, newOption: .translate)
        }
        
        return lyrics
    }
    
    private init() {}
}


