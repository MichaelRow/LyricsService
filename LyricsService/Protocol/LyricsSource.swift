//
//  LyricsSource.swift
//  LyricsX
//
//  Created by Eru on 2017/6/18.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public enum LyricsSourceInfo: String, RawRepresentable {
    
    public typealias RawValue = String
    
    case NetEase = "网易云音乐"
    
    case QQMusic = "QQ音乐"
    
    case TTPod = "天天动听"
    
    case Gecimi = "歌词迷"
    
    case Xiami = "虾米音乐"
    
    case Qianqian = "千千静听"
    
    case Kugou = "酷狗音乐"
    
    var supportFeature: Lyrics.Option {
        switch self {
        case .NetEase:
            return [.karaoke, .translate]
        case .QQMusic:
            return [.translate]
        case .TTPod:
            return []
        case .Gecimi:
            return []
        case .Xiami:
            return []
        case .Qianqian:
            return []
        case .Kugou:
            return [.karaoke, .translate, .romaji]
        }
    }
}

public enum LyricsType: String {
    
    case lrc
    case lrcx
    case krc
    case netEase
    
    var decoder: LyricsDecoder {
        switch self {
        case .lrc:
            return LrcDecoder.shared
        case .lrcx:
            return LrcxDecoder.shared
        case .krc:
            return KrcDecoder.shared
        case .netEase:
            return NetEaseJSONLyricsDecoder.shared
        }
    }
}

public protocol LyricsSource: class {
    
    var info: LyricsSourceInfo { get }
    
    /// 开始搜索
    func search(with info: SearchInfo, completionHandler: @escaping ([WebLyrics], LyricsError?) -> Void)
    
    /// 开始搜索
    func search(with info: SearchInfo, inProgress: @escaping (Lyrics) -> Void, completionHandler: @escaping ([Lyrics], LyricsError?) -> Void)
    
    /// 取消搜索
    func cancelSearch(info: SearchInfo)
    
    /// 停止搜索
    func stopSearch()
}
