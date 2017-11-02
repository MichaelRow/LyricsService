//
//  MetaData.swift
//  LyricsX
//
//  Created by Michael Row on 2017/8/6.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

public struct MetaData: Encodable {
    
    ///歌名 Tag: ti
    public var title: String? {
        didSet {
            allInfo["ti"] = title
        }
    }
    
    ///歌手名 Tag: ar
    public var artist: String? {
        didSet {
            allInfo["ar"] = artist
        }
    }
    
    ///专辑名 Tag: al
    public var album: String? {
        didSet {
            allInfo["al"] = album
        }
    }
    
    /// 作者 Tag: by
    public var author: String? {
        didSet {
            allInfo["by"] = author
        }
    }
    
    ///偏移量 Tag: offset
    public var offset: Int = 0 {
        didSet {
            allInfo["offset"] = "\(offset)"
        }
    }
    
    ///其他信息
    public var allInfo = [String : String]()
    
    public init() {}
    
    public mutating func set(value: String, forKey key: String) {
        switch key.lowercased() {
        case "ti", "title":
            title = value
        case "ar", "artist":
            artist = value
        case "al", "album":
            album = value
        case "by", "author":
            author = value
        case "offset":
            if let intValue = Int(value) { offset = intValue }
        default:
            break
        }
        allInfo[key] = value
    }
    
    public subscript(key: String) -> String? {
        get {
            return allInfo[key]
        }
        set {
            guard let newValue = newValue else { return }
            set(value: newValue, forKey: key)
        }
    }    
}

extension MetaData: LyricsDictionaryPresentable {
    public var dictionaryValue: [String : Encodable] { return allInfo }
}
