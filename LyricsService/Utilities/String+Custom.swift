//
//  String+NSRange.swift
//  LyricsService
//
//  Created by Michael Row on 2017/9/17.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import OpenCCSwift

extension String {
    
    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
              let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
              let from = String.Index(from16, within: self),
              let to = String.Index(to16, within: self)
        else { return nil }
        
        return from ..< to
    }
    
    var urlEncoding: String {
        if let encoded = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return encoded
        } else {
            return ""
        }
    }
    
    var withoutSpace: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
