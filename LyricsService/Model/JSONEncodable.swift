//
//  JSONEncodable.swift
//  LyricsService
//
//  Created by Michael Row on 2018/4/14.
//  Copyright © 2018年 Michael Row. All rights reserved.
//

import Foundation

public protocol JSONEncodable {}

extension Int : JSONEncodable {}

extension UInt : JSONEncodable {}

extension Bool : JSONEncodable {}

extension Double : JSONEncodable {}

extension String : JSONEncodable {}

extension Data : JSONEncodable {}

extension Array : JSONEncodable where Element == JSONEncodable {}

extension Dictionary : JSONEncodable where Key == String, Value == JSONEncodable {}
