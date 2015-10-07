//
//  Cuda.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

extension String
{
    subscript (r: Range<Int>) -> String
    {
        get
        {
            let subStart = self.startIndex.advancedBy(r.startIndex)
            let subEnd = subStart.advancedBy(r.endIndex - r.startIndex)
            return self.substringWithRange(Range(start: subStart, end: subEnd))
        }
    }
    
    func escapeMore() -> String
    {
        var escapedString = self.stringByReplacingOccurrencesOfString("=", withString: "%3D")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("&", withString: "%26")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("+", withString: "%2B")
        escapedString = escapedString.stringByReplacingOccurrencesOfString("!", withString: "%21")
        
        return escapedString
    }
}

class Cuda
{
    static let KEY_LAST_WARNING_NO_NETWORK = "noNetwork"
    
    class var isLowHeight: Bool
    {
        return UIScreen.mainScreen().bounds.height < 568
    }
    
    class var isHighHeight: Bool
    {
        return UIScreen.mainScreen().bounds.height > 568
    }
    
    class var isHighWidth: Bool
    {
        return UIScreen.mainScreen().bounds.width > 320
    }
    
    class var isConnectedToNetwork: Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    class var countryCode: String
    {
        if let code = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String
        {
            return code.lowercaseString
        }
        
        return "us"
    }
    
    class func executeOnMainThread(meth: ()->())
    {
        if NSThread.isMainThread()
        {
            meth()
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue())
            {
                meth()
            }
        }
    }
    
    // how many characters are identical at the beginning of the 2 strings
    class func countEqual(str1 str1: String, str2: String) -> Int
    {
        let str1Lower = str1.lowercaseString
        let str2Lower = str2.lowercaseString
        
        let shorterString = str1Lower.characters.count > str2Lower.characters.count ? str2Lower : str1Lower
        
        var c = 0
        let indi = shorterString.characters.indices
        
        for index in indi
        {
            if str1Lower[index] == str2Lower[index]
            {
                ++c
            }
            else
            {
                break
            }
        }
        
        return c
    }
}
