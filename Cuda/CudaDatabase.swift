//
//  CudaDatabase.swift
//  Cuda
//
//  Created by Tamas Bara on 24.06.15.
//  Copyright (c) 2015 SnoozeSoft. All rights reserved.
//

import Foundation

enum CudaDatabaseResult: String, CustomStringConvertible
{
    case DoneNothing = "DoneNothing"
    case Updated = "Updated"
    case Inserted = "Inserted"
    case Deleted = "Deleted"
    case Error = "Error"
    case ErrorAlreadyExists = "ErrorAlreadyExists"
    
    var description: String
    {
        return "\(self.rawValue)"
    }
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
            print("Unable to open database")
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
        let fileManager = NSFileManager.defaultManager()
        path = filePath(dbName)
        
        if !fileManager.fileExistsAtPath(path!)
        {
            let dbNameFull = "\(self.dbName).sqlite"
            let countDbName = dbNameFull.characters.count
            do
            {
                let directory = path![0...(path!.characters.count - (countDbName + 1))]
                try fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
            }
            catch
            {
                print("createDirectoryAtPath error")
            }
            
            let dbName = dbNameFull[0...(countDbName - 8)]
            if let sourcePath = NSBundle.mainBundle().pathForResource(dbName, ofType: "sqlite")
            {
                do
                {
                    try fileManager.copyItemAtPath(sourcePath, toPath: path!)
                }
                catch
                {
                    print("copyItemAtPath error")
                }
            }
        }
    }
    
    private func filePath(dbName: String) -> String?
    {
        let applicationSupport = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
        
        let applicationFolder = "\(applicationSupport)/\(NSBundle.mainBundle().bundleIdentifier!)"
        
        return "\(applicationFolder)/\(dbName).sqlite"
    }
}
