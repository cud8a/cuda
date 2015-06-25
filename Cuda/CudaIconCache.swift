//
//  CudaIconCache.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation
import UIKit

class CudaIconCache: NSObject, NSURLSessionTaskDelegate
{
    var counter = 1
    var cacheFolderName = "icons"
    
    var logEnabled = false
    
    class var sharedInstance: CudaIconCache
    {
        struct Singleton
        {
            static let instance = CudaIconCache()
        }
        
        return Singleton.instance
    }
    
    var cache: [String: UIImage] = [:]
    
    func getIcon(url: String, size: CGSize, imgView: UIImageView? = nil) -> UIImage?
    {
        if url.isEmpty
        {
            return nil
        }
        
        let key = "\(CudaUtilities.md5(url))_\(size.width)x\(size.height)"
        var icon = cache[key]
        imgView?.tag = counter
        let tagBefore = counter++
        
        if icon == nil
        {
            if let cacheFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as? String
            {
                let fileManager = NSFileManager.defaultManager()
                
                let iconsFolder = cacheFolder.stringByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!).stringByAppendingPathComponent(cacheFolderName)
                if !fileManager.fileExistsAtPath(iconsFolder)
                {
                    var error:NSError?
                    if !fileManager.createDirectoryAtPath(iconsFolder, withIntermediateDirectories: true, attributes: nil, error: &error)
                    {
                        logError("createDirectoryAtPath error: \(error)")
                    }
                }
                
                let iconFile = iconsFolder.stringByAppendingPathComponent(key)
                if fileManager.fileExistsAtPath(iconFile)
                {
                    icon = UIImage(data: NSData(contentsOfFile: iconFile)!)
                    cache[key] = icon
                    
                    log("icon found in files cache: \(url)")
                }
                else
                {
                    let request = NSMutableURLRequest(URL: NSURL(string: url)!)
                    let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
                        {
                            data, response, error in
                            
                            if error != nil
                            {
                                self.logError("icon download error: \(error)")
                            }
                            else
                            {
                                self.log("icon download ok: \(url)")
                                if let original = UIImage(data: data)
                                {
                                    let icon = self.resizeImage(original, newSize: CGSizeMake(size.width, size.height))
                                    self.cache[key] = icon
                                    
                                    self.checkCanCreateDifferentSize(size, url: url, iconsFolder: iconsFolder, fileManager: fileManager, original: original)
                                    
                                    if imgView != nil
                                    {
                                        if imgView!.tag == tagBefore
                                        {
                                            Cuda.executeOnMainThread()
                                                {
                                                    //imgView!.image = icon
                                                    
                                                    UIView.transitionWithView(imgView!,
                                                        duration:0.5,
                                                        options: UIViewAnimationOptions.TransitionCrossDissolve,
                                                        animations: { imgView!.image = icon },
                                                        completion: nil)
                                            }
                                        }
                                        else
                                        {
                                            self.log("tag changed")
                                        }
                                    }
                                    
                                    if UIImagePNGRepresentation(icon).writeToFile(iconFile, atomically: true)
                                    {
                                        self.log("icon saved as: \(iconFile)")
                                    }
                                    else
                                    {
                                        self.logError("could not save icon")
                                    }
                                }
                                else
                                {
                                    self.logError("could not create image from data: \(data.length)")
                                }
                            }
                    }
                    task.resume()
                }
            }
        }
        else
        {
            log("icon found in cache, size: \(icon!.size)")
        }
        
        log("icons in cache: \(cache.count)")
        
        return icon
    }
    
    private func checkCanCreateDifferentSize(size: CGSize, url: String, iconsFolder: String, fileManager: NSFileManager, original: UIImage)
    {
        if size.width == 30 && size.height == 30
        {
            let size2 = CGSize(width: 50, height: 50)
            let key2 = "\(CudaUtilities.md5(url))_\(size2.width)x\(size2.height)"
            var icon2 = self.cache[key2]
            if icon2 == nil
            {
                let iconFile2 = iconsFolder.stringByAppendingPathComponent(key2)
                if !fileManager.fileExistsAtPath(iconFile2)
                {
                    icon2 = self.resizeImage(original, newSize: CGSizeMake(size2.width, size2.height))
                    self.cache[key2] = icon2
                    
                    if UIImagePNGRepresentation(icon2).writeToFile(iconFile2, atomically: true)
                    {
                        self.log("icon saved as: \(iconFile2)")
                    }
                    else
                    {
                        self.logError("could not save icon")
                    }
                }
            }
        }
        else if size.width == 50 && size.height == 50
        {
            let size2 = CGSize(width: 30, height: 30)
            let key2 = "\(CudaUtilities.md5(url))_\(size2.width)x\(size2.height)"
            var icon2 = self.cache[key2]
            if icon2 == nil
            {
                let iconFile2 = iconsFolder.stringByAppendingPathComponent(key2)
                if !fileManager.fileExistsAtPath(iconFile2)
                {
                    icon2 = self.resizeImage(original, newSize: CGSizeMake(size2.width, size2.height))
                    self.cache[key2] = icon2
                    
                    if UIImagePNGRepresentation(icon2).writeToFile(iconFile2, atomically: true)
                    {
                        self.log("icon saved as: \(iconFile2)")
                    }
                    else
                    {
                        self.logError("could not save icon")
                    }
                }
            }
        }
    }
    
    func deleteIcon(url: String, size: CGSize)
    {
        if url.isEmpty
        {
            return
        }
        
        let key = "\(CudaUtilities.md5(url))_\(size.width)x\(size.height)"
        if let icon = cache.removeValueForKey(key)
        {
            if let cacheFolder = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as? String
            {
                let fileManager = NSFileManager.defaultManager()
                
                let iconsFolder = cacheFolder.stringByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!).stringByAppendingPathComponent(cacheFolderName)
                
                let iconFile = iconsFolder.stringByAppendingPathComponent(key)
                if fileManager.fileExistsAtPath(iconFile)
                {
                    var error: NSError?
                    let deleteOk = fileManager.removeItemAtPath(iconFile, error: &error)
                    if error != nil
                    {
                        logError("error deleting icon: \(error!)")
                    }
                    else if deleteOk
                    {
                        log("icon deleted: \(key)")
                    }
                }
            }
        }
    }
    
    private func log(msg: String)
    {
        if logEnabled
        {
            println(msg)
        }
    }
    
    private func logError(msg: String)
    {
        println(msg)
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage?
    {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        // Get the resized image from the context and a UIImage
        let newImageRef = CGBitmapContextCreateImage(context)
        let newImage = UIImage(CGImage: newImageRef)
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
