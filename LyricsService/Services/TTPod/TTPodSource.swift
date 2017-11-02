//
//  TTPodSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/4.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON

private let TTPodSearchURL = "http://lp.music.ttpod.com/lrc/down?lrcid=&artist=%@&title=%@"

public class TTPodSource {
    var requestMap = [SearchInfo : LyricsRequestContext]()
    public init() {}
}

extension TTPodSource: LyricsSource {
    public var info: LyricsSourceInfo { return .TTPod }
}

extension TTPodSource: ConcurrentableLyricsSource {
    var httpMethod: HTTPMethod { return .get }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    func parameters(from info: SearchInfo) -> Parameters? { return nil }
    
    func searchURL(from info: SearchInfo) -> String {
        return String(format: TTPodSearchURL, info.artist, info.title).urlEncoding
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        guard let content = JSON(data)["data"]["lrc"].string,
              let webLyrics = TTPodWebLyrics(info: context.searchInfo, lyricsContent: content)
        else {
            completionHandler([], .parse)
            return
        }
        
        completionHandler([webLyrics], nil)
    }
}
