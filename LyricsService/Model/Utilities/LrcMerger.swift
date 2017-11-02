//
//  LrcMerger.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/29.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import OpenCCSwift

class LrcMerger {
        
    private init() {}
    
    static func mergeMatchingTime(_ lyrics: Lyrics, with translationLyrics: Lyrics) {
        let simplizer = ChineseConverter(Simplize.taiwanPhrase)!
        let traditionalizer = ChineseConverter(Traditionalize.taiwanPhrase)!
        var translationLines = translationLyrics.lines
        for line in lyrics.lines {
            var shouldRemoveIndex: Int? = nil
            for (translationIndex, translationLine) in translationLines.enumerated() {
                if abs(line.begin - translationLine.begin) <= 0.5 {
                    shouldRemoveIndex = translationIndex
                    let simplifiedTranslation = simplizer.convert(string: translationLine.value)
                    let traditionalTranslation = traditionalizer.convert(string: translationLine.value)
                    let simplifiedAccessory = LyricsLineAccessoryTranslation(value: simplifiedTranslation, begin: line.begin, duration: line.end, type: .translation(.simplifiedChinese))
                    let traditionalizedAccessory = LyricsLineAccessoryTranslation(value: traditionalTranslation, begin: line.begin, duration: line.duration, type: .translation(.traditionalChinese))
                    line.accessory.setTranslation(accessory: simplifiedAccessory, for: .simplifiedChinese)
                    line.accessory.setTranslation(accessory: traditionalizedAccessory, for: .traditionalChinese)
                }
                if shouldRemoveIndex != nil {
                    translationLines.remove(at: shouldRemoveIndex!)
                    break
                }
            }
        }
    }
    
}
