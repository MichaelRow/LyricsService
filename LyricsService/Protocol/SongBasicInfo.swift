//
//  SearchInfo.swift
//  LyricsX
//
//  Created by lialong on 2017/8/16.
//  Copyright © 2017年 Eru. All rights reserved.
//

import Foundation

struct SearchInfo: Equatable {
    
    var title: String
    var artist: String
    var duration: Int?
    
    static func ==(lhs: SearchInfo, rhs: SearchInfo) -> Bool {
        guard lhs.title == rhs.title,
              lhs.artist == rhs.artist,
              let ld = lhs.duration,
              let rd = lhs.duration,
              ld == rd
        else { return false }
        
        return true
    }
}

