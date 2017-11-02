//
//  WebLyrics.swift
//  LyricsX
//
//  Created by Eru on 2017/6/22.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation
import Alamofire

public protocol WebLyrics: class {
    
    /// 歌曲搜索信息
    var searchInfo: SearchInfo { get set }
    
    /// 服务端的歌曲名
    var serverTitle: String? { get set }
    
    /// 服务端的歌手名
    var serverArtist: String? { get set }
    
    /// 服务端的专辑名
    var serverAlbum: String? { get set }
    
    /// 歌词源
    var sourceInfo: LyricsSourceInfo { get }
    
    /// 歌词类型
    var lyricsType: LyricsType { get }
    
    /// 获取歌词
    @discardableResult
    func lyrics(_ completeHandler: @escaping (Lyrics?) -> Void) -> DataRequest?
}

protocol NowAvailableWebLyrics: WebLyrics {
    var lyrics: Lyrics { get }
}

extension NowAvailableWebLyrics {
    func lyrics(_ completeHandler: @escaping (Lyrics?) -> Void) -> DataRequest? {
        completeHandler(lyrics)
        return nil
    }
}

protocol DownloadableWebLyrics: WebLyrics {
    var lyrics: Lyrics? { get set }
    var requestURL: String { get }
    var parameters: Parameters? { get }
    var httpHeaders: HTTPHeaders? { get }
    func handle(response: String) -> Lyrics?
}

extension DownloadableWebLyrics {
    
    func handle(response: String) -> Lyrics? { return lyricsType.decoder.decode(response) }
    
    func lyrics(_ completeHandler: @escaping (Lyrics?) -> Void) -> DataRequest? {
        if lyrics != nil {
            completeHandler(lyrics)
            return nil
        }
        
        let request = Alamofire.request(requestURL, parameters: parameters, headers: httpHeaders)
        request.responseString(encoding: .utf8, completionHandler: { response in
            guard case .success(let value) = response.result else {
                completeHandler(nil)
                return
            }
            self.lyrics = self.handle(response: value)
            completeHandler(self.lyrics)
        })
        
        return request
    }
}

