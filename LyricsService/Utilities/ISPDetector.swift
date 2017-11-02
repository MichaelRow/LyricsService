//
//  ISPDetector.swift
//  LyricsService
//
//  Created by Eru on 2017/10/6.
//  Copyright © 2017年 Michael Row. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

private let ISPDetectURL = "http://ip-api.com/json"

class ISPDetector {
    
    enum ISP {
        case telecom
        case unicom
        case mobile
    }
    
    static func detect(_ completionHandler:@escaping (ISP) -> Void) {
        Alamofire.request(ISPDetectURL).responseJSON { response in
            guard case .success(let value) = response.result,
                  let ispName = JSON(value)["isp"].string
            else { return }
            
            if ispName.contains("Unicom") {
                completionHandler(.unicom)
            } else if ispName.contains("China Mobile") {
                completionHandler(.mobile)
            } else {
                completionHandler(.telecom)
            }
        }
    }
    
    private init() {}
}
