//
//  CudaRequest.swift
//  Cuda
//
//  Created by Tamas Bara on 26.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation
import UIKit

class CudaRequest
{
    let logEnabled: Bool
    let url: String
    let cookie: String?
    var dateFormatter = NSDateFormatter()
    
    init(url: String, logEnabled: Bool = false, cookie: String? = nil)
    {
        self.logEnabled = logEnabled
        self.url = url
        self.cookie = cookie
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func log(msg: String)
    {
        if logEnabled
        {
            println(msg)
        }
    }
    
    func logError(msg: String)
    {
        println(msg)
    }
    
    func sendAndReceive() -> Bool
    {
        var result = false
        
        if checkNetwork()
        {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let requestUrl = NSURL(string: url)
            {
                let request = NSMutableURLRequest(URL: requestUrl)
                if cookie != nil
                {
                    request.setValue(cookie, forHTTPHeaderField: "Cookie")
                }
                
                let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
                {
                    data, response, error in
                    
                    if error != nil
                    {
                        self.requestError(error)
                        return
                    }
                    
                    if let httpRespone = response as? NSHTTPURLResponse
                    {
                        if httpRespone.statusCode == 200
                        {
                            self.requestOk(response, data: data)
                        }
                        else
                        {
                            self.requestError(httpRespone)
                        }
                    }
                }
                task.resume()
            }
            else
            {
                logError("corrupt URL: \(url)")
            }
            
            result = true
        }
        
        return result
    }
    
    func requestOk(response: NSURLResponse, data: NSData)
    {
        log("\(self), response:\n\(response)\n")
        
        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
        log("\(self), responseString:\n\(responseString)\n")
    }
    
    func requestError(error: NSError)
    {
        logError("\(self), error=\(error)")
    }
    
    func sessionExpired()
    {
        log("session expired")
    }
    
    private func requestError(response: NSHTTPURLResponse)
    {
        logError("\(self), error=\(response.statusCode)")
        
        if response.statusCode == 401
        {
            sessionExpired()
        }
        else
        {
            requestError(NSError(domain: "HTTP", code: response.statusCode, userInfo: nil))
        }
    }
    
    func checkNetwork() -> Bool
    {
        if Cuda.isConnectedToNetwork
        {
            return true
        }
        
        println("No network error")
        
        var showWarning = false
        let defaults = NSUserDefaults.standardUserDefaults()
        if let strDateLastWarning = defaults.objectForKey(Cuda.KEY_LAST_WARNING_NO_NETWORK) as? String
        {
            let dateLastWarning = dateFormatter.dateFromString(strDateLastWarning)
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMinute, fromDate: dateLastWarning!, toDate: NSDate(), options: nil)
            showWarning = components.minute > 0
        }
        else
        {
            showWarning = true
        }
        
        if showWarning
        {
            let alert = UIAlertView()
            alert.title = NSLocalizedString("Warning", comment: "")
            alert.message = NSLocalizedString("NoNetwork", comment: "")
            alert.addButtonWithTitle("OK")
            alert.show()
            
            defaults.setObject(dateFormatter.stringFromDate(NSDate()), forKey: Cuda.KEY_LAST_WARNING_NO_NETWORK)
        }
        
        return false
    }
    
    func getDateUpdatedFromJson(json: JSON) -> NSDate?
    {
        var dateUpdated: NSDate?
        if let strDate = json["updated_at"].string
        {
            // 2015-04-07T21:59:54.281Z
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            dateUpdated = dateFormatter.dateFromString(strDate)?.dateByAddingTimeInterval(2 * 60 * 60)
        }
        
        return dateUpdated
    }
}
