//
//  KugouDecrypt.swift
//  LyricsX
//
//  Created by Eru on 2017/6/30.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Cocoa
import Archiver

class KugouDecrypt {

    static private let decodeKey: [UInt8] = [64, 71, 97, 119, 94, 50, 116, 71, 81, 54, 49, 45, 206, 210, 110, 105]
    static private let flagKey: [UInt8] = [107, 114, 99, 49] //krc1
    
    /// 酷狗krc解密
    ///
    /// - Parameter base64: 输入base64密文
    /// - Returns: 歌词明文
    static func decrypt(base64: String) -> String? {
        //base64解码
        guard let contentData = Data(base64Encoded: base64) else { return nil }
        //转成byte array
        let byteArray = contentData.toArray(type: UInt8.self)
        //判断是否是krc1标志位开头
        guard byteArray.starts(with: flagKey) else { return nil }
        //移除标志位后的解密数组
        let decryptedArray = byteArray.dropFirst(4).enumerated().map{ $1 ^ decodeKey[$0 % 16] }
        //解密后的data
        let decryptedData = Data(fromArray: decryptedArray);
        //解密后进行解压
        guard let unarchivedData = Archiver.uncompress(decryptedData) else { return nil }

        return String(data: unarchivedData, encoding: .utf8)
    }
    
    /// 酷狗krc加密
    ///
    /// - Parameter krc: krc明文
    /// - Returns: base64密文
    static func encrypt(krc: String) -> String? {
        //转成data
        guard let krcData = krc.data(using: .utf8) else { return nil }
        //zip压缩
        guard let archivedData = Archiver.compress(krcData) else { return nil }
        //转换成byte array
        let byteArray = archivedData.toArray(type: UInt8.self)
        //加密后的数组
        var encryptedArray = byteArray.enumerated().map{ $1 ^ decodeKey[$0 % 16] }
        //添加标志位krc1
        encryptedArray.insert(contentsOf: flagKey, at: 0)
        //转成data
        let encryptedData = Data(fromArray: encryptedArray)
        
        //返回base64字符串
        return encryptedData.base64EncodedString()
    }
    
    private init() {}
}
