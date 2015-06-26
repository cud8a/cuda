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
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
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
    class func countEqual(#str1: String, str2: String) -> Int
    {
        let str1Lower = str1.lowercaseString
        let str2Lower = str2.lowercaseString
        
        let shorterString = count(str1Lower) > count(str2Lower) ? str2Lower : str1Lower
        
        var c = 0
        let indi = indices(shorterString)
        
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
