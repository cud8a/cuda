//
//  CudaFetchControl.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

class CudaFetchControl
{
    let key: String
    let timespan: Int
    
    var dateFormatter = NSDateFormatter()
    
    init(key: String, timespan: Int)
    {
        self.key = key
        self.timespan = timespan - 1
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func shouldFetch() -> Bool
    {
        var fetch = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let strDateLastFetch = defaults.objectForKey(key) as? String
        {
            let dateLastFetch = dateFormatter.dateFromString(strDateLastFetch)
            let components = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitMinute, fromDate: dateLastFetch!, toDate: NSDate(), options: nil)
            if components.minute > timespan
            {
                fetch = true
            }
            else
            {
                println("timespan too short for another fetch, key: \(key)")
            }
        }
        else
        {
            fetch = true
        }
        
        return fetch
    }
    
    func stamp()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(dateFormatter.stringFromDate(NSDate()), forKey: key)
    }
    
    func clear()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey(key)
        
        println("fetch control cleared for key: \(key)")
    }
    
    func isFirstFetch() -> Bool
    {
        var firstFetch = true
        let defaults = NSUserDefaults.standardUserDefaults()
        if let strDateLastFetch = defaults.objectForKey(key) as? String
        {
            firstFetch = false
        }
        
        return firstFetch
    }
}
