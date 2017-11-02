//
//  LyricsRequestContext.swift
//  LyricsService
//
//  Created by Michael Row on 2017/10/8.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import Alamofire

public enum LyricsError: Error {
    case userCancel
    case network
    case parse
    case unknown
}

class LyricsRequestContext {
    
    private(set) var identifier = arc4random()
    
    private(set) var searchInfo: SearchInfo
    
    private(set) var isCancelled = false
    
    private(set) var group = DispatchGroup()
    
    var allWebLyrics = [WebLyrics]()
    
    var allLyrics = [Lyrics]()
    
    private var requestList = [DataRequest]()
    
    init(_ searchInfo: SearchInfo) {
        self.searchInfo = searchInfo
    }
    
    func add(request: DataRequest) {
        guard !isCancelled else { return }
        requestList.append(request)
    }
    
    func cancel() {
        guard !isCancelled else { return }
        isCancelled = true
        requestList.forEach { $0.cancel() }
    }
}

class PickingSearchContext: LyricsRequestContext {
    
    var pickedQuantization: LyricsPicker.Quantization?
    
    var pickingOption: Lyrics.Option
    
    var lyricsList: WebLyricsList?
    
    var pickedLyrics: Lyrics? { return allLyrics.last }
    
    func pick(lyrics: Lyrics, quantization: LyricsPicker.Quantization) {
        allLyrics.append(lyrics)
        pickedQuantization = quantization
    }
    
    init(_ searchInfo: SearchInfo, option: Lyrics.Option) {
        pickingOption = option
        super.init(searchInfo)
    }
}
