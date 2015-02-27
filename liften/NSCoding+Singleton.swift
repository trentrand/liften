//
//  NSCoding+Singleton.swift
//  liften
//
//  Created by Trent Rand on 2/27/15.
//  Copyright (c) 2015 applies, llc. All rights reserved.
//

import Foundation

extension NSCache {
    class var sharedInstance : NSCache {
        struct Static {
            static let instance : NSCache = NSCache()
        }
        return Static.instance
    }
}