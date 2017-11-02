//
//  LyricsSourceFactory.swift
//  LyricsX
//
//  Created by Eru on 2017/8/26.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public struct LyricsSourceFactory {
    
    /// 歌词源工厂
    public static func source(with name: LyricsSourceInfo) -> LyricsSource {
        switch name {
        case .NetEase:
            return NetEaseSource()
        case .QQMusic:
            return QQSource()
        case .TTPod:
            return TTPodSource()
        case .Gecimi:
            return GecimiSource()
        case .Xiami:
            return XiamiSource()
        case .Qianqian:
            return QianqianSource()
        case .Kugou:
            return KugouSource()
        }
    }
    
    private init() {}
}

