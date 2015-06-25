//
//  CudaDatabase.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

enum CudaDatabaseResult
{
    case DoneNothing
    case Updated
    case Inserted
    case Deleted
    case Error
    case ErrorAlreadyExists
}

class CudaDatabase
{
    var path: String?
    let dbName = "cuda"
    
    init()
    {
        prepare()
    }
    
    func getDatabase() -> FMDatabase?
    {
        let database = FMDatabase(path: path)
        database.setDateFormat(FMDatabase.storeableDateFormat("yyyy-MM-dd HH:mm:ss"))
        
        if !database.open()
        {
            println("Unable to open database")
            return nil
        }
        
        return database
    }
    
    func getVersion(database: FMDatabase) -> Int
    {
        var version = -1
        
        if let rs = database.executeQuery("PRAGMA user_version", withArgumentsInArray: nil)
        {
            while rs.next()
            {
                version = Int(rs.intForColumn("user_version"))
            }
        }
        
        return version
    }
    
    private func prepare()
    {
        var pathOk = true
        let fileManager = NSFileManager.defaultManager()
        let destinationPath = filePath(dbName)
        
        if destinationPath != nil
        {
            if !fileManager.fileExistsAtPath(destinationPath!)
            {
                var error:NSError?
                if !fileManager.createDirectoryAtPath(destinationPath!.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil, error: &error)
                {
                    println("createDirectoryAtPath error: \(error)")
                }
                
                let sourcePath = NSBundle.mainBundle().pathForResource(dbName, ofType: "sqlite")
                if !fileManager.copyItemAtPath(sourcePath!, toPath: destinationPath!, error: &error)
                {
                    println("copyItemAtPath error: \(error)")
                }
            }
        }
        else
        {
            pathOk = false
        }
        
        if pathOk
        {
            path = destinationPath
        }
    }
    
    private func filePath(dbName: String) -> String?
    {
        if let applicationSupport = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as? String
        {
            let applicationFolder = applicationSupport.stringByAppendingPathComponent(NSBundle.mainBundle().bundleIdentifier!)
            return applicationFolder.stringByAppendingPathComponent("\(dbName).sqlite")
        }
        
        return nil
    }
}
