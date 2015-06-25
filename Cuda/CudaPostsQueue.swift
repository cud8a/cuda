//
//  CudaPostsQueue.swift
//  Cuda
//
//  Created by Tamas Bara on 25.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

class CudaPostsQueue
{
    var busy = false
    var dateFormatter = NSDateFormatter()
    
    private init()
    {
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    class var singleton: CudaPostsQueue
    {
        struct Static
        {
            static var instance: CudaPostsQueue?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token)
        {
            Static.instance = CudaPostsQueue()
        }
        
        return Static.instance!
    }
    
    func addToQueue(pending: CudaPendingRow)
    {
        CudaPendingTable().add(pending)
        post()
    }
    
    func post()
    {
        if !Cuda.isConnectedToNetwork
        {
            println("can´t post: no network connection")
            
            return
        }
        
        if !busy
        {
            busy = true
            
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0))
            {
                println("----------- PostsQueue started")
                self.postInBackground()
            }
        }
    }
    
    private func postInBackground(lastId: Int = 0)
    {
        if let pending = CudaPendingTable().nextForLookup(lastId: lastId)
        {
            println("pending method: \(pending.method), id: \(pending.id!), url: \(pending.url), data: \(pending.data)")
            
            send(pending)
        }
        else
        {
            busy = false
            println("----------- PostsQueue finished")
        }
    }
    
    private func send(pending: CudaPendingRow)
    {
        if let url = NSURL(string: pending.url)
        {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = pending.method
            
            if let contentType = pending.contentType
            {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            
            request.HTTPBody = pending.data.dataUsingEncoding(NSUTF8StringEncoding)
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
            {
                data, response, error in
                
                if error != nil
                {
                    println("pending: \(pending.id!) error=\(error)")
                    self.postError(pending, error: error)
                    return
                }
                
                if let httpRespone = response as? NSHTTPURLResponse
                {
                    if httpRespone.statusCode == 200
                    {
                        println("pending: \(pending.id!) response:\n\(response)\n")
                        
                        let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
                        println("pending: \(pending.id!) responseString:\n\(responseString)\n")
                        
                        self.postSuccess(pending, data: data)
                    }
                    else
                    {
                        println("pending: \(pending.id!) error=\(httpRespone.statusCode)")
                        self.postError(pending, error: NSError(domain: "HTTP", code: httpRespone.statusCode, userInfo: nil))
                    }
                }
            }
            task.resume()
        }
        else
        {
            println("corrupt url: \(pending.url)")
        }
    }
    
    private func postError(pending: CudaPendingRow, error: NSError)
    {
        pending.status = CudaPendingStatus.Error
        pending.retries += 1
        pending.dateLastTry = NSDate()
        CudaPendingTable().update(pending)
        
        println("pending updated, id: \(pending.id!)")
        
        postInBackground(lastId: pending.id!)
    }
    
    private func postSuccess(pending: CudaPendingRow, data: NSData)
    {
        CudaPendingTable().delete(pending)
        
        println("pending deleted, id: \(pending.id!)")
        
        postInBackground(lastId: pending.id!)
    }
}
