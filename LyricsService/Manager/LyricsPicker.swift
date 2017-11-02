//
//  LyricsPicker.swift
//  LyricsService
//
//  Created by Eru on 2017/10/7.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation

class LyricsPicker {
    
    //MARK: - Public
    
    struct Quantization {
        var user: Float
        var ovaral: Float
    }
    
    private init() {}
    
    static func pickLyrics(with context: PickingSearchContext, inProgress:((Lyrics) -> Void)?, completion:@escaping (Lyrics?, LyricsError?) -> Void) {
        context.lyricsList = WebLyricsList(context.allWebLyrics)
        recursionPick(with: context, inProgress: inProgress, completion: completion)
    }
    
    //MARK: - Picking
    
    private static func recursionPick(with context: PickingSearchContext, inProgress:((Lyrics) -> Void)?, completion:@escaping (Lyrics?, LyricsError?) -> Void) {
        guard let webLyrics = context.lyricsList?.defaultIterator.next(),
              !context.isCancelled
        else {
            completion(context.pickedLyrics, context.isCancelled ? LyricsError.userCancel : nil)
            return
        }
        
        guard shouldRequest(with: context, webLyrics: webLyrics) else {
            recursionPick(with: context, inProgress: inProgress, completion: completion)
            return
        }
        
        let request = webLyrics.lyrics { lyrics in
            guard let lyrics = lyrics else {
                recursionPick(with: context, inProgress: inProgress, completion: completion)
                return
            }
            
            guard let lastPickedQuan = context.pickedQuantization else {
                context.pick(lyrics: lyrics, quantization: quantize(lyrics: lyrics, option: context.pickingOption))
                inProgress?(lyrics)
                recursionPick(with: context, inProgress: inProgress, completion: completion)
                return
            }
            
            let newLyricsQuan = quantize(lyrics: lyrics, option: context.pickingOption)
            if newLyricsQuan > lastPickedQuan {
                context.pick(lyrics: lyrics, quantization: newLyricsQuan)
                inProgress?(lyrics)
            }
            
            if newLyricsQuan.ovaral == 1 {
                let error = context.isCancelled ? LyricsError.userCancel : nil
                completion(context.pickedLyrics, error)
            } else {
                recursionPick(with: context, inProgress: inProgress, completion: completion)
            }
        }
        
        if request != nil {
            context.add(request: request!)
        }
    }
    
    private static func shouldRequest(with context: PickingSearchContext, webLyrics: WebLyrics) -> Bool {
        guard let lyrics = context.pickedLyrics else { return true }
        if lyrics.option.contains(webLyrics.sourceInfo.supportFeature) { return false }
        return true
    }
    
    //MARK: - Quantization
    
    private static func quantize(lyrics: Lyrics, option: Lyrics.Option) -> Quantization {
        let userQuantization = quantization(with: lyrics.option, compareOpt: option)
        let overalQuantization = quantization(with: lyrics.option, compareOpt: Lyrics.Option.completeOption)
        return Quantization(user: userQuantization, ovaral: overalQuantization)
    }
    
    private static func quantization(with lyricsOpt: Lyrics.Option, compareOpt: Lyrics.Option) -> Float {
        var satisfied = 0
        var totoal = 0
        
        Lyrics.Option.allOption.forEach { opt in
            guard compareOpt.contains(opt) else { return }
            totoal += 1
            guard lyricsOpt.contains(opt) else { return }
            satisfied += 1
        }
        
        return Float(satisfied) / Float(totoal)
    }
    
}

extension LyricsPicker.Quantization: Comparable {
    
    static func <(lhs: LyricsPicker.Quantization, rhs: LyricsPicker.Quantization) -> Bool {
        if lhs.user < rhs.user {
            return true
        } else if lhs.user == rhs.user {
            return lhs.ovaral < rhs.ovaral
        } else {
            return false
        }
    }
    
    static func ==(lhs: LyricsPicker.Quantization, rhs: LyricsPicker.Quantization) -> Bool {
        return lhs.user == rhs.user && lhs.ovaral == rhs.ovaral
    }
}
