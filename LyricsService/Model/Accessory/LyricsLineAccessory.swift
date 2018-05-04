//
//  LyricsLineAccessory.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/14.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

public protocol LyricsLineAccessoryable: LyricsJSONPresentable {
    var begin: TimeInterval { get }
    var duration: TimeInterval { get }
    var end: TimeInterval { get }
    var type: LyricsLineAccessory.Kind { get }
}

public enum Language: String {
    case simplifiedChinese = "zh_CN"
    case traditionalChinese = "zh_TW"
    case japaneseRomaji = "jp_romaji"
    case english = "en"
}

public class LyricsLineAccessory {
    
    public enum Kind {
        case romaji
        case karaoke
        case translation(Language)
        
        public var lyricsOption: Lyrics.Option {
            switch self {
            case .romaji:
                return .romaji
            case .karaoke:
                return .karaoke
            case .translation(_):
                return .translate
            }
        }
    }
    
    public private(set) var values = [Kind : LyricsLineAccessoryable]()
    
    public private(set) var supportedTranslation = Set<Language>()
    
    public var romaji: LyricsLineAccessoryPronunciation? {
        get {
            return values[.romaji] as? LyricsLineAccessoryPronunciation
        }
        set {
            guard newValue?.type == .romaji else { return }
            values[.romaji] = newValue
        }
    }
    
    public var karaoke: LyricsLineAccessoryKaraoke? {
        get {
            return values[.karaoke] as? LyricsLineAccessoryKaraoke
        }
        set {
            guard newValue?.type == .karaoke else { return }
            values[.karaoke] = newValue
        }
    }
    
    public func translation(for language: Language) -> LyricsLineAccessoryTranslation? {
        return values[.translation(language)] as? LyricsLineAccessoryTranslation
    }
    
    public func setTranslation(accessory: LyricsLineAccessoryTranslation, for language: Language) {
        values[.translation(language)] = accessory
        supportedTranslation.insert(language)
    }
    
    public func setAccessory(_ accessory: LyricsLineAccessoryable?, for type: Kind) {
        if accessory == nil,
           case .translation(let language) = type {
            supportedTranslation.remove(language)
            return
        }
        
        values[type] = accessory
        if case .translation(let language) = type {
            supportedTranslation.insert(language)
        }
    }
}

extension LyricsLineAccessory: LyricsJSONPresentable {
    
    public var codableValue: JSONEncodable {
        var map = [String : JSONEncodable]()
        values.keys.forEach { type in
            map[type.rawValue] = values[type]?.codableValue
        }
        return map
    }
}

extension LyricsLineAccessory.Kind: RawRepresentable {
    
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        if rawValue == "romaji" {
            self = .romaji
        } else if rawValue == "karaoke" {
            self = .karaoke
        } else if rawValue.starts(with: "translation-") {
            self = .translation(.english)
            guard let type = type(from: rawValue) else { return nil }
            self = type
        } else {
            return nil
        }
    }
    
    public var rawValue: String {
        switch self {
        case .romaji:
            return "romaji"
        case .karaoke:
            return "karaoke"
        case .translation(let translation):
            return "translation-" + translation.rawValue
        }
    }
    
    private func type(from translation: String) -> LyricsLineAccessory.Kind? {
        if translation.hasSuffix(Language.simplifiedChinese.rawValue) {
            return .translation(.simplifiedChinese)
        } else if translation.hasSuffix(Language.traditionalChinese.rawValue) {
            return .translation(.traditionalChinese)
        } else if translation.hasSuffix(Language.japaneseRomaji.rawValue) {
            return .translation(.japaneseRomaji)
        } else {
            return nil
        }
    }
}

extension LyricsLineAccessory.Kind: Hashable {
    public var hashValue: Int { return self.rawValue.hashValue }
}
