//
//  QianqianSource.swift
//  LyricsX
//
//  Created by Eru on 2017/7/1.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyJSON
import OpenCCSwift
import Private.Qianqian

/// 千千静听(电信)
private let QianqianSearchURLCT = "http://ttlrcct.qianqian.com/dll/lyricsvr.dll?sh?Artist=%@&Title=%@&Flags=0"
/// 千千静听(联通)
private let QianqianSearchURLCU = "http://ttlrccnc.qianqian.com/dll/lyricsvr.dll?sh?Artist=%@&Title=%@&Flags=0"
/// 歌词获取地址（电信）
private let QianqianGetLyricsURLCT = "http://ttlrcct.qianqian.com/dll/lyricsvr.dll?dl?Id=%@&Code=%@"
/// 歌词获取地址（联通）
private let QianqianGetLyricsURLCU = "http://ttlrccnc.qianqian.com/dll/lyricsvr.dll?dl?Id=%@&Code=%@"

private let HexChar: [UInt8] = [41, 42, 43, 44, 45, 46]

public class QianqianSource {
        
    var requestMap = [SearchInfo : LyricsRequestContext]()
    
    private var isp = ISPDetector.ISP.telecom
    
    private var searchBaseURL: String {
        switch isp {
        case .telecom:
            return QianqianSearchURLCT
        case .unicom:
            return QianqianSearchURLCU
        case .mobile:
            return QianqianGetLyricsURLCT
        }
    }
    
    private var lyricsBaseURL: String {
        switch isp {
        case .telecom:
            return QianqianGetLyricsURLCT
        case .unicom:
            return QianqianGetLyricsURLCU
        case .mobile:
            return QianqianGetLyricsURLCT
        }
    }
    
    public init() {
        detectISP()
    }
    
    func detectISP() {
        ISPDetector.detect { isp in
            self.isp = isp
        }
    }
}

extension QianqianSource: LyricsSource {
    public var info: LyricsSourceInfo { return .Qianqian }
}

extension QianqianSource: ConcurrentableLyricsSource {
    
    var httpMethod: HTTPMethod { return .get }
    
    var httpHeaders: HTTPHeaders? { return nil }
    
    func parameters(from info: SearchInfo) -> Parameters? { return nil }
    
    func searchURL(from info: SearchInfo) -> String {
        let converter = ChineseConverter(Simplize.default)
        guard let title = converter?.convert(string: info.title.lowercased().withoutSpace),
              let artist = converter?.convert(string: info.artist.lowercased().withoutSpace),
              let hexTitle = QianqianDecrypt.hexEncodedString(title),
              let hexArtist = QianqianDecrypt.hexEncodedString(artist)
        else { return ""}
        return String(format: searchBaseURL, hexArtist, hexTitle)
    }
    
    func handle(data: Data, context: LyricsRequestContext, completionHandler: ([WebLyrics], LyricsError?) -> Void) {
        let webLyrics = QianqianXMLParser(lyricsBaseURL: self.lyricsBaseURL).parse(lyricsData: data, info: context.searchInfo)
        completionHandler(webLyrics, nil)
    }
}
